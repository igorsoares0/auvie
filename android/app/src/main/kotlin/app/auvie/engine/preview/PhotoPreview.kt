package app.auvie.engine.preview

import android.graphics.Bitmap
import android.opengl.EGLSurface
import android.view.Surface
import app.auvie.engine.develop.DevelopSettings
import app.auvie.engine.gl.GlEngine
import app.auvie.engine.gl.GlTexture
import io.flutter.view.TextureRegistry.SurfaceProducer

/**
 * A developed photo shown in a Flutter `Texture`. Created and controlled from
 * the platform thread; rendering happens on the GL thread.
 *
 * Flutter may destroy the surface (e.g. when the app goes to background):
 * [onSurfaceCleanup] drops the EGL surface synchronously and
 * [onSurfaceAvailable] redraws on the new one.
 */
class PhotoPreview private constructor(
    private val producer: SurfaceProducer,
    private val engine: GlEngine,
    private val source: GlTexture,
) : Preview, SurfaceProducer.Callback {
    override val id: Long get() = producer.id()
    val width: Int get() = source.width
    val height: Int get() = source.height

    /** Size of the developed output shown (the crop's aspect). */
    @Volatile private var outputWidth = source.width
    @Volatile private var outputHeight = source.height

    @Volatile private var settings = DevelopSettings.NEUTRAL
    @Volatile private var showOriginal = false
    @Volatile private var surface: Surface? = null
    @Volatile private var disposed = false

    // GL thread only.
    private var eglSurface: EGLSurface? = null
    private var eglSurfaceFor: Surface? = null

    private val scheduler = RenderScheduler(engine.thread::post, ::render)

    private fun start() {
        producer.setSize(source.width, source.height)
        producer.setCallback(this)
        surface = producer.surface
        scheduler.request()
    }

    override fun update(settings: DevelopSettings) {
        this.settings = settings
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

    override fun setShowOriginal(original: Boolean) {
        showOriginal = original
        scheduler.request()
    }

    override fun onSurfaceAvailable() {
        surface = producer.surface
        scheduler.request()
    }

    override fun onSurfaceCleanup() {
        surface = null
        engine.thread.runBlocking { releaseEglSurface() }
    }

    override fun dispose() {
        disposed = true
        producer.setCallback(null)
        surface = null
        engine.thread.runBlocking {
            releaseEglSurface()
            source.release()
        }
        producer.release()
    }

    private fun render() {
        if (disposed) return
        val target = surface ?: return
        val gl = engine.gl
        if (eglSurfaceFor !== target) {
            releaseEglSurface()
            eglSurface = gl.egl.createWindowSurface(target)
            eglSurfaceFor = target
        }
        val egl = eglSurface ?: return
        gl.egl.makeCurrent(egl)
        gl.renderer.draw(
            source, settings, outputWidth, outputHeight,
            flipY = true, showOriginal = showOriginal,
        )
        if (!gl.egl.swapBuffers(egl)) releaseEglSurface()
    }

    private fun releaseEglSurface() {
        eglSurface?.let { engine.gl.egl.releaseSurface(it) }
        eglSurface = null
        eglSurfaceFor = null
    }

    companion object {
        /** Uploads [bitmap] on the GL thread and starts showing it. Call on the platform thread. */
        suspend fun create(producer: SurfaceProducer, engine: GlEngine, bitmap: Bitmap): PhotoPreview {
            val source = engine.thread.call {
                engine.gl.egl.makeIdleCurrent()
                GlTexture.fromBitmap(bitmap)
            }
            return PhotoPreview(producer, engine, source).also { it.start() }
        }
    }
}
