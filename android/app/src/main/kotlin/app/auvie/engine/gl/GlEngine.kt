package app.auvie.engine.gl

import android.content.res.AssetManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.opengl.GLES30
import app.auvie.engine.develop.DevelopRenderer
import app.auvie.engine.develop.DevelopSettings
import app.auvie.engine.export.ExportPlanner
import app.auvie.engine.export.Tile

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

    /** Largest texture side the GPU accepts. Call on [thread]. */
    val maxTextureSize: Int by lazy {
        gl
        val size = IntArray(1)
        GLES30.glGetIntegerv(GLES30.GL_MAX_TEXTURE_SIZE, size, 0)
        size[0]
    }

    /** Uploads [bitmap] as a source texture. Call on [thread]. */
    fun upload(bitmap: Bitmap): GlTexture {
        gl.egl.makeIdleCurrent()
        return GlTexture.fromBitmap(bitmap)
    }

    /** Develops one [tile] of a [outputWidth]×[outputHeight] output. Call on [thread]. */
    fun renderTile(
        source: GlTexture,
        settings: DevelopSettings,
        outputWidth: Int,
        outputHeight: Int,
        tile: Tile,
    ): Bitmap {
        val gl = gl
        gl.egl.makeIdleCurrent()
        val target = Framebuffer(tile.width, tile.height)
        try {
            target.bind()
            gl.renderer.draw(source, settings, outputWidth, outputHeight, flipY = false, tile = tile)
            return target.readBitmap()
        } finally {
            target.release()
        }
    }

    /**
     * Develops [bitmap] offscreen into a [outputWidth]×[outputHeight] bitmap
     * (the crop's size by default), tile by tile. Call on [thread].
     */
    fun renderToBitmap(
        bitmap: Bitmap,
        settings: DevelopSettings,
        outputWidth: Int = bitmap.width,
        outputHeight: Int = bitmap.height,
        tileSize: Int = ExportPlanner.TILE,
    ): Bitmap {
        val source = upload(bitmap)
        try {
            val output = Bitmap.createBitmap(outputWidth, outputHeight, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(output)
            for (tile in ExportPlanner.tiles(outputWidth, outputHeight, tileSize)) {
                val part = renderTile(source, settings, outputWidth, outputHeight, tile)
                canvas.drawBitmap(part, tile.x.toFloat(), tile.y.toFloat(), null)
                part.recycle()
            }
            return output
        } finally {
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
