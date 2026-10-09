package app.auvie.engine.export

import android.content.ContentResolver
import android.net.Uri
import androidx.exifinterface.media.ExifInterface
import java.io.File

/**
 * "Keep location & camera data": copies capture metadata from the original
 * into an exported JPEG. Without it, exports carry no EXIF at all.
 */
class MetadataCopier(private val resolver: ContentResolver) {
    /** Blocking. Pixels are already upright, so orientation is "normal". */
    fun copy(source: Uri, target: File) {
        val out = ExifInterface(target.absolutePath)
        resolver.openInputStream(source)?.use { stream ->
            val original = ExifInterface(stream)
            for (tag in TAGS) original.getAttribute(tag)?.let { out.setAttribute(tag, it) }
        }
        out.setAttribute(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL.toString())
        out.saveAttributes()
    }

    companion object {
        val TAGS = listOf(
            ExifInterface.TAG_DATETIME_ORIGINAL,
            ExifInterface.TAG_DATETIME_DIGITIZED,
            ExifInterface.TAG_OFFSET_TIME_ORIGINAL,
            ExifInterface.TAG_MAKE,
            ExifInterface.TAG_MODEL,
            ExifInterface.TAG_LENS_MAKE,
            ExifInterface.TAG_LENS_MODEL,
            ExifInterface.TAG_F_NUMBER,
            ExifInterface.TAG_EXPOSURE_TIME,
            ExifInterface.TAG_PHOTOGRAPHIC_SENSITIVITY,
            ExifInterface.TAG_FOCAL_LENGTH,
            ExifInterface.TAG_FOCAL_LENGTH_IN_35MM_FILM,
            ExifInterface.TAG_GPS_LATITUDE,
            ExifInterface.TAG_GPS_LATITUDE_REF,
            ExifInterface.TAG_GPS_LONGITUDE,
            ExifInterface.TAG_GPS_LONGITUDE_REF,
            ExifInterface.TAG_GPS_ALTITUDE,
            ExifInterface.TAG_GPS_ALTITUDE_REF,
            ExifInterface.TAG_GPS_TIMESTAMP,
            ExifInterface.TAG_GPS_DATESTAMP,
        )
    }
}
