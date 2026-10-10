package app.auvie.engine

import android.graphics.BitmapFactory
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import app.auvie.engine.media.MediaLoader
import app.auvie.engine.media.PixelSize
import app.auvie.engine.media.WaveformReader
import com.google.common.truth.Truth.assertThat
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class MediaToolsTest {
    private val context = InstrumentationRegistry.getInstrumentation().targetContext
    private val loader = MediaLoader(context)

    @Test
    fun readsVideoInfo() {
        val clip = loader.videoInfo(VideoFixtures.uri(VideoFixtures.CLIP))
        assertThat(clip.size).isEqualTo(PixelSize(640, 360))
        assertThat(clip.durationMs).isIn(2900L..3100L)
        assertThat(clip.hasAudio).isTrue()
        assertThat(loader.videoInfo(VideoFixtures.uri(VideoFixtures.SILENT)).hasAudio).isFalse()
        assertThat(loader.videoInfo(VideoFixtures.uri(VideoFixtures.ROTATED)).size).isEqualTo(PixelSize(360, 640))
    }

    @Test
    fun filmFramesAreSmallJpegs() {
        val frames = loader.videoFrames(VideoFixtures.uri(VideoFixtures.CLIP), 5, 160)
        assertThat(frames).hasSize(5)
        for (jpeg in frames) {
            val bitmap = BitmapFactory.decodeByteArray(jpeg, 0, jpeg.size)
            assertThat(maxOf(bitmap.width, bitmap.height)).isAtMost(160)
        }
    }

    @Test
    fun videoFramesAreUpright() {
        val frame = loader.videoFrame(VideoFixtures.uri(VideoFixtures.ROTATED), 500, 640)
        assertThat(frame.height).isGreaterThan(frame.width)
    }

    @Test
    fun waveformFollowsTheSound() {
        val reader = WaveformReader(context)
        val peaks = reader.read(VideoFixtures.uri(VideoFixtures.CLIP), 30)!!
        assertThat(peaks).hasLength(30)
        assertThat(peaks.max()).isEqualTo(1.0)
        // A steady tone: every slice is loud.
        assertThat(peaks.drop(1).dropLast(1).min()).isGreaterThan(0.5)
        assertThat(reader.read(VideoFixtures.uri(VideoFixtures.SILENT), 30)).isNull()
    }
}
