package app.auvie.engine.gl

import android.graphics.Bitmap
import android.opengl.GLES30
import android.opengl.GLUtils
import java.nio.ByteBuffer
import java.nio.ByteOrder

/** An RGBA8 texture. GL thread only. */
class GlTexture private constructor(val id: Int, val width: Int, val height: Int) {
    fun bind(unit: Int) {
        GLES30.glActiveTexture(GLES30.GL_TEXTURE0 + unit)
        GLES30.glBindTexture(GLES30.GL_TEXTURE_2D, id)
    }

    /** Replaces the pixels of a texture created with [empty]. */
    fun upload(rgba: ByteArray) {
        require(rgba.size == width * height * 4) { "Expected ${width * height * 4} bytes, got ${rgba.size}" }
        GLES30.glBindTexture(GLES30.GL_TEXTURE_2D, id)
        GLES30.glTexSubImage2D(
            GLES30.GL_TEXTURE_2D, 0, 0, 0, width, height,
            GLES30.GL_RGBA, GLES30.GL_UNSIGNED_BYTE, ByteBuffer.wrap(rgba),
        )
    }

    fun release() = GLES30.glDeleteTextures(1, intArrayOf(id), 0)

    companion object {
        /** Uploads [bitmap] (row 0 at t = 0). The bitmap can be recycled afterwards. */
        fun fromBitmap(bitmap: Bitmap): GlTexture {
            val texture = create(bitmap.width, bitmap.height)
            GLUtils.texImage2D(GLES30.GL_TEXTURE_2D, 0, bitmap, 0)
            return texture
        }

        fun empty(width: Int, height: Int): GlTexture {
            val texture = create(width, height)
            GLES30.glTexImage2D(
                GLES30.GL_TEXTURE_2D, 0, GLES30.GL_RGBA8, width, height, 0,
                GLES30.GL_RGBA, GLES30.GL_UNSIGNED_BYTE, null,
            )
            return texture
        }

        private fun create(width: Int, height: Int): GlTexture {
            val ids = IntArray(1)
            GLES30.glGenTextures(1, ids, 0)
            GLES30.glBindTexture(GLES30.GL_TEXTURE_2D, ids[0])
            GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D, GLES30.GL_TEXTURE_MIN_FILTER, GLES30.GL_LINEAR)
            GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D, GLES30.GL_TEXTURE_MAG_FILTER, GLES30.GL_LINEAR)
            GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D, GLES30.GL_TEXTURE_WRAP_S, GLES30.GL_CLAMP_TO_EDGE)
            GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D, GLES30.GL_TEXTURE_WRAP_T, GLES30.GL_CLAMP_TO_EDGE)
            return GlTexture(ids[0], width, height)
        }
    }
}

/** An offscreen render target whose pixels can be read back. GL thread only. */
class Framebuffer(val width: Int, val height: Int) {
    private val texture = GlTexture.empty(width, height)
    private val id: Int

    init {
        val ids = IntArray(1)
        GLES30.glGenFramebuffers(1, ids, 0)
        id = ids[0]
        GLES30.glBindFramebuffer(GLES30.GL_FRAMEBUFFER, id)
        GLES30.glFramebufferTexture2D(
            GLES30.GL_FRAMEBUFFER, GLES30.GL_COLOR_ATTACHMENT0, GLES30.GL_TEXTURE_2D, texture.id, 0,
        )
        val status = GLES30.glCheckFramebufferStatus(GLES30.GL_FRAMEBUFFER)
        GLES30.glBindFramebuffer(GLES30.GL_FRAMEBUFFER, 0)
        check(status == GLES30.GL_FRAMEBUFFER_COMPLETE) { "Framebuffer incomplete: 0x${Integer.toHexString(status)}" }
    }

    fun bind() = GLES30.glBindFramebuffer(GLES30.GL_FRAMEBUFFER, id)

    /** Reads the pixels into a new bitmap, row 0 first (matching the source bitmap). */
    fun readBitmap(): Bitmap {
        bind()
        val buffer = ByteBuffer.allocateDirect(width * height * 4).order(ByteOrder.nativeOrder())
        GLES30.glReadPixels(0, 0, width, height, GLES30.GL_RGBA, GLES30.GL_UNSIGNED_BYTE, buffer)
        GLES30.glBindFramebuffer(GLES30.GL_FRAMEBUFFER, 0)
        buffer.rewind()
        return Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888).apply {
            copyPixelsFromBuffer(buffer)
        }
    }

    fun release() {
        GLES30.glDeleteFramebuffers(1, intArrayOf(id), 0)
        texture.release()
    }
}
