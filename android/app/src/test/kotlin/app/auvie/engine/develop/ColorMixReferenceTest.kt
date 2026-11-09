package app.auvie.engine.develop

import com.google.common.truth.Truth.assertThat
import org.junit.Test

/** Step 3b of develop.frag (color mix / HSL), through the CPU reference. */
class ColorMixReferenceTest {
    private fun develop(rgb: IntArray, lut: ByteArray) =
        DevelopReference.develop255(rgb, DevelopSettings(colorLut = lut)).toList()

    @Test
    fun `a neutral table is not a color mix`() {
        assertThat(DevelopSettings.NEUTRAL.hasColorMix).isFalse()
        assertThat(DevelopSettings(colorLut = ColorLuts.uniform()).hasColorMix).isFalse()
        assertThat(DevelopSettings(colorLut = ColorLuts.uniform(saturation = 0.2)).hasColorMix).isTrue()
    }

    @Test
    fun `full desaturation turns colors gray`() {
        val out = develop(intArrayOf(200, 60, 40), ColorLuts.uniform(saturation = -1.0))
        assertThat(out.max() - out.min()).isAtMost(1)
    }

    @Test
    fun `grays have no hue and stay as they are`() {
        val lut = ColorLuts.uniform(hue = 1.0, saturation = 1.0, luminance = -1.0)
        for (level in listOf(0, 30, 128, 200, 255)) {
            val gray = intArrayOf(level, level, level)
            assertThat(develop(gray, lut)).isEqualTo(gray.toList())
        }
    }

    @Test
    fun `hue turns toward the next range`() {
        // Red at +1 turns 30 degrees: orange.
        val out = develop(intArrayOf(255, 0, 0), ColorLuts.uniform(hue = 1.0))
        assertThat(out[0]).isEqualTo(255)
        assertThat(out[1]).isIn(120..136)
        assertThat(out[2]).isEqualTo(0)
    }

    @Test
    fun `luminance darkens and lightens`() {
        val red = intArrayOf(200, 40, 40)
        val darker = develop(red, ColorLuts.uniform(luminance = -1.0))
        val lighter = develop(red, ColorLuts.uniform(luminance = 1.0))
        assertThat(darker).isEqualTo(listOf(100, 20, 20))
        assertThat(lighter.zip(red.toList()).all { (out, input) -> out > input }).isTrue()
    }

    @Test
    fun `only the chosen range changes`() {
        // Desaturate around blue (240 degrees) only.
        val lut = ColorLuts.byHue { hue ->
            doubleArrayOf(0.0, if (hue in 0.6..0.73) -1.0 else 0.0, 0.0)
        }
        val blue = develop(intArrayOf(40, 60, 220), lut)
        val red = develop(intArrayOf(220, 50, 40), lut)
        assertThat(blue.max() - blue.min()).isAtMost(2)
        assertThat(red).isEqualTo(listOf(220, 50, 40))
    }

    @Test
    fun `the table wraps round the wheel`() {
        // Entries 255 and 0 sit either side of hue 0: halfway is their average.
        val lut = ColorLuts.uniform()
        lut[255 * 4 + 1] = (DevelopSettings.COLOR_LUT_ZERO + 127).toByte()
        val m = DevelopReference.colorMixAt(lut, 0.0)
        assertThat(m[1]).isWithin(1e-9).of(0.5)
        assertThat(DevelopReference.colorMixAt(lut, 0.5)[1]).isWithin(1e-9).of(0.0)
    }
}
