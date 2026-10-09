package app.auvie.engine.gl

import android.content.res.AssetManager
import android.graphics.Bitmap
import app.auvie.engine.develop.DevelopRenderer
import app.auvie.engine.develop.DevelopSettings

/**
 * The GL thread, its context and the develop renderer, created lazily on
 * first use. One per Flutter engine.
 */
class GlEngine(private val assets: AssetManager) {
    val thread = GlThread()
    private var state: State? = null

    class State(val egl: EglCore, val renderer: DevelopRenderer)

    /** The GL state; call only on [thread]. */
    val gl: State
        get() {
            check(thread.isCurrent) { "GL used off the GL thread" }
            return state ?: run {
                val egl = EglCore()
                State(egl, DevelopRenderer(assets)).also { state = it }
            }
        }

    /** Develops [bitmap] offscreen at its own size. Call on [thread]. */
    fun renderToBitmap(bitmap: Bitmap, settings: DevelopSettings): Bitmap {
        val gl = gl
        gl.egl.makeIdleCurrent()
        val source = GlTexture.fromBitmap(bitmap)
        val target = Framebuffer(bitmap.width, bitmap.height)
        try {
            target.bind()
            gl.renderer.draw(source, settings, bitmap.width, bitmap.height, flipY = false)
            return target.readBitmap()
        } finally {
            target.release()
            source.release()
        }
    }

    fun release() {
        thread.runBlocking {
            state?.let {
                it.renderer.release()
                it.egl.release()
            }
            state = null
        }
        thread.quit()
    }
}
