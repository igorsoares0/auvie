package app.auvie.engine.picker

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.plugin.common.PluginRegistry
import kotlin.coroutines.resume
import kotlinx.coroutines.CancellableContinuation
import kotlinx.coroutines.suspendCancellableCoroutine

/** Asks to post notifications (Android 13+), for the video export progress. */
class NotificationPermission(private val context: Context) : PluginRegistry.RequestPermissionsResultListener {
    var activity: Activity? = null
    private var pending: CancellableContinuation<Boolean>? = null

    val granted: Boolean
        get() = Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
            context.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED

    /** Platform thread. True when notifications are allowed. */
    suspend fun request(): Boolean {
        if (granted || Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return granted
        val activity = activity ?: return false
        if (pending != null) return false
        return suspendCancellableCoroutine { cont ->
            pending = cont
            cont.invokeOnCancellation { pending = null }
            activity.requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), REQUEST_CODE)
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ): Boolean {
        if (requestCode != REQUEST_CODE) return false
        val cont = pending ?: return true
        pending = null
        cont.resume(grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED)
        return true
    }

    companion object {
        private const val REQUEST_CODE = 0x4176
    }
}
