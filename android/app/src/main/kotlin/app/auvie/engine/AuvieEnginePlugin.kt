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
import app.auvie.engine.gl.GlEngine
import app.auvie.engine.media.MediaLoader
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
import app.auvie.engine.pigeon.PreviewInfo
import app.auvie.engine.picker.MediaPicker
import app.auvie.engine.preview.PhotoPreview
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
    private lateinit var engine: GlEngine
    private lateinit var context: Context
    private lateinit var exporter: PhotoExporter
    private lateinit var store: ExportStore
    private var activityBinding: ActivityPluginBinding? = null
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
    private val main = Handler(Looper.getMainLooper())

    /** Platform thread only. */
    private val previews = HashMap<Long, PhotoPreview>()

    /** Running exports, by job id. Platform thread only. */
    private val exports = HashMap<String, Job>()
    private var progressSink: PigeonEventSink<ExportProgress>? = null

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
        engine = GlEngine(context.assets)
        this.context = context
        store = ExportStore(context)
        exporter = PhotoExporter(
            engine, loader, store, GallerySaver(context.contentResolver),
            MetadataCopier(context.contentResolver),
        )
        MediaHostApi.setUp(messenger, this)
        ExportProgressStreamHandler.register(messenger, progressHandler)
        scope.launch(Dispatchers.IO) { store.clean() }
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
        binding.addActivityResultListener(picker)
    }

    override fun onDetachedFromActivity() {
        activityBinding?.removeActivityResultListener(picker)
        activityBinding = null
        picker.activity = null
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

    override fun cancelExport(jobId: String) {
        exports[jobId]?.cancel()
    }

    override suspend fun copyToClipboard(mediaUri: String) {
        val clipboard = context.getSystemService(ClipboardManager::class.java)
        clipboard.setPrimaryClip(ClipData.newUri(context.contentResolver, "Auvie", Uri.parse(mediaUri)))
    }

    override suspend fun renderPhoto(uri: String, params: DevelopParams, maxPx: Long): ByteArray =
        EngineErrors.mapping(uri) {
            val settings = DevelopSettings.from(params)
            val decoded = withContext(Dispatchers.IO) { loader.decodePhoto(Uri.parse(uri), maxPx.toInt()) }
            val size = Geometry.outputSize(
                settings.geometry, decoded.bitmap.width, decoded.bitmap.height, maxPx.toInt(),
            )
            val developed = try {
                engine.thread.call {
                    engine.renderToBitmap(decoded.bitmap, settings, size.width, size.height)
                }
            } finally {
                decoded.bitmap.recycle()
            }
            withContext(Dispatchers.IO) {
                try {
                    MediaLoader.jpeg(developed)
                } finally {
                    developed.recycle()
                }
            }
        }

    private fun preview(textureId: Long): PhotoPreview =
        previews[textureId] ?: throw FlutterError(EngineErrors.UNKNOWN_TEXTURE, "No preview $textureId")
}
