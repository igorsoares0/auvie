package app.auvie.engine.media

import com.google.common.truth.Truth.assertThat
import org.junit.Test

class WaveformTest {
    @Test
    fun `samples land in the slice of their time`() {
        val peaks = DoubleArray(4)
        // Stereo at 4 Hz over 1 s: one frame per slice, louder channel wins.
        val pcm = shortArrayOf(100, -16384, 0, 0, 32767, 5, -8192, 0)
        Waveform.accumulate(peaks, pcm, channels = 2, sampleRate = 4, startUs = 0, durationUs = 1_000_000)
        assertThat(peaks[0]).isWithin(1e-6).of(0.5)
        assertThat(peaks[1]).isEqualTo(0.0)
        assertThat(peaks[2]).isWithin(1e-4).of(1.0)
        assertThat(peaks[3]).isWithin(1e-6).of(0.25)
    }

    @Test
    fun `buffers later in the clip use their start time`() {
        val peaks = DoubleArray(10)
        Waveform.accumulate(peaks, shortArrayOf(8192), channels = 1, sampleRate = 44100, startUs = 950_000, durationUs = 1_000_000)
        assertThat(peaks[9]).isWithin(1e-6).of(0.25)
        // Samples past the end are dropped.
        Waveform.accumulate(peaks, shortArrayOf(32767), channels = 1, sampleRate = 44100, startUs = 1_000_000, durationUs = 1_000_000)
        assertThat(peaks.max()).isWithin(1e-6).of(0.25)
    }

    @Test
    fun `normalizing scales the loudest slice to one`() {
        assertThat(Waveform.normalized(doubleArrayOf(0.1, 0.4, 0.2)).toList())
            .containsExactly(0.25, 1.0, 0.5).inOrder()
        assertThat(Waveform.normalized(DoubleArray(3)).toList()).containsExactly(0.0, 0.0, 0.0)
    }
}
