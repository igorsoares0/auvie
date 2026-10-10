package app.auvie.engine

import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.SurfaceTexture
import android.opengl.GLES11Ext
import android.opengl.Matrix
import android.view.Surface
import androidx.media3.common.MediaItem
import androidx.media3.exoplayer.ExoPlayer
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import app.auvie.engine.develop.DevelopSettings
import app.auvie.engine.gl.Framebuffer
import app.auvie.engine.gl.GlEngine
import app.auvie.engine.gl.OesTexture
import app.auvie.engine.gl.SourceTexture
import com.google.common.truth.Truth.assertThat
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import org.junit.AfterClass
import org.junit.BeforeClass
import org.junit.Test
import org.junit.runner.RunWith

/**
 * The preview path: ExoPlayer → SurfaceTexture (OES) → develop shader,
 * as VideoPreview does, read back from a framebuffer.
 */
@RunWith(AndroidJUnit4::class)
class VideoPreviewRenderTest {
    companion object {
        private val instrumentation = InstrumentationRegistry.getInstrumentation()
        private val context = instrumentation.targetContext
        private lateinit var engine: GlEngine

        @BeforeClass
        @JvmStatic
        fun setUp() {
            engine = GlEngine(context.assets)
        }

        @AfterClass
        @JvmStatic
        fun tearDown() = engine.release()
    }

    /** The first frame of [clip], developed with [settings] at [width]×[height]. */
    private fun render(clip: String, width: Int, height: Int, settings: DevelopSettings = DevelopSettings.NEUTRAL): Bitmap {
        val (oes, frames) = engine.thread.runBlocking {
            engine.gl.egl.makeIdleCurrent()
            val texture = OesTexture()
            texture to SurfaceTexture(texture.id)
        }
        val ready = CountDownLatch(1)
        frames.setOnFrameAvailableListener { ready.countDown() }
        val surface = Surface(frames)
        lateinit var player: ExoPlayer
        instrumentation.runOnMainSync {
            player = ExoPlayer.Builder(context).build().apply {
                setVideoSurface(surface)
                setMediaItem(MediaItem.fromUri(VideoFixtures.uri(clip)))
                prepare()
            }
        }
        try {
            assertThat(ready.await(10, TimeUnit.SECONDS)).isTrue()
            return engine.thread.runBlocking {
                engine.gl.egl.makeIdleCurrent()
                frames.updateTexImage()
                val st = FloatArray(16).also(frames::getTransformMatrix)
                val transform = FloatArray(16)
                Matrix.multiplyMM(transform, 0, st, 0, SourceTexture.FLIP_Y, 0)
                val target = Framebuffer(width, height)
                try {
                    target.bind()
                    engine.gl.renderer.draw(
                        SourceTexture(oes.id, GLES11Ext.GL_TEXTURE_EXTERNAL_OES, width, height, transform),
                        settings, width, height, flipY = false,
                    )
                    target.readBitmap()
                } finally {
                    target.release()
                }
            }
        } finally {
            instrumentation.runOnMainSync { player.release() }
            engine.thread.runBlocking {
                surface.release()
                frames.release()
                oes.release()
            }
        }
    }

    @Test
    fun developsVideoFramesLikePhotos() {
        val plain = render(VideoFixtures.CLIP, 64, 36)
        val red = Color.red(plain.getPixel(32, 18))
        assertThat(red).isIn(118..138)
        val bright = render(VideoFixtures.CLIP, 64, 36, DevelopSettings(exposure = 0.5f))
        assertThat(Color.red(bright.getPixel(32, 18))).isGreaterThan(red + 30)
    }

    @Test
    fun rotatedVideosAreDrawnUpright() {
        val frame = render(VideoFixtures.ROTATED, 36, 64)
        val top = Color.red(frame.getPixel(18, 12))
        val bottom = Color.red(frame.getPixel(18, 52))
        val left = Color.red(frame.getPixel(6, 12))
        val right = Color.red(frame.getPixel(30, 12))
        assertThat(kotlin.math.abs(top - bottom)).isGreaterThan(200)
        assertThat(kotlin.math.abs(left - right)).isLessThan(30)
    }
}
