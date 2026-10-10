package app.auvie.engine

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.os.storage.StorageManager
import app.auvie.engine.develop.DevelopSettings
import app.auvie.engine.develop.Geometry
import app.auvie.engine.export.ExportStore
import app.auvie.engine.export.GallerySaver
import app.auvie.engine.export.MetadataCopier
import app.auvie.engine.export.PhotoExporter
import app.auvie.engine.export.VideoExportBus
import app.auvie.engine.export.VideoExportPlanner
import app.auvie.engine.export.VideoExportWorker
import app.auvie.engine.gl.GlEngine
import app.auvie.engine.media.MediaLoader
import app.auvie.engine.media.WaveformReader
import app.auvie.engine.pigeon.DevelopParams
import app.auvie.engine.pigeon.ExportProgress
import app.auvie.engine.pigeon.ExportProgressStreamHandler
import app.auvie.engine.pigeon.ExportRequest
import app.auvie.engine.pigeon.ExportResult
import app.auvie.engine.pigeon.FlutterError
import app.auvie.engine.pigeon.MediaHostApi
import app.auvie.engine.pigeon.MediaKind
import app.auvie.engine.pigeon.PickedMedia
import app.auvie.engine.pigeon.PigeonEventSink
import app.auvie.engine.pigeon.PlaybackState
import app.auvie.engine.pigeon.PlaybackStateStreamHandler
import app.auvie.engine.pigeon.PreviewInfo
import app.auvie.engine.pigeon.VideoExportRequest
import app.auvie.engine.pigeon.VideoPreviewInfo
import app.auvie.engine.picker.MediaPicker
import app.auvie.engine.picker.NotificationPermission
import app.auvie.engine.preview.PhotoPreview
import app.auvie.engine.preview.Preview
import app.auvie.engine.preview.VideoPreview
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkInfo
import androidx.work.WorkManager
import androidx.work.workDataOf
import java.io.File
import java.util.UUID
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.view.TextureRegistry
import kotlin.coroutines.cancellation.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.currentCoroutineContext
import kotlinx.coroutines.flow.filter
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.job
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/**
 * The media engine behind `MediaHostApi`. Pigeon calls arrive on the
 * platform thread; decoding runs on IO and GL work on the GL thread.
 */
class AuvieEnginePlugin : FlutterPlugin, ActivityAware, MediaHostApi {
    private lateinit var messenger: BinaryMessenger
    private lateinit var textures: TextureRegistry
    private lateinit var loader: MediaLoader
    private lateinit var picker: MediaPicker
    private lateinit var notifications: NotificationPermission
    private lateinit var waveforms: WaveformReader
    private lateinit var engine: GlEngine
    private lateinit var context: Context
    private lateinit var exporter: PhotoExporter
    private lateinit var store: ExportStore
    private var activityBinding: ActivityPluginBinding? = null
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
    private val main = Handler(Looper.getMainLooper())

    /** Photo and video previews, by texture id. Platform thread only. */
    private val previews = HashMap<Long, Preview>()

    /** Running photo exports, by job id. Platform thread only. */
    private val exports = HashMap<String, Job>()

    /** Running video exports (WorkManager), by job id. Platform thread only. */
    private val videoExports = HashMap<String, UUID>()
    private var progressSink: PigeonEventSink<ExportProgress>? = null
    private var playbackSink: PigeonEventSink<PlaybackState>? = null

    private val playbackHandler = object : PlaybackStateStreamHandler() {
        override fun onListen(p0: Any?, sink: PigeonEventSink<PlaybackState>) {
            playbackSink = sink
        }

        override fun onCancel(p0: Any?) {
            playbackSink = null
        }
    }

    private val progressHandler = object : ExportProgressStreamHandler() {
        override fun onListen(p0: Any?, sink: PigeonEventSink<ExportProgress>) {
            progressSink = sink
        }

        override fun onCancel(p0: Any?) {
            progressSink = null
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val context = binding.applicationContext
        messenger = binding.binaryMessenger
        textures = binding.textureRegistry
        loader = MediaLoader(context)
        picker = MediaPicker(context)
        notifications = NotificationPermission(context)
        waveforms = WaveformReader(context)
        engine = GlEngine(context.assets)
        this.context = context
        store = ExportStore(context)
        exporter = PhotoExporter(
            engine, loader, store, GallerySaver(context.contentResolver),
            MetadataCopier(context.contentResolver),
        )
        MediaHostApi.setUp(messenger, this)
        ExportProgressStreamHandler.register(messenger, progressHandler)
        PlaybackStateStreamHandler.register(messenger, playbackHandler)
        scope.launch(Dispatchers.IO) { store.clean() }
        scope.launch {
            VideoExportBus.progress.collect { progressSink?.success(it) }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        MediaHostApi.setUp(messenger, null)
        exports.values.forEach { it.cancel() }
        scope.cancel()
        previews.values.forEach { it.dispose() }
        previews.clear()
        engine.release()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
        picker.activity = binding.activity
        notifications.activity = binding.activity
        binding.addActivityResultListener(picker)
        binding.addRequestPermissionsResultListener(notifications)
    }

    override fun onDetachedFromActivity() {
        activityBinding?.removeActivityResultListener(picker)
        activityBinding?.removeRequestPermissionsResultListener(notifications)
        activityBinding = null
        picker.activity = null
        notifications.activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) =
        onAttachedToActivity(binding)

    override fun onDetachedFromActivityForConfigChanges() = onDetachedFromActivity()

    // MediaHostApi

    override suspend fun pickMedia(kind: MediaKind): PickedMedia? {
        val picked = picker.pick(kind) ?: return null
        return EngineErrors.mapping(picked.toString()) {
            withContext(Dispatchers.IO) { loader.probe(picker.persist(picked)) }
        }
    }

    override suspend fun probe(uri: String): PickedMedia = EngineErrors.mapping(uri) {
        withContext(Dispatchers.IO) { loader.probe(Uri.parse(uri)) }
    }

    override suspend fun thumbnail(uri: String, maxPx: Long): ByteArray = EngineErrors.mapping(uri) {
        withContext(Dispatchers.IO) { loader.thumbnail(Uri.parse(uri), maxPx.toInt()) }
    }

    override suspend fun createPhotoPreview(uri: String, maxPx: Long): PreviewInfo = EngineErrors.mapping(uri) {
        val decoded = withContext(Dispatchers.IO) { loader.decodePhoto(Uri.parse(uri), maxPx.toInt()) }
        val preview = try {
            PhotoPreview.create(textures.createSurfaceProducer(), engine, decoded.bitmap)
        } finally {
            decoded.bitmap.recycle()
        }
        previews[preview.id] = preview
        PreviewInfo(preview.id, preview.width.toLong(), preview.height.toLong())
    }

    override suspend fun createVideoPreview(uri: String, maxPx: Long): VideoPreviewInfo = EngineErrors.mapping(uri) {
        val parsed = Uri.parse(uri)
        val info = withContext(Dispatchers.IO) { loader.videoInfo(parsed) }
        if (info.size.width <= 0 || info.durationMs <= 0) {
            throw FlutterError(EngineErrors.DECODE_FAILED, "Not a playable video: $uri")
        }
        val preview = VideoPreview.create(
            context, textures.createSurfaceProducer(), engine, parsed, info, maxPx.toInt(),
        ) { state -> playbackSink?.success(state) }
        previews[preview.id] = preview
        VideoPreviewInfo(
            preview.id, info.size.width.toLong(), info.size.height.toLong(), info.durationMs, info.hasAudio,
        )
    }

    override fun playVideo(textureId: Long) = video(textureId).play()

    override fun pauseVideo(textureId: Long) = video(textureId).pause()

    override fun seekVideo(textureId: Long, positionMs: Long, exact: Boolean) =
        video(textureId).seek(positionMs, exact)

    override fun setPlaybackRange(textureId: Long, startMs: Long, endMs: Long) {
        try {
            video(textureId).setRange(startMs, endMs)
        } catch (e: IllegalArgumentException) {
            throw FlutterError(EngineErrors.INVALID_PARAMS, e.message)
        }
    }

    override fun setVideoMuted(textureId: Long, muted: Boolean) = video(textureId).setMuted(muted)

    override suspend fun videoFrames(uri: String, count: Long, maxPx: Long): List<ByteArray> =
        EngineErrors.mapping(uri) {
            withContext(Dispatchers.IO) { loader.videoFrames(Uri.parse(uri), count.toInt(), maxPx.toInt()) }
        }

    override suspend fun waveform(uri: String, buckets: Long): DoubleArray? = EngineErrors.mapping(uri) {
        withContext(Dispatchers.Default) { waveforms.read(Uri.parse(uri), buckets.toInt()) }
    }

    override fun updateEdit(textureId: Long, params: DevelopParams) {
        val settings = try {
            DevelopSettings.from(params)
        } catch (e: IllegalArgumentException) {
            throw FlutterError(EngineErrors.INVALID_PARAMS, e.message)
        }
        preview(textureId).update(settings)
    }

    override fun setShowOriginal(textureId: Long, original: Boolean) =
        preview(textureId).setShowOriginal(original)

    override fun disposePreview(textureId: Long) {
        previews.remove(textureId)?.dispose()
    }

    override fun resizePreview(textureId: Long, width: Long, height: Long) {
        try {
            preview(textureId).resize(width.toInt(), height.toInt())
        } catch (e: IllegalArgumentException) {
            throw FlutterError(EngineErrors.INVALID_PARAMS, e.message)
        }
    }

    override fun availableBytes(): Long =
        context.getSystemService(StorageManager::class.java)
            .getAllocatableBytes(StorageManager.UUID_DEFAULT)

    override suspend fun exportPhoto(jobId: String, request: ExportRequest): ExportResult {
        exports[jobId] = currentCoroutineContext().job
        try {
            return EngineErrors.mapping(request.uri) {
                exporter.export(request) { fraction, stage ->
                    main.post { progressSink?.success(ExportProgress(jobId, fraction, stage)) }
                }
            }
        } catch (e: CancellationException) {
            throw FlutterError(EngineErrors.CANCELLED, "Export $jobId cancelled")
        } catch (e: FlutterError) {
            throw e
        } catch (e: Exception) {
            throw FlutterError(EngineErrors.EXPORT_FAILED, e.message)
        } finally {
            exports.remove(jobId)
        }
    }

    override suspend fun exportVideo(jobId: String, request: VideoExportRequest): ExportResult {
        try {
            VideoExportPlanner.validate(request)
        } catch (e: IllegalArgumentException) {
            throw FlutterError(EngineErrors.INVALID_PARAMS, e.message)
        }
        val jobFile = withContext(Dispatchers.IO) {
            File(context.cacheDir, "video-jobs").apply { mkdirs() }.resolve("$jobId.json").apply {
                writeText(VideoExportPlanner.toJson(request))
            }
        }
        val work = OneTimeWorkRequestBuilder<VideoExportWorker>()
            .setInputData(
                workDataOf(
                    VideoExportWorker.KEY_JOB_ID to jobId,
                    VideoExportWorker.KEY_JOB_FILE to jobFile.absolutePath,
                    VideoExportWorker.KEY_TITLE to request.fileName,
                ),
            )
            .addTag(VideoExportWorker.WORK_TAG)
            .build()
        val workManager = WorkManager.getInstance(context)
        videoExports[jobId] = work.id
        try {
            workManager.enqueueUniqueWork(jobId, ExistingWorkPolicy.KEEP, work)
            val info = workManager.getWorkInfoByIdFlow(work.id).filter { it?.state?.isFinished == true }.first()!!
            return when (info.state) {
                WorkInfo.State.SUCCEEDED -> VideoExportWorker.resultOf(info.outputData)
                WorkInfo.State.CANCELLED -> throw FlutterError(EngineErrors.CANCELLED, "Export $jobId cancelled")
                else -> throw FlutterError(
                    info.outputData.getString(VideoExportWorker.KEY_ERROR_CODE) ?: EngineErrors.EXPORT_FAILED,
                    info.outputData.getString(VideoExportWorker.KEY_ERROR_MESSAGE),
                )
            }
        } catch (e: CancellationException) {
            workManager.cancelWorkById(work.id)
            throw e
        } finally {
            videoExports.remove(jobId)
        }
    }

    override fun cancelExport(jobId: String) {
        exports[jobId]?.cancel()
        videoExports[jobId]?.let { WorkManager.getInstance(context).cancelWorkById(it) }
    }

    override suspend fun requestNotificationPermission(): Boolean = notifications.request()

    override suspend fun copyToClipboard(mediaUri: String) {
        val clipboard = context.getSystemService(ClipboardManager::class.java)
        clipboard.setPrimaryClip(ClipData.newUri(context.contentResolver, "Auvie", Uri.parse(mediaUri)))
    }

    override suspend fun renderFrame(uri: String, params: DevelopParams, maxPx: Long, timeMs: Long?): ByteArray =
        EngineErrors.mapping(uri) {
            val settings = DevelopSettings.from(params)
            val bitmap = withContext(Dispatchers.IO) {
                if (timeMs != null) {
                    loader.videoFrame(Uri.parse(uri), timeMs, maxPx.toInt())
                } else {
                    loader.decodePhoto(Uri.parse(uri), maxPx.toInt()).bitmap
                }
            }
            val size = Geometry.outputSize(settings.geometry, bitmap.width, bitmap.height, maxPx.toInt())
            val developed = try {
                engine.thread.call {
                    engine.renderToBitmap(bitmap, settings, size.width, size.height)
                }
            } finally {
                bitmap.recycle()
            }
            withContext(Dispatchers.IO) {
                try {
                    MediaLoader.jpeg(developed)
                } finally {
                    developed.recycle()
                }
            }
        }

    private fun preview(textureId: Long): Preview =
        previews[textureId] ?: throw FlutterError(EngineErrors.UNKNOWN_TEXTURE, "No preview $textureId")

    private fun video(textureId: Long): VideoPreview =
        previews[textureId] as? VideoPreview
            ?: throw FlutterError(EngineErrors.UNKNOWN_TEXTURE, "No video preview $textureId")
}
