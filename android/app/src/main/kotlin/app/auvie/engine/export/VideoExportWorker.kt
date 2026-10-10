package app.auvie.engine.export

import android.content.Context
import android.os.SystemClock
import android.util.Log
import androidx.work.CoroutineWorker
import androidx.work.Data
import androidx.work.WorkManager
import androidx.work.WorkerParameters
import androidx.work.workDataOf
import app.auvie.engine.EngineErrors
import app.auvie.engine.pigeon.ExportProgress
import app.auvie.engine.pigeon.ExportResult
import app.auvie.engine.pigeon.FlutterError
import java.io.File
import java.io.FileNotFoundException
import java.io.IOException
import kotlin.coroutines.cancellation.CancellationException

/**
 * Runs a video export as a foreground job, so it continues when the app
 * goes to background. The request comes in a JSON job file (deleted at the
 * end); progress goes to [VideoExportBus] and the notification.
 */
class VideoExportWorker(context: Context, params: WorkerParameters) : CoroutineWorker(context, params) {
    override suspend fun doWork(): Result {
        val jobId = inputData.getString(KEY_JOB_ID) ?: return Result.failure()
        val jobFile = File(inputData.getString(KEY_JOB_FILE) ?: return Result.failure())
        val title = inputData.getString(KEY_TITLE) ?: "Auvie"
        try {
            val request = VideoExportPlanner.fromJson(jobFile.readText())
            val notifications = ExportNotifications(applicationContext)
            val cancel = WorkManager.getInstance(applicationContext).createCancelPendingIntent(id)
            val notificationId = jobId.hashCode()
            foreground { setForeground(notifications.progress(notificationId, title, 0.0, cancel)) }

            var lastNotified = 0L
            val exporter = VideoExporter(
                applicationContext,
                ExportStore(applicationContext),
                GallerySaver(applicationContext.contentResolver),
            )
            val result = exporter.export(request) { fraction, stage ->
                VideoExportBus.emit(ExportProgress(jobId, fraction, stage))
                val now = SystemClock.elapsedRealtime()
                if (now - lastNotified >= NOTIFY_MS) {
                    lastNotified = now
                    setForegroundAsync(notifications.progress(notificationId, title, fraction, cancel))
                }
            }
            return Result.success(toData(result))
        } catch (e: CancellationException) {
            throw e
        } catch (e: FlutterError) {
            return Result.failure(workDataOf(KEY_ERROR_CODE to e.code, KEY_ERROR_MESSAGE to e.message))
        } catch (e: IllegalArgumentException) {
            return Result.failure(workDataOf(KEY_ERROR_CODE to EngineErrors.INVALID_PARAMS, KEY_ERROR_MESSAGE to e.message))
        } catch (e: FileNotFoundException) {
            return Result.failure(workDataOf(KEY_ERROR_CODE to EngineErrors.MEDIA_UNAVAILABLE, KEY_ERROR_MESSAGE to e.message))
        } catch (e: IOException) {
            val code = if (e.message?.contains("ENOSPC") == true) EngineErrors.STORAGE_FULL else EngineErrors.DECODE_FAILED
            return Result.failure(workDataOf(KEY_ERROR_CODE to code, KEY_ERROR_MESSAGE to e.message))
        } catch (e: SecurityException) {
            return Result.failure(workDataOf(KEY_ERROR_CODE to EngineErrors.MEDIA_UNAVAILABLE, KEY_ERROR_MESSAGE to e.message))
        } catch (e: Exception) {
            return Result.failure(workDataOf(KEY_ERROR_CODE to EngineErrors.EXPORT_FAILED, KEY_ERROR_MESSAGE to e.message))
        } finally {
            jobFile.delete()
        }
    }

    /** Running in the foreground can be refused (e.g. started from background); export anyway. */
    private suspend fun foreground(block: suspend () -> Unit) {
        try {
            block()
        } catch (e: CancellationException) {
            throw e
        } catch (e: Exception) {
            Log.w(TAG, "Exporting without a foreground notification", e)
        }
    }

    companion object {
        private const val TAG = "VideoExportWorker"
        private const val NOTIFY_MS = 500L
        const val WORK_TAG = "video-export"
        const val KEY_JOB_ID = "jobId"
        const val KEY_JOB_FILE = "jobFile"
        const val KEY_TITLE = "title"
        const val KEY_MEDIA_URI = "mediaUri"
        const val KEY_FILE_PATH = "filePath"
        const val KEY_WIDTH = "width"
        const val KEY_HEIGHT = "height"
        const val KEY_BYTES = "bytes"
        const val KEY_DURATION_MS = "durationMs"
        const val KEY_ERROR_CODE = "errorCode"
        const val KEY_ERROR_MESSAGE = "errorMessage"

        fun toData(result: ExportResult): Data = workDataOf(
            KEY_MEDIA_URI to result.mediaUri,
            KEY_FILE_PATH to result.filePath,
            KEY_WIDTH to result.width,
            KEY_HEIGHT to result.height,
            KEY_BYTES to result.bytes,
            KEY_DURATION_MS to (result.durationMs ?: -1L),
        )

        fun resultOf(data: Data): ExportResult = ExportResult(
            mediaUri = data.getString(KEY_MEDIA_URI)!!,
            filePath = data.getString(KEY_FILE_PATH)!!,
            width = data.getLong(KEY_WIDTH, 0),
            height = data.getLong(KEY_HEIGHT, 0),
            bytes = data.getLong(KEY_BYTES, 0),
            durationMs = data.getLong(KEY_DURATION_MS, -1).takeIf { it >= 0 },
        )
    }
}
