package app.auvie.engine

import android.graphics.Bitmap
import android.graphics.Color
import android.net.Uri
import android.provider.MediaStore
import androidx.exifinterface.media.ExifInterface
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import app.auvie.engine.develop.DevelopSettings
import app.auvie.engine.export.ExportStore
import app.auvie.engine.export.GallerySaver
import app.auvie.engine.export.MetadataCopier
import app.auvie.engine.export.PhotoExporter
import app.auvie.engine.gl.GlEngine
import app.auvie.engine.media.MediaLoader
import app.auvie.engine.pigeon.DevelopParams
import app.auvie.engine.pigeon.ExportFormat
import app.auvie.engine.pigeon.ExportLayer
import app.auvie.engine.pigeon.LayerBlend
import app.auvie.engine.pigeon.ExportRequest
import app.auvie.engine.pigeon.ExportResult
import com.google.common.truth.Truth.assertThat
import java.io.File
import kotlin.coroutines.cancellation.CancellationException
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.runBlocking
import org.junit.After
import org.junit.AfterClass
import org.junit.Before
import org.junit.BeforeClass
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class PhotoExporterTest {
    companion object {
        private val context = InstrumentationRegistry.getInstrumentation().targetContext
        private lateinit var engine: GlEngine

        @BeforeClass
        @JvmStatic
        fun setUp() {
            engine = GlEngine(context.assets)
        }

        @AfterClass
        @JvmStatic
        fun tearDown() = engine.release()
    }

    private val resolver = context.contentResolver
    private val store = ExportStore(context)
    private lateinit var dir: File
    private val saved = mutableListOf<Uri>()

    private fun exporter(tile: Int = 2048) = PhotoExporter(
        engine, MediaLoader(context), store, GallerySaver(resolver), MetadataCopier(resolver), tile,
    )

    @Before
    fun prepare() {
        dir = File(context.cacheDir, "exporter_test").apply { mkdirs() }
    }

    @After
    fun cleanUp() {
        saved.forEach { resolver.delete(it, null, null) }
        dir.deleteRecursively()
    }

    /** A [width]×[height] JPEG rotated 90° by EXIF, with a GPS position. */
    private fun original(name: String, width: Int, height: Int): Uri {
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.RGB_565).apply {
            eraseColor(Color.rgb(120, 140, 160))
        }
        val file = File(dir, name)
        file.outputStream().use { bitmap.compress(Bitmap.CompressFormat.JPEG, 85, it) }
        bitmap.recycle()
        ExifInterface(file.absolutePath).apply {
            setAttribute(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_ROTATE_90.toString())
            setLatLong(-23.55, -46.63)
            setAttribute(ExifInterface.TAG_MODEL, "Test Camera")
            saveAttributes()
        }
        return Uri.fromFile(file)
    }

    private fun params(): DevelopParams = DevelopSettings.NEUTRAL.let {
        DevelopParams(
            0.1, 0.0, 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.0, 0.0,
            it.curveLut, it.geometry,
        )
    }

    private fun request(
        uri: Uri,
        width: Int,
        height: Int,
        format: ExportFormat = ExportFormat.JPEG,
        keep: Boolean = false,
        name: String = "auvie-test-${System.nanoTime()}",
        layers: List<ExportLayer> = emptyList(),
    ) = ExportRequest(
        uri.toString(), params(), format, width.toLong(), height.toLong(),
        maxOf(width, height).toLong(), keep, name, layers,
    )

    private fun run(request: ExportRequest, tile: Int = 2048): ExportResult = runBlocking {
        exporter(tile).export(request) { _, _ -> }.also { saved += Uri.parse(it.mediaUri) }
    }

    private fun isPending(uri: Uri): Int? = resolver.query(
        uri, arrayOf(MediaStore.Images.Media.IS_PENDING), null, null, null,
    )?.use { if (it.moveToFirst()) it.getInt(0) else null }

    @Test
    fun exportsAJpegToTheGalleryWithoutMetadata() {
        val source = original("a.jpg", 3000, 2000) // Upright: 2000 × 3000.
        val result = run(request(source, 2000, 3000))

        assertThat(result.width to result.height).isEqualTo(2000L to 3000L)
        val file = File(result.filePath)
        assertThat(file.readBytes().take(2)).containsExactly(0xFF.toByte(), 0xD8.toByte()).inOrder()
        val exif = ExifInterface(file.absolutePath)
        assertThat(exif.latLong).isNull()
        assertThat(exif.getAttribute(ExifInterface.TAG_MODEL)).isNull()
        assertThat(isPending(Uri.parse(result.mediaUri))).isEqualTo(0)
    }

    @Test
    fun keepsCaptureDataWhenAskedWithUprightOrientation() {
        val source = original("b.jpg", 3000, 2000)
        val result = run(request(source, 1000, 1500, keep = true))

        val exif = ExifInterface(result.filePath)
        assertThat(exif.latLong!![0]).isWithin(0.01).of(-23.55)
        assertThat(exif.getAttribute(ExifInterface.TAG_MODEL)).isEqualTo("Test Camera")
        assertThat(exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, 0))
            .isEqualTo(ExifInterface.ORIENTATION_NORMAL)
    }

    @Test
    fun exportsPngAtASmallerSize() {
        val source = original("c.jpg", 3000, 2000)
        val result = run(request(source, 400, 600, format = ExportFormat.PNG))

        assertThat(result.width to result.height).isEqualTo(400L to 600L)
        assertThat(File(result.filePath).readBytes().take(4))
            .containsExactly(0x89.toByte(), 0x50.toByte(), 0x4E.toByte(), 0x47.toByte()).inOrder()
    }

    @Test
    fun tiledExportsMatchTheRequestedSize() {
        val source = original("d.jpg", 1200, 900)
        val result = run(request(source, 900, 1200), tile = 256)
        assertThat(result.width to result.height).isEqualTo(900L to 1200L)
    }

    @Test
    fun cancellingLeavesNothingBehind() {
        val source = original("e.jpg", 3000, 2000)
        val name = "auvie-cancel-${System.nanoTime()}"
        val before = store.directory.listFiles()?.size ?: 0
        val started = CompletableDeferred<Unit>()

        val error = runBlocking {
            val job = async(Dispatchers.Default) {
                exporter(tile = 128).export(request(source, 2000, 3000, name = name)) { _, stage ->
                    if (stage == PhotoExporter.STAGE_RENDER) started.complete(Unit)
                }
            }
            started.await()
            job.cancel()
            runCatching { job.await() }.exceptionOrNull()
        }

        assertThat(error).isInstanceOf(CancellationException::class.java)
        assertThat(store.directory.listFiles()?.size ?: 0).isEqualTo(before)
        val rows = resolver.query(
            MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY),
            arrayOf(MediaStore.Images.Media._ID),
            "${MediaStore.Images.Media.DISPLAY_NAME} LIKE ?",
            arrayOf("$name%"),
            null,
        )?.use { it.count }
        assertThat(rows).isEqualTo(0)
    }

    @Test
    fun aFortyEightMegapixelOriginalExportsWithoutRunningOutOfMemory() {
        val source = original("big.jpg", 8000, 6000) // Upright: 6000 × 8000.
        val result = run(request(source, 6000, 8000))
        // Capped at 32 MP by the planner.
        assertThat(result.width * result.height).isAtMost(32_000_000L)
        assertThat(result.height).isGreaterThan(result.width)
    }

    /** A [w]×[h] PNG layer filled with [color]. */
    private fun layer(name: String, w: Int, h: Int, color: Int): String {
        val bitmap = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888).apply { eraseColor(color) }
        val file = File(dir, name)
        file.outputStream().use { bitmap.compress(Bitmap.CompressFormat.PNG, 100, it) }
        bitmap.recycle()
        return file.absolutePath
    }

    @Test
    fun layersAreCompositedWithTheirPlaceBlendAndOpacity() {
        val source = original("g.jpg", 600, 400) // Upright 400 × 600, grey-blue.
        val red = layer("red.png", 10, 10, Color.RED)
        val white = layer("white.png", 10, 10, Color.WHITE)
        val result = run(
            request(
                source, 400, 600, format = ExportFormat.PNG,
                layers = listOf(
                    // Opaque red square, scaled up from 10 px to 100 px.
                    ExportLayer(red, 50.0, 50.0, 100.0, 100.0, LayerBlend.NORMAL, 1.0),
                    // Half-opaque white over the lower half.
                    ExportLayer(white, 0.0, 300.0, 400.0, 300.0, LayerBlend.NORMAL, 0.5),
                    // Screen with black changes nothing.
                    ExportLayer(layer("black.png", 4, 4, Color.BLACK), 0.0, 0.0, 400.0, 600.0, LayerBlend.SCREEN, 1.0),
                ),
            ),
        )
        val out = android.graphics.BitmapFactory.decodeFile(result.filePath)
        val inRed = out.getPixel(100, 100)
        assertThat(Color.red(inRed)).isGreaterThan(240)
        assertThat(Color.green(inRed)).isLessThan(20)
        val outside = out.getPixel(300, 100)
        val lifted = out.getPixel(300, 500)
        // Half-white lifts the photo halfway towards white.
        assertThat(Color.green(lifted)).isGreaterThan(Color.green(outside) + 30)
        assertThat(Color.green(lifted)).isLessThan(255)
        out.recycle()
    }

    @Test
    fun screenLightensAndMultiplyDarkens() {
        val grey = Color.rgb(128, 128, 128)
        val output = Bitmap.createBitmap(20, 10, Bitmap.Config.ARGB_8888).apply { eraseColor(grey) }
        val mid = layer("mid.png", 2, 2, Color.rgb(128, 128, 128))
        app.auvie.engine.export.LayerCompositor.compose(
            output,
            listOf(
                ExportLayer(mid, 0.0, 0.0, 10.0, 10.0, LayerBlend.SCREEN, 1.0),
                ExportLayer(mid, 10.0, 0.0, 10.0, 10.0, LayerBlend.MULTIPLY, 1.0),
            ),
        )
        assertThat(Color.red(output.getPixel(5, 5))).isGreaterThan(180)
        assertThat(Color.red(output.getPixel(15, 5))).isLessThan(80)
    }
}
