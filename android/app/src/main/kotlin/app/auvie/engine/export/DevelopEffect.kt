package app.auvie.engine.export

import android.content.Context
import android.opengl.GLES30
import androidx.media3.common.util.Size
import androidx.media3.effect.BaseGlShaderProgram
import androidx.media3.effect.GlEffect
import androidx.media3.effect.GlShaderProgram
import app.auvie.engine.develop.DevelopRenderer
import app.auvie.engine.develop.DevelopSettings
import app.auvie.engine.gl.SourceTexture
import kotlin.math.floor

/**
 * The develop shader as a Media3 effect: adjustments, preset, curves,
 * crop / turns / straighten and the scale to [outputWidth]×[outputHeight],
 * in one pass, exactly as for photos. Grain changes 24 times a second.
 */
class DevelopEffect(
    private val settings: DevelopSettings,
    private val outputWidth: Int,
    private val outputHeight: Int,
    private val trimStartMs: Long,
) : GlEffect {
    override fun toGlShaderProgram(context: Context, useHdr: Boolean): GlShaderProgram =
        Program(DevelopRenderer(context.assets))

    private inner class Program(private val renderer: DevelopRenderer) :
        BaseGlShaderProgram(/* useHighPrecisionColorComponents= */ false, /* texturePoolCapacity= */ 1) {
        private var inputWidth = 0
        private var inputHeight = 0

        override fun configure(inputWidth: Int, inputHeight: Int): Size {
            this.inputWidth = inputWidth
            this.inputHeight = inputHeight
            return Size(outputWidth, outputHeight)
        }

        override fun drawFrame(inputTexId: Int, presentationTimeUs: Long) {
            GLES30.glDisable(GLES30.GL_BLEND)
            val source = SourceTexture(
                inputTexId, GLES30.GL_TEXTURE_2D, inputWidth, inputHeight, SourceTexture.FLIP_Y,
            )
            val mediaSeconds = trimStartMs / 1000.0 + presentationTimeUs / 1_000_000.0
            renderer.draw(
                source, settings, outputWidth, outputHeight,
                flipY = true, grainSeed = floor(mediaSeconds * GRAIN_PER_SECOND).toFloat(),
            )
        }

        override fun release() {
            super.release()
            renderer.release()
        }
    }

    companion object {
        const val GRAIN_PER_SECOND = 24
    }
}
