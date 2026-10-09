package app.auvie.engine.develop

import app.auvie.engine.media.PixelSize
import com.google.common.truth.Truth.assertThat
import org.junit.Test

class GeometryTest {
    @Test
    fun `matrix is column-major for GLSL`() {
        val m = Geometry.toMatrix3(doubleArrayOf(1.0, 2.0, 3.0, 4.0, 5.0, 6.0))
        // x' = 1x + 2y + 5, y' = 3x + 4y + 6.
        assertThat(m.toList()).containsExactly(1f, 3f, 0f, 2f, 4f, 0f, 5f, 6f, 1f).inOrder()
    }

    @Test
    fun `identity keeps the source size`() {
        assertThat(Geometry.outputSize(Geometry.IDENTITY, 4000, 3000, 8000))
            .isEqualTo(PixelSize(4000, 3000))
    }

    @Test
    fun `a half-width crop halves the output width`() {
        val half = doubleArrayOf(0.5, 0.0, 0.0, 1.0, 0.25, 0.0)
        assertThat(Geometry.outputSize(half, 4000, 3000, 8000)).isEqualTo(PixelSize(2000, 3000))
    }

    @Test
    fun `a quarter turn swaps the sides and the limit applies`() {
        val turn = doubleArrayOf(0.0, 1.0, -1.0, 0.0, 0.0, 1.0)
        assertThat(Geometry.outputSize(turn, 4000, 3000, 8000)).isEqualTo(PixelSize(3000, 4000))
        assertThat(Geometry.outputSize(turn, 4000, 3000, 400)).isEqualTo(PixelSize(300, 400))
    }
}
