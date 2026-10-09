package app.auvie.engine.export

import android.content.ContentResolver
import android.content.ContentValues
import android.net.Uri
import android.provider.MediaStore
import java.io.File
import java.io.IOException

/** Saves into Pictures/Auvie through MediaStore: no storage permission. */
class GallerySaver(private val resolver: ContentResolver) {
    /**
     * Blocking. The row stays pending (hidden) until the copy is complete,
     * and is removed if anything fails.
     */
    fun save(file: File, displayName: String, mimeType: String): Uri {
        val values = ContentValues().apply {
            put(MediaStore.Images.Media.DISPLAY_NAME, displayName)
            put(MediaStore.Images.Media.MIME_TYPE, mimeType)
            put(MediaStore.Images.Media.RELATIVE_PATH, RELATIVE_PATH)
            put(MediaStore.Images.Media.IS_PENDING, 1)
        }
        val collection = MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
        val uri = resolver.insert(collection, values) ?: throw IOException("MediaStore insert failed")
        try {
            val out = resolver.openOutputStream(uri) ?: throw IOException("Cannot write $uri")
            out.use { stream -> file.inputStream().use { it.copyTo(stream) } }
            resolver.update(
                uri,
                ContentValues().apply { put(MediaStore.Images.Media.IS_PENDING, 0) },
                null,
                null,
            )
            return uri
        } catch (e: Throwable) {
            resolver.delete(uri, null, null)
            throw e
        }
    }

    companion object {
        const val RELATIVE_PATH = "Pictures/Auvie"
    }
}
