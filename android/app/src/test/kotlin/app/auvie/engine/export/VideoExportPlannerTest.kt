package app.auvie.engine.export

import app.auvie.engine.develop.DevelopSettings
import app.auvie.engine.develop.Geometry
import app.auvie.engine.pigeon.DevelopParams
import app.auvie.engine.pigeon.ExportLayer
import app.auvie.engine.pigeon.LayerBlend
import app.auvie.engine.pigeon.VideoExportRequest
import com.google.common.truth.Truth.assertThat
import org.junit.Assert.assertThrows
import org.junit.Test

class VideoExportPlannerTest {
    private val params = DevelopParams(
        exposure = 0.25, brightness = 0.0, contrast = -0.1, highlights = 0.0,
        shadows = 0.0, saturation = 0.3, temperature = 0.0, tint = 0.0,
        sharpen = 0.0, grain = 0.4, fade = 0.0, vignette = 0.2,
        curveLut = DevelopSettings.IDENTITY_LUT.copyOf().also { it[5] = 9 },
        geometry = doubleArrayOf(0.5, 0.0, 0.0, 1.0, 0.25, 0.0),
    )

    private fun layer(start: Long? = 1000, end: Long? = 2000) = ExportLayer(
        path = "/cache/layers/j/0.png", left = 10.0, top = 20.0, width = 300.0, height = 100.0,
        blend = LayerBlend.SCREEN, opacity = 0.5, startMs = start, endMs = end,
    )

    private fun request(
        width: Long = 720,
        height: Long = 1280,
        trimStart: Long = 500,
        trimEnd: Long = 2500,
        bitrate: Long = 6_000_000,
        layers: List<ExportLayer> = listOf(layer()),
    ) = VideoExportRequest(
        uri = "content://media/video/1", params = params, outputWidth = width, outputHeight = height,
        trimStartMs = trimStart, trimEndMs = trimEnd, includeAudio = false, videoBitrate = bitrate,
        fileName = "Film 012", layers = layers,
    )

    @Test
    fun `a valid request passes`() {
        VideoExportPlanner.validate(request())
    }

    @Test
    fun `rejects odd, empty or huge outputs`() {
        for (r in listOf(request(width = 721), request(height = 0), request(width = 4096, height = 2160))) {
            assertThrows(IllegalArgumentException::class.java) { VideoExportPlanner.validate(r) }
        }
    }

    @Test
    fun `rejects bad trims, bitrates and layer times`() {
        val bad = listOf(
            request(trimStart = 2000, trimEnd = 2000),
            request(trimStart = -1),
            request(bitrate = 10),
            request(layers = listOf(layer(start = 1000, end = null))),
            request(layers = listOf(layer(start = 2000, end = 1000))),
        )
        for (r in bad) {
            assertThrows(IllegalArgumentException::class.java) { VideoExportPlanner.validate(r) }
        }
    }

    @Test
    fun `needed room matches the Dart estimate`() {
        // Same numbers as test/features/export/export_options_test.dart.
        assertThat(VideoExportPlanner.requiredBytes(8_000_000, 10_000, includeAudio = true)).isEqualTo(22_352_000)
        assertThat(VideoExportPlanner.requiredBytes(8_000_000, 10_000, includeAudio = false)).isEqualTo(22_000_000)
    }

    @Test
    fun `layers show in their range of the original clip`() {
        val timed = layer(start = 1000, end = 2000)
        // Frames count from the trim start (500 ms).
        assertThat(VideoExportPlanner.layerVisible(timed, 400_000, trimStartMs = 500)).isFalse()
        assertThat(VideoExportPlanner.layerVisible(timed, 500_000, trimStartMs = 500)).isTrue()
        assertThat(VideoExportPlanner.layerVisible(timed, 1_499_000, trimStartMs = 500)).isTrue()
        assertThat(VideoExportPlanner.layerVisible(timed, 1_500_000, trimStartMs = 500)).isFalse()
        assertThat(VideoExportPlanner.layerVisible(layer(null, null), 99_000_000, trimStartMs = 0)).isTrue()
    }

    @Test
    fun `the job file round-trips the request`() {
        val original = request(layers = listOf(layer(), layer(start = null, end = null)))
        val copy = VideoExportPlanner.fromJson(VideoExportPlanner.toJson(original))
        assertThat(copy.copy(params = params)).isEqualTo(original)
        assertThat(copy.params.curveLut).isEqualTo(params.curveLut)
        assertThat(copy.params.geometry).isEqualTo(params.geometry)
        assertThat(DevelopSettings.from(copy.params)).isEqualTo(DevelopSettings.from(params))
        assertThat(copy.layers[1].startMs).isNull()
    }

    @Test
    fun `file names are safe mp4 names`() {
        assertThat(VideoExportPlanner.fileName("Film 012 · 07")).isEqualTo("Film_012_07.mp4")
        assertThat(VideoExportPlanner.fileName("  ")).isEqualTo("Auvie.mp4")
    }

    @Test
    fun `identity geometry is accepted`() {
        VideoExportPlanner.validate(request().copy(params = params.copy(geometry = Geometry.IDENTITY)))
    }
}
