package app.auvie.engine

import android.graphics.Bitmap
import android.graphics.Color
import android.net.Uri
import android.provider.MediaStore
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import app.auvie.engine.VideoFixtures.Probe
import app.auvie.engine.develop.DevelopSettings
import app.auvie.engine.develop.Geometry
import app.auvie.engine.export.ExportStore
import app.auvie.engine.export.GallerySaver
import app.auvie.engine.export.VideoExporter
import app.auvie.engine.pigeon.DevelopParams
import app.auvie.engine.pigeon.ExportLayer
import app.auvie.engine.pigeon.ExportResult
import app.auvie.engine.pigeon.LayerBlend
import app.auvie.engine.pigeon.VideoExportRequest
import com.google.common.truth.Truth.assertThat
import java.io.File
import kotlin.coroutines.cancellation.CancellationException
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.runBlocking
import org.junit.After
import org.junit.Assert.assertThrows
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class VideoExporterTest {
    private val context = InstrumentationRegistry.getInstrumentation().targetContext
    private val resolver = context.contentResolver
    private val store = ExportStore(context)
    private val exporter = VideoExporter(context, store, GallerySaver(resolver))
    private lateinit var dir: File
    private val results = mutableListOf<ExportResult>()

    @Before
    fun prepare() {
        dir = File(context.cacheDir, "video_exporter_test").apply { mkdirs() }
    }

    @After
    fun cleanUp() {
        results.forEach {
            resolver.delete(Uri.parse(it.mediaUri), null, null)
            File(it.filePath).delete()
        }
        dir.deleteRecursively()
    }

    private fun params(exposure: Double = 0.0, geometry: DoubleArray = Geometry.IDENTITY) = DevelopParams(
        exposure = exposure, brightness = 0.0, contrast = 0.0, highlights = 0.0, shadows = 0.0,
        saturation = 0.0, temperature = 0.0, tint = 0.0, sharpen = 0.0, grain = 0.0, fade = 0.0,
        vignette = 0.0, curveLut = DevelopSettings.IDENTITY_LUT, geometry = geometry,
    )

    private fun request(
        clip: String = VideoFixtures.CLIP,
        width: Long = 640,
        height: Long = 360,
        trimStart: Long = 0,
        trimEnd: Long = 3000,
        audio: Boolean = true,
        params: DevelopParams = params(),
        layers: List<ExportLayer> = emptyList(),
        bitrate: Long = 2_000_000,
    ) = VideoExportRequest(
        uri = VideoFixtures.uri(clip).toString(), params = params, outputWidth = width, outputHeight = height,
        trimStartMs = trimStart, trimEndMs = trimEnd, includeAudio = audio, videoBitrate = bitrate,
        fileName = "video_exporter_test", layers = layers,
    )

    private fun export(request: VideoExportRequest): ExportResult =
        runBlocking { exporter.export(request) { _, _ -> } }.also { results += it }

    private fun center(bitmap: Bitmap) = bitmap.getPixel(bitmap.width / 2, bitmap.height / 2)

    @Test
    fun trimKeepsTheRequestedDuration() {
        val result = export(request(trimStart = 500, trimEnd = 2500))
        Probe(result.filePath).use {
            // ±1 frame at 30 fps.
            assertThat(it.durationMs.toDouble()).isWithin(34.0).of(2000.0)
            assertThat(it.size).isEqualTo(640 to 360)
        }
        assertThat(result.mediaUri).contains("video")
    }

    @Test
    fun withoutSoundThereIsNoAudioTrack() {
        assertThat(VideoFixtures.hasAudioTrack(export(request(audio = true)).filePath)).isTrue()
        assertThat(VideoFixtures.hasAudioTrack(export(request(audio = false)).filePath)).isFalse()
    }

    @Test
    fun clipsWithoutSoundExportEvenWhenSoundIsAsked() {
        val result = export(request(clip = VideoFixtures.SILENT, trimEnd = 2000, audio = true))
        assertThat(VideoFixtures.hasAudioTrack(result.filePath)).isFalse()
    }

    @Test
    fun squareCropComesOutSquare() {
        // The centered 360×360 square of the 640×360 frame.
        val a = 360.0 / 640
        val result = export(request(width = 360, height = 360, params = params(geometry = doubleArrayOf(a, 0.0, 0.0, 1.0, (1 - a) / 2, 0.0))))
        Probe(result.filePath).use { assertThat(it.size).isEqualTo(360 to 360) }
        assertThat(result.width to result.height).isEqualTo(360L to 360L)
    }

    @Test
    fun exposureBrightensTheFrames() {
        val plain = Probe(export(request()).filePath).use { Color.red(center(it.frame(1000))) }
        val bright = Probe(export(request(params = params(exposure = 0.5))).filePath).use { Color.red(center(it.frame(1000))) }
        assertThat(plain).isIn(118..138)
        assertThat(bright).isGreaterThan(plain + 30)
    }

    @Test
    fun layersShowOnlyInTheirTimeRange() {
        val png = File(dir, "red.png")
        Bitmap.createBitmap(32, 32, Bitmap.Config.ARGB_8888).apply { eraseColor(Color.RED) }
            .also { b -> png.outputStream().use { b.compress(Bitmap.CompressFormat.PNG, 100, it) } }
        val layer = ExportLayer(
            path = png.absolutePath, left = 220.0, top = 80.0, width = 200.0, height = 200.0,
            blend = LayerBlend.NORMAL, opacity = 1.0, startMs = 1000, endMs = 2000,
        )
        // Times in the original: the export starts at 0.5 s.
        val result = export(request(trimStart = 500, trimEnd = 2500, layers = listOf(layer)))
        Probe(result.filePath).use {
            assertThat(VideoFixtures.isRed(center(it.frame(250)))).isFalse() // 0.75 s
            assertThat(VideoFixtures.isRed(center(it.frame(1000)))).isTrue() // 1.5 s
            assertThat(VideoFixtures.isRed(center(it.frame(1750)))).isFalse() // 2.25 s
            // Outside the layer's rect the frame stays gray.
            assertThat(Color.red(it.frame(1000).getPixel(20, 20))).isIn(118..138)
        }
    }

    @Test
    fun screenBlendLightens() {
        val png = File(dir, "gray.png")
        Bitmap.createBitmap(8, 8, Bitmap.Config.ARGB_8888).apply { eraseColor(Color.rgb(128, 128, 128)) }
            .also { b -> png.outputStream().use { b.compress(Bitmap.CompressFormat.PNG, 100, it) } }
        val layer = ExportLayer(
            path = png.absolutePath, left = 0.0, top = 0.0, width = 640.0, height = 360.0,
            blend = LayerBlend.SCREEN, opacity = 1.0, startMs = null, endMs = null,
        )
        val result = export(request(layers = listOf(layer)))
        // screen(0.5, 0.5) = 0.75 → ~191.
        Probe(result.filePath).use { assertThat(Color.red(center(it.frame(1000)))).isIn(180..200) }
    }

    @Test
    fun rotatedVideosStayUpright() {
        val result = export(request(clip = VideoFixtures.ROTATED, width = 360, height = 640, trimEnd = 2000))
        Probe(result.filePath).use {
            assertThat(it.size).isEqualTo(360 to 640)
            val frame = it.frame(1000)
            val top = Color.red(frame.getPixel(frame.width / 2, frame.height / 4))
            val bottom = Color.red(frame.getPixel(frame.width / 2, frame.height * 3 / 4))
            val left = Color.red(frame.getPixel(frame.width / 4, frame.height / 4))
            val right = Color.red(frame.getPixel(frame.width * 3 / 4, frame.height / 4))
            // The halves turned with the picture: they split top / bottom.
            assertThat(kotlin.math.abs(top - bottom)).isGreaterThan(200)
            assertThat(kotlin.math.abs(left - right)).isLessThan(30)
        }
    }

    @Test
    fun cancellingLeavesNoFiles() {
        val before = store.directory.listFiles()?.map { it.name }?.toSet() ?: emptySet()
        runBlocking {
            val started = CompletableDeferred<Unit>()
            val job = async(Dispatchers.Default) {
                exporter.export(request(width = 1920, height = 1080, bitrate = 20_000_000)) { fraction, _ ->
                    if (fraction > 0) started.complete(Unit)
                }
            }
            started.await()
            job.cancel()
            assertThrows(CancellationException::class.java) { runBlocking { job.await() } }
        }
        val after = store.directory.listFiles()?.map { it.name }?.toSet() ?: emptySet()
        assertThat(after - before).isEmpty()
        val pending = resolver.query(
            MediaStore.Video.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY),
            arrayOf(MediaStore.MediaColumns._ID),
            "${MediaStore.MediaColumns.DISPLAY_NAME} LIKE ?",
            arrayOf("video_exporter_test%"),
            null,
        )!!.use { it.count }
        assertThat(pending).isEqualTo(0)
    }
}
