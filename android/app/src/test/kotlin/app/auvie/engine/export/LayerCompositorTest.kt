package app.auvie.engine.export

import app.auvie.engine.pigeon.ExportLayer
import app.auvie.engine.pigeon.LayerBlend
import com.google.common.truth.Truth.assertThat
import org.junit.Assert.assertThrows
import org.junit.Test

class LayerCompositorTest {
    private fun layer(
        path: String = "/x.png",
        w: Double = 10.0,
        h: Double = 10.0,
        opacity: Double = 1.0,
    ) = ExportLayer(path, 0.0, 0.0, w, h, LayerBlend.NORMAL, opacity)

    @Test
    fun `valid layers pass`() {
        LayerCompositor.validate(layer())
    }

    @Test
    fun `rejects layers without file, size or with bad opacity`() {
        assertThrows(IllegalArgumentException::class.java) { LayerCompositor.validate(layer(path = " ")) }
        assertThrows(IllegalArgumentException::class.java) { LayerCompositor.validate(layer(w = 0.0)) }
        assertThrows(IllegalArgumentException::class.java) { LayerCompositor.validate(layer(h = Double.NaN)) }
        assertThrows(IllegalArgumentException::class.java) { LayerCompositor.validate(layer(opacity = 1.5)) }
    }
}
