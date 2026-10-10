package app.auvie.engine

import android.net.Uri
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import androidx.work.ListenableWorker
import androidx.work.testing.TestListenableWorkerBuilder
import androidx.work.workDataOf
import app.auvie.engine.develop.DevelopSettings
import app.auvie.engine.develop.Geometry
import app.auvie.engine.export.VideoExportPlanner
import app.auvie.engine.export.VideoExportWorker
import app.auvie.engine.pigeon.DevelopParams
import app.auvie.engine.pigeon.VideoExportRequest
import com.google.common.truth.Truth.assertThat
import java.io.File
import kotlinx.coroutines.runBlocking
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class VideoExportWorkerTest {
    private val context = InstrumentationRegistry.getInstrumentation().targetContext

    private fun worker(request: VideoExportRequest, jobFile: File): VideoExportWorker {
        jobFile.parentFile!!.mkdirs()
        jobFile.writeText(VideoExportPlanner.toJson(request))
        return TestListenableWorkerBuilder<VideoExportWorker>(context)
            .setInputData(
                workDataOf(
                    VideoExportWorker.KEY_JOB_ID to "job",
                    VideoExportWorker.KEY_JOB_FILE to jobFile.absolutePath,
                    VideoExportWorker.KEY_TITLE to "Film 012",
                ),
            )
            .build()
    }

    private fun request(uri: String = VideoFixtures.uri(VideoFixtures.CLIP).toString()) = VideoExportRequest(
        uri = uri,
        params = DevelopParams(
            exposure = 0.0, brightness = 0.0, contrast = 0.0, highlights = 0.0, shadows = 0.0,
            saturation = 0.0, temperature = 0.0, tint = 0.0, sharpen = 0.0, grain = 0.0, fade = 0.0,
            vignette = 0.0, curveLut = DevelopSettings.IDENTITY_LUT, geometry = Geometry.IDENTITY,
        ),
        outputWidth = 320, outputHeight = 180, trimStartMs = 0, trimEndMs = 1000,
        includeAudio = false, videoBitrate = 1_000_000, fileName = "worker_test", layers = emptyList(),
    )

    @Test
    fun exportsAndReportsTheResult() = runBlocking {
        val jobFile = File(context.cacheDir, "video-jobs/job.json")
        val result = worker(request(), jobFile).doWork()

        assertThat(result).isInstanceOf(ListenableWorker.Result.Success::class.java)
        val exported = VideoExportWorker.resultOf((result as ListenableWorker.Result.Success).outputData)
        assertThat(exported.width to exported.height).isEqualTo(320L to 180L)
        assertThat(File(exported.filePath).length()).isGreaterThan(0L)
        assertThat(jobFile.exists()).isFalse()
        context.contentResolver.delete(Uri.parse(exported.mediaUri), null, null)
        File(exported.filePath).delete()
        Unit
    }

    @Test
    fun aMissingVideoFailsWithItsReason() = runBlocking {
        val jobFile = File(context.cacheDir, "video-jobs/missing.json")
        val result = worker(request(uri = "file:///nowhere/clip.mp4"), jobFile).doWork()

        assertThat(result).isInstanceOf(ListenableWorker.Result.Failure::class.java)
        val code = (result as ListenableWorker.Result.Failure).outputData.getString(VideoExportWorker.KEY_ERROR_CODE)
        assertThat(code).isAnyOf(EngineErrors.MEDIA_UNAVAILABLE, EngineErrors.DECODE_FAILED)
        assertThat(jobFile.exists()).isFalse()
        Unit
    }
}
