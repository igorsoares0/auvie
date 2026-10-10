package app.auvie.engine

import android.graphics.Bitmap
import android.graphics.Color
import android.media.MediaExtractor
import android.media.MediaFormat
import android.media.MediaMetadataRetriever
import android.net.Uri
import androidx.test.platform.app.InstrumentationRegistry
import java.io.File

/** Clips from src/androidTest/assets (made with ffmpeg, see each name). */
object VideoFixtures {
    private val target get() = InstrumentationRegistry.getInstrumentation().targetContext

    /** 640×360, 30 fps, 3 s, mid gray (128), with a 440 Hz tone. */
    const val CLIP = "clip_3s.mp4"

    /** 640×360, 2 s, mid gray, no sound. */
    const val SILENT = "clip_silent.mp4"

    /** 640×360 stored, white left half / black right half, rotated 90°: 360×640 upright. */
    const val ROTATED = "clip_rot90.mp4"

    /** Copies [name] out of the test APK into the app's cache. */
    fun uri(name: String): Uri {
        val file = File(target.cacheDir, "fixtures/$name")
        if (!file.exists()) {
            file.parentFile!!.mkdirs()
            InstrumentationRegistry.getInstrumentation().context.assets.open(name).use { input ->
                file.outputStream().use { input.copyTo(it) }
            }
        }
        return Uri.fromFile(file)
    }

    fun hasAudioTrack(path: String): Boolean {
        val extractor = MediaExtractor()
        return try {
            extractor.setDataSource(path)
            (0 until extractor.trackCount).any {
                extractor.getTrackFormat(it).getString(MediaFormat.KEY_MIME)!!.startsWith("audio/")
            }
        } finally {
            extractor.release()
        }
    }

    /** Duration, upright size and frames of an exported file. */
    class Probe(path: String) : AutoCloseable {
        private val retriever = MediaMetadataRetriever().apply { setDataSource(path) }

        private fun meta(key: Int) = retriever.extractMetadata(key)!!.toInt()

        val durationMs: Int get() = meta(MediaMetadataRetriever.METADATA_KEY_DURATION)

        val size: Pair<Int, Int>
            get() {
                val w = meta(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH)
                val h = meta(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT)
                val rotation = meta(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION)
                return if (rotation % 180 != 0) h to w else w to h
            }

        val frameCount: Int get() = meta(MediaMetadataRetriever.METADATA_KEY_VIDEO_FRAME_COUNT)

        /** The upright frame closest to [ms]. */
        fun frame(ms: Long): Bitmap =
            retriever.getFrameAtTime(ms * 1000, MediaMetadataRetriever.OPTION_CLOSEST)!!

        override fun close() = retriever.release()
    }

    fun isRed(color: Int) = Color.red(color) > 200 && Color.green(color) < 70 && Color.blue(color) < 70
}
