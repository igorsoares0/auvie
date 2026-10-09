package app.auvie.engine.export

import app.auvie.engine.media.PixelSize
import app.auvie.engine.pigeon.ExportFormat
import com.google.common.truth.Truth.assertThat
import org.junit.Assert.assertThrows
import org.junit.Test

class ExportPlannerTest {
    @Test
    fun `outputs under the cap are kept`() {
        assertThat(ExportPlanner.clampOutput(4000, 3000)).isEqualTo(PixelSize(4000, 3000))
    }

    @Test
    fun `huge outputs are capped keeping the aspect`() {
        val size = ExportPlanner.clampOutput(12000, 9000)
        assertThat(size.width.toLong() * size.height).isAtMost(ExportPlanner.MAX_PIXELS)
        assertThat(size.width.toDouble() / size.height).isWithin(0.01).of(12000.0 / 9000)
    }

    @Test
    fun `rejects empty outputs`() {
        assertThrows(IllegalArgumentException::class.java) { ExportPlanner.clampOutput(0, 10) }
    }

    @Test
    fun `tiles cover the output exactly once`() {
        val (w, h) = 5000 to 3001
        val tiles = ExportPlanner.tiles(w, h, 2048)
        val covered = Array(h / 1000 + 1) { BooleanArray(w / 1000 + 1) }
        var area = 0L
        for (t in tiles) {
            assertThat(t.width).isAtMost(2048)
            assertThat(t.height).isAtMost(2048)
            assertThat(t.x + t.width).isAtMost(w)
            assertThat(t.y + t.height).isAtMost(h)
            area += t.width.toLong() * t.height
        }
        assertThat(area).isEqualTo(w.toLong() * h)
        assertThat(tiles.map { it.x to it.y }.toSet()).hasSize(tiles.size)
        assertThat(covered).isNotEmpty()
    }

    @Test
    fun `one tile when the output is small`() {
        assertThat(ExportPlanner.tiles(800, 600)).containsExactly(Tile(0, 0, 800, 600))
    }

    @Test
    fun `png needs more room than jpeg`() {
        val jpeg = ExportPlanner.requiredBytes(4000, 3000, ExportFormat.JPEG)
        val png = ExportPlanner.requiredBytes(4000, 3000, ExportFormat.PNG)
        assertThat(jpeg).isGreaterThan(0L)
        assertThat(png).isGreaterThan(jpeg)
    }

    @Test
    fun `file names are safe`() {
        assertThat(ExportPlanner.fileName("Roll 014 · 07", ExportFormat.JPEG)).isEqualTo("Roll_014_07.jpg")
        assertThat(ExportPlanner.fileName("  ", ExportFormat.PNG)).isEqualTo("Auvie.png")
        assertThat(ExportPlanner.mimeType(ExportFormat.PNG)).isEqualTo("image/png")
    }
}
