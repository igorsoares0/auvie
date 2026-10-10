package app.auvie.engine.export

import android.content.ContentResolver
import android.content.ContentValues
import android.net.Uri
import android.provider.MediaStore
import java.io.File
import java.io.IOException

/** Where exports go in the gallery. */
enum class GalleryCollection(val relativePath: String) {
    IMAGES("Pictures/Auvie"),
    VIDEOS("Movies/Auvie"),
    ;

    val contentUri: Uri
        get() = when (this) {
            IMAGES -> MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
            VIDEOS -> MediaStore.Video.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
        }
}

/** Saves into Pictures/Auvie or Movies/Auvie through MediaStore: no storage permission. */
class GallerySaver(private val resolver: ContentResolver) {
    /**
     * Blocking. The row stays pending (hidden) until the copy is complete,
     * and is removed if anything fails.
     */
    fun save(
        file: File,
        displayName: String,
        mimeType: String,
        collection: GalleryCollection = GalleryCollection.IMAGES,
    ): Uri {
        val values = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, displayName)
            put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
            put(MediaStore.MediaColumns.RELATIVE_PATH, collection.relativePath)
            put(MediaStore.MediaColumns.IS_PENDING, 1)
        }
        val uri = resolver.insert(collection.contentUri, values) ?: throw IOException("MediaStore insert failed")
        try {
            val out = resolver.openOutputStream(uri) ?: throw IOException("Cannot write $uri")
            out.use { stream -> file.inputStream().use { it.copyTo(stream) } }
            resolver.update(
                uri,
                ContentValues().apply { put(MediaStore.MediaColumns.IS_PENDING, 0) },
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
        val RELATIVE_PATH = GalleryCollection.IMAGES.relativePath
    }
}
