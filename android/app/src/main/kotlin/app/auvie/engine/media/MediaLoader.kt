package app.auvie.engine.media

import android.content.ContentResolver
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.ColorSpace
import android.graphics.ImageDecoder
import android.media.ExifInterface
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.util.Size
import android.webkit.MimeTypeMap
import app.auvie.engine.pigeon.MediaKind
import app.auvie.engine.pigeon.PickedMedia
import java.io.ByteArrayOutputStream
import java.io.FileNotFoundException

/** A decoded photo and the size of the full-resolution original. */
class DecodedPhoto(val bitmap: Bitmap, val fullSize: PixelSize)

/** What the video editor needs to know about a clip. [size] is upright. */
class VideoInfo(val size: PixelSize, val durationMs: Long, val hasAudio: Boolean)

/** Reads the user's media. Blocking: call from an IO thread. */
class MediaLoader(private val context: android.content.Context) {
    private val resolver: ContentResolver get() = context.contentResolver

    fun kindOf(uri: Uri): MediaKind {
        val type = resolver.getType(uri)
            ?: MimeTypeMap.getSingleton().getMimeTypeFromExtension(
                MimeTypeMap.getFileExtensionFromUrl(uri.toString()),
            )
        return if (type?.startsWith("video/") == true) MediaKind.VIDEO else MediaKind.PHOTO
    }

    fun probe(uri: Uri): PickedMedia = when (kindOf(uri)) {
        MediaKind.PHOTO -> {
            val size = photoSize(uri)
            PickedMedia(uri.toString(), MediaKind.PHOTO, size.width.toLong(), size.height.toLong())
        }
        MediaKind.VIDEO -> withRetriever(uri) { r ->
            fun meta(key: Int) = r.extractMetadata(key)?.toIntOrNull() ?: 0
            val size = PixelSize(
                meta(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH),
                meta(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT),
            ).rotated(meta(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION))
            PickedMedia(
                uri.toString(), MediaKind.VIDEO, size.width.toLong(), size.height.toLong(),
                r.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)?.toLongOrNull(),
            )
        }
    }

    fun videoInfo(uri: Uri): VideoInfo = withRetriever(uri) { r ->
        fun meta(key: Int) = r.extractMetadata(key)?.toIntOrNull() ?: 0
        VideoInfo(
            PixelSize(
                meta(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH),
                meta(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT),
            ).rotated(meta(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION)),
            r.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)?.toLongOrNull() ?: 0,
            r.extractMetadata(MediaMetadataRetriever.METADATA_KEY_HAS_AUDIO) == "yes",
        )
    }

    /** The upright frame closest to [timeMs], longer side ≤ [maxPx], ARGB_8888. */
    fun videoFrame(uri: Uri, timeMs: Long, maxPx: Int): Bitmap = withRetriever(uri) { r ->
        frameAt(r, timeMs * 1000, maxPx, MediaMetadataRetriever.OPTION_CLOSEST)
    }

    /** [count] JPEG frames at the middle of equal slices of the video (FILM strip). */
    fun videoFrames(uri: Uri, count: Int, maxPx: Int): List<ByteArray> = withRetriever(uri) { r ->
        require(count in 1..MAX_FRAMES) { "count must be 1…$MAX_FRAMES, was $count" }
        val durationUs = (r.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)?.toLongOrNull() ?: 0) * 1000
        (0 until count).map { i ->
            val frame = frameAt(r, (durationUs * (2 * i + 1)) / (2 * count), maxPx, MediaMetadataRetriever.OPTION_CLOSEST_SYNC)
            try {
                jpeg(frame, THUMBNAIL_QUALITY)
            } finally {
                frame.recycle()
            }
        }
    }

    private fun frameAt(r: MediaMetadataRetriever, timeUs: Long, maxPx: Int, option: Int): Bitmap {
        val frame = r.getScaledFrameAtTime(timeUs, option, maxPx, maxPx)
            ?: throw java.io.IOException("No frame at ${timeUs}us")
        if (frame.config == Bitmap.Config.ARGB_8888) return frame
        return frame.copy(Bitmap.Config.ARGB_8888, false).also { frame.recycle() }
    }

    /** Decodes with EXIF rotation applied, longer side ≤ [maxPx], in sRGB. */
    fun decodePhoto(uri: Uri, maxPx: Int): DecodedPhoto {
        var fullSize = PixelSize(0, 0)
        val bitmap = ImageDecoder.decodeBitmap(ImageDecoder.createSource(resolver, uri)) { decoder, info, _ ->
            fullSize = PixelSize(info.size.width, info.size.height)
            val target = fullSize.fitWithin(maxPx)
            decoder.setTargetSize(target.width, target.height)
            decoder.allocator = ImageDecoder.ALLOCATOR_SOFTWARE
            decoder.setTargetColorSpace(ColorSpace.get(ColorSpace.Named.SRGB))
        }
        val opaque = if (bitmap.config == Bitmap.Config.ARGB_8888) bitmap else {
            bitmap.copy(Bitmap.Config.ARGB_8888, false).also { bitmap.recycle() }
        }
        return DecodedPhoto(opaque, fullSize)
    }

    /** JPEG thumbnail, longer side ≤ [maxPx]. */
    fun thumbnail(uri: Uri, maxPx: Int): ByteArray {
        // The system thumbnail cache only serves content:// URIs; file://
        // copies (see MediaPicker.persist) are decoded directly.
        val bitmap = if (uri.scheme == ContentResolver.SCHEME_CONTENT) {
            try {
                resolver.loadThumbnail(uri, Size(maxPx, maxPx), null)
            } catch (e: Exception) {
                if (e is SecurityException || e is FileNotFoundException) throw e
                decodeThumbnail(uri, maxPx) // Providers without thumbnail support.
            }
        } else {
            decodeThumbnail(uri, maxPx)
        }
        return try {
            jpeg(bitmap)
        } finally {
            bitmap.recycle()
        }
    }

    private fun decodeThumbnail(uri: Uri, maxPx: Int): Bitmap = when (kindOf(uri)) {
        MediaKind.PHOTO -> decodePhoto(uri, maxPx).bitmap
        MediaKind.VIDEO -> withRetriever(uri) { r ->
            r.getScaledFrameAtTime(0, MediaMetadataRetriever.OPTION_CLOSEST_SYNC, maxPx, maxPx)
        } ?: throw java.io.IOException("No frame in $uri")
    }

    private fun photoSize(uri: Uri): PixelSize {
        val options = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        val stream = resolver.openInputStream(uri) ?: throw FileNotFoundException(uri.toString())
        stream.use { BitmapFactory.decodeStream(it, null, options) }
        if (options.outWidth <= 0) throw java.io.IOException("Not an image: $uri")
        val orientation = resolver.openInputStream(uri)?.use {
            ExifInterface(it).getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL)
        } ?: ExifInterface.ORIENTATION_NORMAL
        return PixelSize(options.outWidth, options.outHeight).rotated(rotationOf(orientation))
    }

    private fun <T> withRetriever(uri: Uri, block: (MediaMetadataRetriever) -> T): T {
        val retriever = MediaMetadataRetriever()
        return try {
            retriever.setDataSource(context, uri)
            block(retriever)
        } catch (e: RuntimeException) {
            if (e is SecurityException) throw e
            throw java.io.IOException("Could not read video $uri: ${e.message}", e)
        } finally {
            retriever.release()
        }
    }

    companion object {
        const val JPEG_QUALITY = 88
        const val THUMBNAIL_QUALITY = 75
        const val MAX_FRAMES = 60

        /** Degrees an EXIF orientation turns the image (transposes count as 90). */
        fun rotationOf(exifOrientation: Int): Int = when (exifOrientation) {
            ExifInterface.ORIENTATION_ROTATE_90,
            ExifInterface.ORIENTATION_TRANSPOSE,
            ExifInterface.ORIENTATION_ROTATE_270,
            ExifInterface.ORIENTATION_TRANSVERSE -> 90
            ExifInterface.ORIENTATION_ROTATE_180 -> 180
            else -> 0
        }

        fun jpeg(bitmap: Bitmap, quality: Int = JPEG_QUALITY): ByteArray =
            ByteArrayOutputStream().use {
                bitmap.compress(Bitmap.CompressFormat.JPEG, quality, it)
                it.toByteArray()
            }
    }
}
