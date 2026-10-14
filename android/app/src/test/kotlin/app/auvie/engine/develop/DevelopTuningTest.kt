package app.auvie.engine.develop

import com.google.common.truth.Truth.assertThat
import org.junit.Test

class DevelopTuningTest {
    @Test
    fun `the sharpen radius follows the photo's size`() {
        // A 1080 px preview and a 4320 px original: 1 px and 4 px of radius,
        // the same fraction of the picture.
        val preview = DevelopTuning.sharpenStep(1440, 1080)
        val full = DevelopTuning.sharpenStep(5760, 4320)
        assertThat(preview.second).isWithin(1e-6f).of(full.second)
        assertThat(preview.first * 1440).isWithin(1e-3f).of(1.08f)
    }

    @Test
    fun `small sources sharpen by at least one pixel`() {
        val (x, y) = DevelopTuning.sharpenStep(400, 300)
        assertThat(x * 400).isWithin(1e-4f).of(1f)
        assertThat(y * 300).isWithin(1e-4f).of(1f)
    }
}
