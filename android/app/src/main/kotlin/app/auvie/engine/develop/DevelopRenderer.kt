package app.auvie.engine.develop

import android.content.res.AssetManager
import android.opengl.GLES30
import app.auvie.engine.gl.GlTexture
import app.auvie.engine.gl.ShaderProgram
import java.nio.ByteBuffer
import java.nio.ByteOrder

/**
 * Draws a source texture through develop.frag into the bound target
 * (window surface or framebuffer). GL thread only.
 */
class DevelopRenderer(assets: AssetManager) {
    private val program = ShaderProgram(
        assets.open("shaders/develop.vert").bufferedReader().use { it.readText() },
        assets.open("shaders/develop.frag").bufferedReader().use { it.readText() },
    )
    private val lut = GlTexture.empty(256, 1)
    private var uploadedLut: ByteArray? = null
    private val quad: Int

    init {
        val vertices = floatArrayOf(-1f, -1f, 1f, -1f, -1f, 1f, 1f, 1f)
        val buffer = ByteBuffer.allocateDirect(vertices.size * 4).order(ByteOrder.nativeOrder())
            .asFloatBuffer().put(vertices).also { it.rewind() }
        val ids = IntArray(1)
        GLES30.glGenBuffers(1, ids, 0)
        quad = ids[0]
        GLES30.glBindBuffer(GLES30.GL_ARRAY_BUFFER, quad)
        GLES30.glBufferData(GLES30.GL_ARRAY_BUFFER, vertices.size * 4, buffer, GLES30.GL_STATIC_DRAW)
        GLES30.glBindBuffer(GLES30.GL_ARRAY_BUFFER, 0)
    }

    /**
     * @param flipY true for window surfaces (bitmap top at the top of the
     *   screen), false for framebuffers read back with glReadPixels.
     */
    fun draw(
        source: GlTexture,
        settings: DevelopSettings,
        outputWidth: Int,
        outputHeight: Int,
        flipY: Boolean,
        showOriginal: Boolean = false,
        grainSeed: Float = 0f,
    ) {
        setLut(settings.curveLut)
        GLES30.glViewport(0, 0, outputWidth, outputHeight)
        program.use()

        source.bind(0)
        program.set("uSource", 0)
        lut.bind(1)
        program.set("uCurveLut", 1)

        program.set("uFlipY", flipY)
        program.set("uShowOriginal", showOriginal)
        program.set("uTexel", 1f / source.width, 1f / source.height)
        program.set("uAspect", outputWidth.toFloat() / outputHeight)
        val (gridW, gridH) = GrainGrid.cells(outputWidth, outputHeight)
        program.set("uGrainGrid", gridW, gridH)
        program.set("uGrainSeed", grainSeed)

        program.set("uExposure", settings.exposure)
        program.set("uBrightness", settings.brightness)
        program.set("uContrast", settings.contrast)
        program.set("uHighlights", settings.highlights)
        program.set("uShadows", settings.shadows)
        program.set("uSaturation", settings.saturation)
        program.set("uTemperature", settings.temperature)
        program.set("uTint", settings.tint)
        program.set("uSharpen", settings.sharpen)
        program.set("uGrain", settings.grain)
        program.set("uFade", settings.fade)
        program.set("uVignette", settings.vignette)

        val position = program.attribute("aPosition")
        GLES30.glBindBuffer(GLES30.GL_ARRAY_BUFFER, quad)
        GLES30.glEnableVertexAttribArray(position)
        GLES30.glVertexAttribPointer(position, 2, GLES30.GL_FLOAT, false, 0, 0)
        GLES30.glDrawArrays(GLES30.GL_TRIANGLE_STRIP, 0, 4)
        GLES30.glDisableVertexAttribArray(position)
        GLES30.glBindBuffer(GLES30.GL_ARRAY_BUFFER, 0)
    }

    fun release() {
        program.release()
        lut.release()
        GLES30.glDeleteBuffers(1, intArrayOf(quad), 0)
    }

    private fun setLut(bytes: ByteArray) {
        if (uploadedLut?.contentEquals(bytes) == true) return
        lut.upload(bytes)
        uploadedLut = bytes.copyOf()
    }
}
