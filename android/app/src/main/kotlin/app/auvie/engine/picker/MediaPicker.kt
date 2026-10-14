package app.auvie.engine.picker

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.webkit.MimeTypeMap
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts.PickVisualMedia
import app.auvie.engine.EngineErrors
import app.auvie.engine.pigeon.FlutterError
import app.auvie.engine.pigeon.MediaKind
import io.flutter.plugin.common.PluginRegistry
import java.io.File
import java.util.UUID
import kotlin.coroutines.resume
import kotlinx.coroutines.CancellableContinuation
import kotlinx.coroutines.suspendCancellableCoroutine

/**
 * The Android Photo Picker (no storage permission needed). FlutterActivity
 * is not a ComponentActivity, so the contract's intent is started with
 * startActivityForResult and the result arrives through [onActivityResult].
 */
class MediaPicker(private val context: Context) : PluginRegistry.ActivityResultListener {
    var activity: Activity? = null
    private var pending: CancellableContinuation<Uri?>? = null

    /** Platform thread. Returns null when the user cancels. */
    suspend fun pick(kind: MediaKind): Uri? {
        val activity = activity ?: throw FlutterError(EngineErrors.NO_ACTIVITY, "No activity attached")
        if (pending != null) throw FlutterError(EngineErrors.PICKER_BUSY, "Picker already open")

        val type = when (kind) {
            MediaKind.PHOTO -> PickVisualMedia.ImageOnly
            MediaKind.VIDEO -> PickVisualMedia.VideoOnly
        }
        val request = PickVisualMediaRequest.Builder().setMediaType(type).build()
        val intent = PickVisualMedia().createIntent(activity, request)

        return suspendCancellableCoroutine { cont ->
            pending = cont
            cont.invokeOnCancellation { pending = null }
            activity.startActivityForResult(intent, REQUEST_CODE)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != REQUEST_CODE) return false
        val cont = pending ?: return true
        pending = null
        cont.resume(if (resultCode == Activity.RESULT_OK) data?.data else null)
        return true
    }

    /**
     * Keeps read access across restarts. If the provider doesn't allow it,
     * copies the media into app storage (`files/projects/media/`) instead.
     * Blocking: call from an IO thread.
     */
    fun persist(uri: Uri): Uri = try {
        context.contentResolver.takePersistableUriPermission(uri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
        uri
    } catch (e: SecurityException) {
        copyToAppStorage(uri)
    }

    /**
     * Undoes [persist] for a project that is gone: releases the read
     * permission, or deletes the private copy. Blocking: call from IO.
     */
    fun release(uri: Uri) {
        when (uri.scheme) {
            "content" -> try {
                context.contentResolver.releasePersistableUriPermission(uri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
            } catch (e: SecurityException) {
                // Never held, or already released.
            }
            "file" -> {
                val file = File(uri.path ?: return)
                if (isPrivateCopy(file, mediaDir)) file.delete()
            }
        }
    }

    private val mediaDir: File get() = File(context.filesDir, "projects/media")

    private fun copyToAppStorage(uri: Uri): Uri {
        val resolver = context.contentResolver
        val extension = MimeTypeMap.getSingleton().getExtensionFromMimeType(resolver.getType(uri)) ?: "bin"
        val dir = mediaDir.apply { mkdirs() }
        val file = File(dir, "${UUID.randomUUID()}.$extension")
        val input = resolver.openInputStream(uri) ?: throw java.io.FileNotFoundException(uri.toString())
        input.use { source -> file.outputStream().use { source.copyTo(it) } }
        return Uri.fromFile(file)
    }

    companion object {
        private const val REQUEST_CODE = 0x4175 // "Au"

        /** Only files the app copied itself may be deleted. */
        fun isPrivateCopy(file: File, mediaDir: File): Boolean =
            file.canonicalFile.parentFile == mediaDir.canonicalFile
    }
}
