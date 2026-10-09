package app.auvie.engine.media

import android.media.ExifInterface
import com.google.common.truth.Truth.assertThat
import org.junit.Assert.assertThrows
import org.junit.Test

class PixelSizeTest {
    @Test
    fun `fits the longer side and keeps the aspect`() {
        assertThat(PixelSize(4000, 3000).fitWithin(2000)).isEqualTo(PixelSize(2000, 1500))
        assertThat(PixelSize(3000, 4000).fitWithin(1000)).isEqualTo(PixelSize(750, 1000))
    }

    @Test
    fun `never scales up`() {
        assertThat(PixelSize(800, 600).fitWithin(2000)).isEqualTo(PixelSize(800, 600))
    }

    @Test
    fun `keeps at least one pixel`() {
        assertThat(PixelSize(10000, 1).fitWithin(100)).isEqualTo(PixelSize(100, 1))
    }

    @Test
    fun `rejects a non-positive limit`() {
        assertThrows(IllegalArgumentException::class.java) { PixelSize(10, 10).fitWithin(0) }
    }

    @Test
    fun `quarter rotations swap the sides`() {
        assertThat(PixelSize(4000, 3000).rotated(90)).isEqualTo(PixelSize(3000, 4000))
        assertThat(PixelSize(4000, 3000).rotated(180)).isEqualTo(PixelSize(4000, 3000))
        assertThat(PixelSize(4000, 3000).rotated(270)).isEqualTo(PixelSize(3000, 4000))
    }

    @Test
    fun `EXIF orientations map to rotations`() {
        assertThat(MediaLoader.rotationOf(ExifInterface.ORIENTATION_NORMAL)).isEqualTo(0)
        assertThat(MediaLoader.rotationOf(ExifInterface.ORIENTATION_ROTATE_90)).isEqualTo(90)
        assertThat(MediaLoader.rotationOf(ExifInterface.ORIENTATION_ROTATE_180)).isEqualTo(180)
        assertThat(MediaLoader.rotationOf(ExifInterface.ORIENTATION_TRANSVERSE)).isEqualTo(90)
        assertThat(MediaLoader.rotationOf(ExifInterface.ORIENTATION_FLIP_HORIZONTAL)).isEqualTo(0)
    }
}
