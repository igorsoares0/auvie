package app.auvie.engine.export

import android.content.Context
import android.graphics.BitmapFactory
import android.opengl.GLES30
import androidx.media3.common.VideoFrameProcessingException
import androidx.media3.common.util.Size
import androidx.media3.effect.BaseGlShaderProgram
import androidx.media3.effect.GlEffect
import androidx.media3.effect.GlShaderProgram
import app.auvie.engine.gl.Framebuffer
import app.auvie.engine.gl.FullScreenQuad
import app.auvie.engine.gl.GlTexture
import app.auvie.engine.gl.ShaderProgram
import app.auvie.engine.pigeon.ExportLayer
import app.auvie.engine.pigeon.LayerBlend

/**
 * Composites the elements Flutter rasterized over each frame, bottom first,
 * with their blend modes, opacity and time ranges. Layer rects are in
 * output pixels; layers are uploaded once.
 */
class LayerEffect(
    private val layers: List<ExportLayer>,
    private val trimStartMs: Long,
) : GlEffect {
    override fun toGlShaderProgram(context: Context, useHdr: Boolean): GlShaderProgram {
        val read = { name: String -> context.assets.open("shaders/$name").bufferedReader().use { it.readText() } }
        return Program(ShaderProgram(read("develop.vert"), read("layer_blend.frag")))
    }

    private inner class Program(private val program: ShaderProgram) :
        BaseGlShaderProgram(/* useHighPrecisionColorComponents= */ false, /* texturePoolCapacity= */ 1) {
        private val quad = FullScreenQuad()
        private var textures: List<GlTexture> = emptyList()
        private var buffers: List<Framebuffer> = emptyList()
        private var width = 0
        private var height = 0

        override fun configure(inputWidth: Int, inputHeight: Int): Size {
            width = inputWidth
            height = inputHeight
            releaseResources()
            textures = layers.map { layer ->
                val bitmap = BitmapFactory.decodeFile(layer.path)
                    ?: throw VideoFrameProcessingException("Cannot read layer ${layer.path}")
                try {
                    GlTexture.fromBitmap(bitmap)
                } finally {
                    bitmap.recycle()
                }
            }
            buffers = if (layers.size > 1) List(2) { Framebuffer(width, height) } else emptyList()
            return Size(inputWidth, inputHeight)
        }

        override fun drawFrame(inputTexId: Int, presentationTimeUs: Long) {
            GLES30.glDisable(GLES30.GL_BLEND)
            val output = IntArray(1).also { GLES30.glGetIntegerv(GLES30.GL_FRAMEBUFFER_BINDING, it, 0) }[0]
            val visible = layers.indices.filter {
                VideoExportPlanner.layerVisible(layers[it], presentationTimeUs, trimStartMs)
            }
            if (visible.isEmpty()) {
                pass(inputTexId, null, output)
                return
            }
            var base = inputTexId
            visible.forEachIndexed { n, index ->
                val last = n == visible.lastIndex
                val target = if (last) null else buffers[n % 2]
                pass(base, index, target?.id ?: output)
                if (target != null) base = target.textureId
            }
        }

        /** Draws [base] with layer [index] (none: a copy) into framebuffer [into]. */
        private fun pass(base: Int, index: Int?, into: Int) {
            GLES30.glBindFramebuffer(GLES30.GL_FRAMEBUFFER, into)
            GLES30.glViewport(0, 0, width, height)
            program.use()
            GLES30.glActiveTexture(GLES30.GL_TEXTURE0)
            GLES30.glBindTexture(GLES30.GL_TEXTURE_2D, base)
            program.set("uBase", 0)
            program.set("uFlipY", false)
            if (index == null) {
                program.set("uOpacity", 0f)
            } else {
                val layer = layers[index]
                textures[index].bind(1)
                program.set("uLayer", 1)
                program.set("uOpacity", layer.opacity.toFloat())
                program.set("uBlend", blendIndex(layer.blend))
                GLES30.glUniform4f(
                    program.uniform("uRect"),
                    (layer.left / width).toFloat(),
                    (1 - (layer.top + layer.height) / height).toFloat(),
                    ((layer.left + layer.width) / width).toFloat(),
                    (1 - layer.top / height).toFloat(),
                )
            }
            quad.draw(program)
        }

        override fun release() {
            super.release()
            releaseResources()
            quad.release()
            program.release()
        }

        private fun releaseResources() {
            textures.forEach { it.release() }
            buffers.forEach { it.release() }
            textures = emptyList()
            buffers = emptyList()
        }
    }

    companion object {
        fun blendIndex(blend: LayerBlend): Int = when (blend) {
            LayerBlend.NORMAL -> 0
            LayerBlend.SCREEN -> 1
            LayerBlend.MULTIPLY -> 2
            LayerBlend.OVERLAY -> 3
            LayerBlend.SOFT_LIGHT -> 4
        }
    }
}
