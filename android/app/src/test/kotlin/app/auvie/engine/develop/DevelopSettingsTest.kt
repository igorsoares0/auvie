package app.auvie.engine.develop

import app.auvie.engine.pigeon.DevelopParams
import com.google.common.truth.Truth.assertThat
import org.junit.Assert.assertThrows
import org.junit.Test

class DevelopSettingsTest {
    @Test
    fun `maps every pigeon field to the parameter of the same name`() {
        // Distinct value per field: 0.01, 0.02, ... in Adjustment order.
        val params = DevelopParams(
            0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08, 0.09, 0.10, 0.11, 0.12,
            DevelopSettings.IDENTITY_LUT,
        )
        val values = DevelopSettings.from(params).values()
        assertThat(values).hasSize(DevelopSettings.PARAMETERS.size)
        values.forEachIndexed { i, v -> assertThat(v).isWithin(1e-6f).of((i + 1) / 100f) }
    }

    @Test
    fun `clamps to each parameter's range`() {
        val s = DevelopSettings.fromMap(mapOf("exposure" to 3.0, "grain" to -0.5, "vignette" to -2.0))
        assertThat(s.exposure).isEqualTo(1f)
        assertThat(s.grain).isEqualTo(0f)
        assertThat(s.vignette).isEqualTo(-1f)
    }

    @Test
    fun `rejects unknown parameters and bad LUTs`() {
        assertThrows(IllegalArgumentException::class.java) {
            DevelopSettings.fromMap(mapOf("bloom" to 0.2))
        }
        assertThrows(IllegalArgumentException::class.java) {
            DevelopSettings(curveLut = ByteArray(10))
        }
    }

    @Test
    fun `equality compares LUT contents`() {
        val a = DevelopSettings(exposure = 0.2f, curveLut = DevelopSettings.IDENTITY_LUT.copyOf())
        val b = DevelopSettings(exposure = 0.2f, curveLut = DevelopSettings.IDENTITY_LUT.copyOf())
        assertThat(a).isEqualTo(b)
        assertThat(a.hashCode()).isEqualTo(b.hashCode())
        assertThat(a).isNotEqualTo(DevelopSettings(exposure = 0.2f, curveLut = DevelopVectors.INVERT_LUT))
    }

    @Test
    fun `identity LUT maps each entry to itself with opaque alpha`() {
        val lut = DevelopSettings.IDENTITY_LUT
        for (i in 0 until 256) {
            assertThat(lut[i * 4].toInt() and 0xFF).isEqualTo(i)
            assertThat(lut[i * 4 + 3].toInt() and 0xFF).isEqualTo(255)
        }
    }
}
