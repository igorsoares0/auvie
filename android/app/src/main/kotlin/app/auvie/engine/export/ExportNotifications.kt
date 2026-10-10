package app.auvie.engine.export

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.pm.ServiceInfo
import android.os.Build
import androidx.work.ForegroundInfo
import app.auvie.R
import kotlin.math.roundToInt

/** The "Exports" channel and the progress notification of a video export. */
class ExportNotifications(private val context: Context) {
    private val manager = context.getSystemService(NotificationManager::class.java)

    init {
        manager.createNotificationChannel(
            NotificationChannel(CHANNEL, "Exports", NotificationManager.IMPORTANCE_LOW).apply {
                description = "Progress of video exports"
            },
        )
    }

    /** "Exporting Film 012 · 42%", with CANCEL. */
    fun progress(notificationId: Int, title: String, fraction: Double, cancel: PendingIntent): ForegroundInfo {
        val percent = (fraction * 100).roundToInt().coerceIn(0, 100)
        val notification = Notification.Builder(context, CHANNEL)
            .setSmallIcon(R.drawable.ic_stat_export)
            .setContentTitle("Exporting $title · $percent%")
            .setProgress(100, percent, false)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setCategory(Notification.CATEGORY_PROGRESS)
            .addAction(Notification.Action.Builder(null, "CANCEL", cancel).build())
            .build()
        val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.VANILLA_ICE_CREAM) {
            ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROCESSING
        } else {
            ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC
        }
        return ForegroundInfo(notificationId, notification, type)
    }

    companion object {
        const val CHANNEL = "exports"
    }
}
