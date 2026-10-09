package app.auvie.engine.export

import android.content.Context
import java.io.File

/**
 * App-private copies of exports (`files/exports/`), kept for sharing and
 * cleaned after a day.
 */
class ExportStore(context: Context) {
    val directory = File(context.filesDir, "exports")

    fun newFile(name: String): File {
        directory.mkdirs()
        var file = File(directory, name)
        var n = 2
        while (file.exists()) {
            file = File(directory, "${name.substringBeforeLast('.')}-$n.${name.substringAfterLast('.')}")
            n++
        }
        return file
    }

    /** Deletes copies older than [maxAgeMs]. Blocking. */
    fun clean(maxAgeMs: Long = DAY_MS, now: Long = System.currentTimeMillis()) {
        directory.listFiles()?.forEach { if (now - it.lastModified() > maxAgeMs) it.delete() }
    }

    companion object {
        const val DAY_MS = 24L * 60 * 60 * 1000
    }
}
