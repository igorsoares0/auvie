package app.auvie.engine.develop

import android.content.res.AssetManager
import android.opengl.GLES30
import app.auvie.engine.export.Tile
import app.auvie.engine.gl.FullScreenQuad
import app.auvie.engine.gl.GlTexture
import app.auvie.engine.gl.ShaderProgram
import app.auvie.engine.gl.SourceTexture

/**
 * Draws a source texture through develop.frag into the bound target
 * (window surface or framebuffer). Photos and Media3 frames are 2D
 * textures; preview video frames are external (OES) textures, drawn by a
 * second build of the same shader. GL thread only (any thread with the
 * context it was created on current).
 */
class DevelopRenderer(assets: AssetManager) {
    private val vertexSource = assets.open("shaders/develop.vert").bufferedReader().use { it.readText() }
    private val fragmentSource = assets.open("shaders/develop.frag").bufferedReader().use { it.readText() }
    private val program2d = ShaderProgram(vertexSource, fragmentSource)
    private var programExternal: ShaderProgram? = null
    private val lut = GlTexture.empty(256, 1)
    private var uploadedLut: ByteArray? = null
    private val quad = FullScreenQuad()

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
    ) = draw(source.asSource(), settings, outputWidth, outputHeight, flipY, showOriginal, grainSeed, tile)

    fun draw(
        source: SourceTexture,
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
        val program = if (source.isExternal) external() else program2d
        program.use()

        source.bind(0)
        program.set("uSource", 0)
        lut.bind(1)
        program.set("uCurveLut", 1)
        program.setMatrix4("uSourceTransform", source.transform)

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

        quad.draw(program)
    }

    fun release() {
        program2d.release()
        programExternal?.release()
        lut.release()
        quad.release()
    }

    private fun external(): ShaderProgram =
        programExternal ?: ShaderProgram(vertexSource, fragmentSource, listOf("EXTERNAL_SOURCE"))
            .also { programExternal = it }

    private fun setLut(bytes: ByteArray) {
        if (uploadedLut?.contentEquals(bytes) == true) return
        lut.upload(bytes)
        uploadedLut = bytes.copyOf()
    }
}
