package app.auvie.engine

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.media.ExifInterface
import android.net.Uri
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import app.auvie.engine.media.MediaLoader
import app.auvie.engine.media.PixelSize
import app.auvie.engine.pigeon.MediaKind
import com.google.common.truth.Truth.assertThat
import java.io.File
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class MediaLoaderTest {
    private val context = InstrumentationRegistry.getInstrumentation().targetContext
    private val loader = MediaLoader(context)
    private lateinit var dir: File

    @Before
    fun setUp() {
        dir = File(context.cacheDir, "media_loader_test").apply { mkdirs() }
    }

    @After
    fun tearDown() {
        dir.deleteRecursively()
    }

    /** A JPEG of [width]×[height], optionally tagged with an EXIF orientation. */
    private fun jpeg(name: String, width: Int, height: Int, orientation: Int? = null): Uri {
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888).apply {
            eraseColor(Color.rgb(90, 140, 200))
        }
        val file = File(dir, name)
        file.outputStream().use { bitmap.compress(Bitmap.CompressFormat.JPEG, 90, it) }
        bitmap.recycle()
        if (orientation != null) {
            ExifInterface(file.absolutePath).apply {
                setAttribute(ExifInterface.TAG_ORIENTATION, orientation.toString())
                saveAttributes()
            }
        }
        return Uri.fromFile(file)
    }

    @Test
    fun probesAPhoto() {
        val media = loader.probe(jpeg("a.jpg", 4000, 3000))
        assertThat(media.kind).isEqualTo(MediaKind.PHOTO)
        assertThat(media.width to media.height).isEqualTo(4000L to 3000L)
    }

    @Test
    fun decodesALargePhotoWithinTheLimit() {
        val decoded = loader.decodePhoto(jpeg("big.jpg", 6000, 4000), 1024)
        assertThat(decoded.fullSize).isEqualTo(PixelSize(6000, 4000))
        assertThat(decoded.bitmap.width).isEqualTo(1024)
        assertThat(decoded.bitmap.height).isEqualTo(683)
        assertThat(decoded.bitmap.config).isEqualTo(Bitmap.Config.ARGB_8888)
        decoded.bitmap.recycle()
    }

    @Test
    fun appliesExifRotationToProbeAndDecode() {
        val uri = jpeg("rotated.jpg", 400, 300, ExifInterface.ORIENTATION_ROTATE_90)

        val media = loader.probe(uri)
        assertThat(media.width to media.height).isEqualTo(300L to 400L)

        val decoded = loader.decodePhoto(uri, 2000)
        assertThat(decoded.bitmap.width to decoded.bitmap.height).isEqualTo(300 to 400)
        decoded.bitmap.recycle()
    }

    @Test
    fun makesAJpegThumbnailWithinTheLimit() {
        val bytes = loader.thumbnail(jpeg("thumb.jpg", 3000, 2000), 256)
        val bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
        assertThat(maxOf(bitmap.width, bitmap.height)).isAtMost(256)
    }
}
