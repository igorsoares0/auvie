package app.auvie.engine.preview

import android.content.Context
import android.graphics.SurfaceTexture
import android.net.Uri
import android.opengl.EGLSurface
import android.opengl.GLES11Ext
import android.opengl.GLES30
import android.opengl.Matrix
import android.os.Handler
import android.os.Looper
import android.view.Surface
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.SeekParameters
import app.auvie.engine.develop.DevelopSettings
import app.auvie.engine.gl.GlEngine
import app.auvie.engine.gl.OesTexture
import app.auvie.engine.gl.SourceTexture
import app.auvie.engine.media.VideoInfo
import app.auvie.engine.pigeon.PlaybackState
import io.flutter.view.TextureRegistry.SurfaceProducer
import java.util.concurrent.atomic.AtomicBoolean

/**
 * A developed video shown in a Flutter `Texture`. ExoPlayer decodes into a
 * SurfaceTexture owned by the GL thread, and every frame is drawn through
 * the develop shader, like a photo. When paused, edits redraw the last
 * frame. Playback loops inside the trim range.
 *
 * Created and controlled from the platform thread (ExoPlayer's thread);
 * rendering happens on the GL thread.
 */
class VideoPreview private constructor(
    private val producer: SurfaceProducer,
    private val engine: GlEngine,
    private val oes: OesTexture,
    private val frames: SurfaceTexture,
    private val player: ExoPlayer,
    private val uri: Uri,
    private val info: VideoInfo,
    private val onState: (PlaybackState) -> Unit,
) : Preview, SurfaceProducer.Callback {
    override val id: Long get() = producer.id()
    private val decoderSurface = Surface(frames)

    @Volatile private var outputWidth = info.size.width
    @Volatile private var outputHeight = info.size.height
    @Volatile private var settings = DevelopSettings.NEUTRAL
    @Volatile private var showOriginal = false
    @Volatile private var surface: Surface? = null
    @Volatile private var disposed = false
    private val frameAvailable = AtomicBoolean(false)

    // GL thread only.
    private var eglSurface: EGLSurface? = null
    private var eglSurfaceFor: Surface? = null
    private var hasFrame = false
    private var frameCount = 0
    private val frameMatrix = FloatArray(16)
    private val transform = FloatArray(16)

    // Platform thread only.
    private var rangeStartMs = 0L
    private var rangeEndMs = info.durationMs
    private val main = Handler(Looper.getMainLooper())
    private val ticker = object : Runnable {
        override fun run() {
            if (disposed) return
            val position = player.currentPosition
            if (position >= rangeEndMs && rangeEndMs < info.durationMs) {
                player.seekTo(rangeStartMs)
            }
            emit()
            if (player.isPlaying) main.postDelayed(this, TICK_MS)
        }
    }

    private val scheduler = RenderScheduler(engine.thread::post, ::render)

    private val listener = object : Player.Listener {
        override fun onIsPlayingChanged(isPlaying: Boolean) {
            main.removeCallbacks(ticker)
            if (isPlaying) main.post(ticker) else emit()
        }

        override fun onPlaybackStateChanged(playbackState: Int) {
            // Reaching the end of the clip loops back to the trim start.
            if (playbackState == Player.STATE_ENDED) player.seekTo(rangeStartMs)
        }

        override fun onPositionDiscontinuity(
            oldPosition: Player.PositionInfo,
            newPosition: Player.PositionInfo,
            reason: Int,
        ) = emit()
    }

    private fun start(width: Int, height: Int) {
        outputWidth = width
        outputHeight = height
        producer.setSize(width, height)
        producer.setCallback(this)
        surface = producer.surface
        frames.setOnFrameAvailableListener {
            frameAvailable.set(true)
            scheduler.request()
        }
        player.addListener(listener)
        player.setVideoSurface(decoderSurface)
        player.setMediaItem(MediaItem.fromUri(uri))
        player.prepare()
    }

    fun play() {
        val position = player.currentPosition
        if (player.playbackState == Player.STATE_ENDED || position < rangeStartMs || position >= rangeEndMs - END_SLACK_MS) {
            player.seekTo(rangeStartMs)
        }
        player.play()
    }

    fun pause() {
        player.pause()
        emit()
    }

    fun seek(positionMs: Long, exact: Boolean) {
        player.setSeekParameters(if (exact) SeekParameters.EXACT else SeekParameters.CLOSEST_SYNC)
        player.seekTo(positionMs.coerceIn(0, info.durationMs))
        emit()
    }

    fun setRange(startMs: Long, endMs: Long) {
        require(startMs in 0 until endMs) { "Invalid range $startMs…$endMs" }
        rangeStartMs = startMs
        rangeEndMs = endMs.coerceAtMost(info.durationMs)
        val position = player.currentPosition
        if (position < rangeStartMs || position > rangeEndMs) seek(rangeStartMs, exact = true)
    }

    fun setMuted(muted: Boolean) {
        player.volume = if (muted) 0f else 1f
    }

    override fun update(settings: DevelopSettings) {
        this.settings = settings
        scheduler.request()
    }

    override fun setShowOriginal(original: Boolean) {
        showOriginal = original
        scheduler.request()
    }

    override fun resize(width: Int, height: Int) {
        require(width > 0 && height > 0) { "Preview size must be positive" }
        if (width == outputWidth && height == outputHeight) return
        outputWidth = width
        outputHeight = height
        producer.setSize(width, height)
        surface = producer.surface
        scheduler.request()
    }

    override fun onSurfaceAvailable() {
        surface = producer.surface
        scheduler.request()
    }

    override fun onSurfaceCleanup() {
        // The app went to background: stop, and drop the EGL surface now.
        player.pause()
        surface = null
        engine.thread.runBlocking { releaseEglSurface() }
    }

    override fun dispose() {
        disposed = true
        main.removeCallbacks(ticker)
        player.removeListener(listener)
        player.release()
        producer.setCallback(null)
        surface = null
        engine.thread.runBlocking {
            releaseEglSurface()
            frames.setOnFrameAvailableListener(null)
            decoderSurface.release()
            frames.release()
            oes.release()
        }
        producer.release()
    }

    private fun emit() {
        if (disposed) return
        onState(PlaybackState(id, player.currentPosition, player.isPlaying))
    }

    private fun render() {
        if (disposed) return
        val gl = engine.gl
        val target = surface
        if (target == null) {
            // Keep the decoder flowing even with nothing to show.
            if (frameAvailable.getAndSet(false)) {
                gl.egl.makeIdleCurrent()
                latchFrame()
            }
            return
        }
        if (eglSurfaceFor !== target) {
            releaseEglSurface()
            eglSurface = gl.egl.createWindowSurface(target)
            eglSurfaceFor = target
        }
        val egl = eglSurface ?: return
        gl.egl.makeCurrent(egl)
        if (frameAvailable.getAndSet(false)) latchFrame()
        if (hasFrame) {
            val source = SourceTexture(
                oes.id, GLES11Ext.GL_TEXTURE_EXTERNAL_OES, info.size.width, info.size.height, transform,
            )
            gl.renderer.draw(
                source, settings, outputWidth, outputHeight,
                flipY = true, showOriginal = showOriginal, grainSeed = (frameCount % GRAIN_PATTERNS).toFloat(),
            )
        } else {
            GLES30.glViewport(0, 0, outputWidth, outputHeight)
            GLES30.glClearColor(0f, 0f, 0f, 1f)
            GLES30.glClear(GLES30.GL_COLOR_BUFFER_BIT)
        }
        if (!gl.egl.swapBuffers(egl)) releaseEglSurface()
    }

    /** Takes the newest decoded frame into the OES texture. GL thread, context current. */
    private fun latchFrame() {
        frames.updateTexImage()
        frames.getTransformMatrix(frameMatrix)
        Matrix.multiplyMM(transform, 0, frameMatrix, 0, SourceTexture.FLIP_Y, 0)
        hasFrame = true
        frameCount++
    }

    private fun releaseEglSurface() {
        eglSurface?.let { engine.gl.egl.releaseSurface(it) }
        eglSurface = null
        eglSurfaceFor = null
    }

    companion object {
        private const val TICK_MS = 33L
        private const val END_SLACK_MS = 50L
        private const val GRAIN_PATTERNS = 1000

        /**
         * Opens the video at [uri] paused on its first frame, drawn at most
         * [maxPx] on the longer side. Call on the platform thread.
         */
        suspend fun create(
            context: Context,
            producer: SurfaceProducer,
            engine: GlEngine,
            uri: Uri,
            info: VideoInfo,
            maxPx: Int,
            onState: (PlaybackState) -> Unit,
        ): VideoPreview {
            val (oes, frames) = engine.thread.call {
                engine.gl.egl.makeIdleCurrent()
                val texture = OesTexture()
                texture to SurfaceTexture(texture.id)
            }
            val player = ExoPlayer.Builder(context).build()
            val size = info.size.fitWithin(maxPx)
            return VideoPreview(producer, engine, oes, frames, player, uri, info, onState)
                .also { it.start(size.width, size.height) }
        }
    }
}
