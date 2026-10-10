package app.auvie.engine.export

import android.content.Context
import android.net.Uri
import android.os.Handler
import android.os.Looper
import androidx.media3.common.Effect
import androidx.media3.common.MediaItem
import androidx.media3.common.MimeTypes
import androidx.media3.transformer.Composition
import androidx.media3.transformer.DefaultEncoderFactory
import androidx.media3.transformer.EditedMediaItem
import androidx.media3.transformer.EditedMediaItemSequence
import androidx.media3.transformer.Effects
import androidx.media3.transformer.ExportException
import androidx.media3.transformer.ProgressHolder
import androidx.media3.transformer.Transformer
import androidx.media3.transformer.VideoEncoderSettings
import app.auvie.engine.EngineErrors
import app.auvie.engine.develop.DevelopSettings
import app.auvie.engine.media.MediaLoader
import app.auvie.engine.pigeon.ExportResult
import app.auvie.engine.pigeon.FlutterError
import app.auvie.engine.pigeon.VideoExportRequest
import java.io.File
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.withContext

/**
 * Video export with Media3 Transformer: trim, develop (+ crop and scale),
 * element layers, H.264 / AAC MP4, then a copy in Movies/Auvie. Cancelling
 * the coroutine cancels the Transformer and deletes the partial file.
 */
class VideoExporter(
    private val context: Context,
    private val store: ExportStore,
    private val gallery: GallerySaver,
) {
    private val main = Handler(Looper.getMainLooper())

    /** [progress] gets (0…1, stage) with stage encode or save. */
    suspend fun export(request: VideoExportRequest, progress: (Double, String) -> Unit): ExportResult {
        VideoExportPlanner.validate(request)
        val settings = DevelopSettings.from(request.params)
        // A clip without sound can't keep its (missing) audio track.
        val hasAudio = withContext(Dispatchers.IO) { MediaLoader(context).videoInfo(Uri.parse(request.uri)).hasAudio }
        val job = request.copy(includeAudio = request.includeAudio && hasAudio)
        val file = store.newFile(VideoExportPlanner.fileName(request.fileName))
        try {
            progress(0.0, STAGE_ENCODE)
            val result = withContext(Dispatchers.Main) { transform(job, settings, file, progress) }
            progress(SAVE_START, STAGE_SAVE)
            val mediaUri = withContext(Dispatchers.IO) {
                gallery.save(file, file.name, VideoExportPlanner.MIME_TYPE, GalleryCollection.VIDEOS)
            }
            progress(1.0, STAGE_SAVE)
            return ExportResult(
                mediaUri = mediaUri.toString(),
                filePath = file.absolutePath,
                width = result.width.toLong(),
                height = result.height.toLong(),
                bytes = file.length(),
                durationMs = result.approximateDurationMs.takeIf { it > 0 },
            )
        } catch (e: Throwable) {
            file.delete()
            throw e
        }
    }

    private suspend fun transform(
        request: VideoExportRequest,
        settings: DevelopSettings,
        file: File,
        progress: (Double, String) -> Unit,
    ): androidx.media3.transformer.ExportResult = coroutineScope {
        val clipping = MediaItem.ClippingConfiguration.Builder()
            .setStartPositionMs(request.trimStartMs)
            .setEndPositionMs(request.trimEndMs)
            .build()
        val item = MediaItem.Builder()
            .setUri(Uri.parse(request.uri))
            .setClippingConfiguration(clipping)
            .build()
        val effects = buildList<Effect> {
            add(DevelopEffect(settings, request.outputWidth.toInt(), request.outputHeight.toInt(), request.trimStartMs))
            if (request.layers.isNotEmpty()) add(LayerEffect(request.layers, request.trimStartMs))
        }
        val edited = EditedMediaItem.Builder(item)
            .setRemoveAudio(!request.includeAudio)
            .setEffects(Effects(emptyList(), effects))
            .build()
        // Videos without sound are sent with includeAudio = false (Dart).
        val sequence = if (request.includeAudio) {
            EditedMediaItemSequence.withAudioAndVideoFrom(listOf(edited))
        } else {
            EditedMediaItemSequence.withVideoFrom(listOf(edited))
        }
        val composition = Composition.Builder(sequence)
            .setHdrMode(Composition.HDR_MODE_TONE_MAP_HDR_TO_SDR_USING_OPEN_GL)
            .build()
        val encoders = DefaultEncoderFactory.Builder(context)
            .setRequestedVideoEncoderSettings(
                VideoEncoderSettings.Builder().setBitrate(request.videoBitrate.toInt()).build(),
            )
            .setEnableFallback(true)
            .build()

        val poll = launch {
            val holder = ProgressHolder()
            while (isActive) {
                delay(PROGRESS_MS)
                val transformer = current ?: continue
                if (transformer.getProgress(holder) == Transformer.PROGRESS_STATE_AVAILABLE) {
                    progress(holder.progress / 100.0 * SAVE_START, STAGE_ENCODE)
                }
            }
        }
        try {
            suspendCancellableCoroutine { cont ->
                val transformer = Transformer.Builder(context)
                    .setVideoMimeType(MimeTypes.VIDEO_H264)
                    .setAudioMimeType(MimeTypes.AUDIO_AAC)
                    .setEncoderFactory(encoders)
                    .setLooper(Looper.getMainLooper())
                    .addListener(object : Transformer.Listener {
                        override fun onCompleted(
                            composition: Composition,
                            exportResult: androidx.media3.transformer.ExportResult,
                        ) {
                            current = null
                            cont.resume(exportResult)
                        }

                        override fun onError(
                            composition: Composition,
                            exportResult: androidx.media3.transformer.ExportResult,
                            exportException: ExportException,
                        ) {
                            current = null
                            cont.resumeWithException(
                                FlutterError(
                                    errorCode(exportException.errorCode, exportException.cause?.message),
                                    exportException.message,
                                ),
                            )
                        }
                    })
                    .build()
                current = transformer
                cont.invokeOnCancellation {
                    main.post {
                        transformer.cancel()
                        current = null
                    }
                }
                transformer.start(composition, file.absolutePath)
            }
        } finally {
            poll.cancel()
        }
    }

    /** Platform thread only: the running Transformer, for progress. */
    @Volatile private var current: Transformer? = null

    companion object {
        const val STAGE_ENCODE = "encode"
        const val STAGE_SAVE = "save"
        private const val SAVE_START = 0.95
        private const val PROGRESS_MS = 200L

        /** Maps a Transformer [ExportException] code to an engine error code. */
        fun errorCode(code: Int, causeMessage: String?): String = when {
            causeMessage?.contains("ENOSPC") == true || causeMessage?.contains("No space") == true ->
                EngineErrors.STORAGE_FULL
            code == ExportException.ERROR_CODE_IO_FILE_NOT_FOUND ||
                code == ExportException.ERROR_CODE_IO_NO_PERMISSION -> EngineErrors.MEDIA_UNAVAILABLE
            code == ExportException.ERROR_CODE_DECODER_INIT_FAILED ||
                code == ExportException.ERROR_CODE_DECODING_FAILED ||
                code == ExportException.ERROR_CODE_DECODING_FORMAT_UNSUPPORTED -> EngineErrors.DECODE_FAILED
            else -> EngineErrors.EXPORT_FAILED
        }
    }
}
