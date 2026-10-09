package app.auvie.engine.develop

import android.content.res.AssetManager
import android.opengl.GLES30
import app.auvie.engine.export.Tile
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
     * Draws the [outputWidth]×[outputHeight] developed output, or only its
     * [tile] when given (into a target of the tile's size).
     *
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
        tile: Tile? = null,
    ) {
        setLut(settings.curveLut)
        val part = tile ?: Tile(0, 0, outputWidth, outputHeight)
        GLES30.glViewport(0, 0, part.width, part.height)
        program.use()

        source.bind(0)
        program.set("uSource", 0)
        lut.bind(1)
        program.set("uCurveLut", 1)

        GLES30.glUniformMatrix3fv(
            program.uniform("uGeometry"), 1, false, Geometry.toMatrix3(settings.geometry), 0,
        )
        GLES30.glUniform4f(
            program.uniform("uTile"),
            part.x.toFloat() / outputWidth,
            part.y.toFloat() / outputHeight,
            part.width.toFloat() / outputWidth,
            part.height.toFloat() / outputHeight,
        )
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
