package app.auvie.engine.develop

import com.google.common.truth.Truth.assertThat
import org.junit.Test

class GrainGridTest {
    @Test
    fun `small outputs get one cell per pixel`() {
        DevelopTuning.reset()
        assertThat(GrainGrid.cells(800, 600)).isEqualTo(800f to 600f)
    }

    @Test
    fun `large outputs share the grid of a capped short side`() {
        DevelopTuning.reset()
        val (w, h) = GrainGrid.cells(4000, 3000)
        assertThat(h).isWithin(1e-3f).of(DevelopTuning.DEFAULT_GRAIN_CELLS.toFloat())
        assertThat(w / h).isWithin(1e-4f).of(4000f / 3000f)
    }

    @Test
    fun `preview and export of the same photo get the same grid`() {
        val preview = GrainGrid.cells(2000, 1500)
        val export = GrainGrid.cells(8000, 6000)
        assertThat(preview.first).isWithin(1e-2f).of(export.first)
        assertThat(preview.second).isWithin(1e-2f).of(export.second)
    }

    @Test
    fun `the lab can make grain coarser`() {
        assertThat(GrainGrid.cells(4000, 3000, maxCells = 500).second).isWithin(1e-3f).of(500f)
    }
}
