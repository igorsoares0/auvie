package app.auvie.engine

import android.net.Uri
import app.auvie.engine.develop.DevelopSettings
import app.auvie.engine.gl.GlEngine
import app.auvie.engine.media.MediaLoader
import app.auvie.engine.pigeon.DevelopParams
import app.auvie.engine.pigeon.FlutterError
import app.auvie.engine.pigeon.MediaHostApi
import app.auvie.engine.pigeon.MediaKind
import app.auvie.engine.pigeon.PickedMedia
import app.auvie.engine.pigeon.PreviewInfo
import app.auvie.engine.picker.MediaPicker
import app.auvie.engine.preview.PhotoPreview
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.view.TextureRegistry
import kotlinx.coroutines.Dispatchers
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
    private var activityBinding: ActivityPluginBinding? = null

    /** Platform thread only. */
    private val previews = HashMap<Long, PhotoPreview>()

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val context = binding.applicationContext
        messenger = binding.binaryMessenger
        textures = binding.textureRegistry
        loader = MediaLoader(context)
        picker = MediaPicker(context)
        engine = GlEngine(context.assets)
        MediaHostApi.setUp(messenger, this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        MediaHostApi.setUp(messenger, null)
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

    override suspend fun renderPhoto(uri: String, params: DevelopParams, maxPx: Long): ByteArray =
        EngineErrors.mapping(uri) {
            val settings = DevelopSettings.from(params)
            val decoded = withContext(Dispatchers.IO) { loader.decodePhoto(Uri.parse(uri), maxPx.toInt()) }
            val developed = try {
                engine.thread.call { engine.renderToBitmap(decoded.bitmap, settings) }
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
