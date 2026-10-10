package app.auvie.engine.media

import android.content.Context
import android.media.MediaCodec
import android.media.MediaExtractor
import android.media.MediaFormat
import android.net.Uri
import java.nio.ByteOrder
import kotlin.math.abs

/**
 * The SOUND lane's waveform: decodes the first audio track to PCM and keeps
 * the peak of each of `buckets` equal slices of the clip. Blocking.
 */
class WaveformReader(private val context: Context) {
    /** Peaks 0…1 (scaled so the loudest slice is 1), or null without sound. */
    fun read(uri: Uri, buckets: Int): DoubleArray? {
        require(buckets in 1..MAX_BUCKETS) { "buckets must be 1…$MAX_BUCKETS, was $buckets" }
        val extractor = MediaExtractor()
        try {
            extractor.setDataSource(context, uri, null)
            val track = (0 until extractor.trackCount).firstOrNull {
                extractor.getTrackFormat(it).getString(MediaFormat.KEY_MIME)?.startsWith("audio/") == true
            } ?: return null
            val format = extractor.getTrackFormat(track)
            val durationUs = if (format.containsKey(MediaFormat.KEY_DURATION)) format.getLong(MediaFormat.KEY_DURATION) else 0L
            if (durationUs <= 0) return null
            extractor.selectTrack(track)
            val peaks = DoubleArray(buckets)
            decode(extractor, format) { pcm, channels, sampleRate, startUs ->
                Waveform.accumulate(peaks, pcm, channels, sampleRate, startUs, durationUs)
            }
            return Waveform.normalized(peaks)
        } finally {
            extractor.release()
        }
    }

    private fun decode(
        extractor: MediaExtractor,
        format: MediaFormat,
        onPcm: (ShortArray, Int, Int, Long) -> Unit,
    ) {
        val codec = MediaCodec.createDecoderByType(format.getString(MediaFormat.KEY_MIME)!!)
        try {
            codec.configure(format, null, null, 0)
            codec.start()
            var channels = format.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
            var sampleRate = format.getInteger(MediaFormat.KEY_SAMPLE_RATE)
            val info = MediaCodec.BufferInfo()
            var inputDone = false
            while (true) {
                if (!inputDone) {
                    val index = codec.dequeueInputBuffer(TIMEOUT_US)
                    if (index >= 0) {
                        val size = extractor.readSampleData(codec.getInputBuffer(index)!!, 0)
                        if (size < 0) {
                            codec.queueInputBuffer(index, 0, 0, 0, MediaCodec.BUFFER_FLAG_END_OF_STREAM)
                            inputDone = true
                        } else {
                            codec.queueInputBuffer(index, 0, size, extractor.sampleTime, 0)
                            extractor.advance()
                        }
                    }
                }
                val out = codec.dequeueOutputBuffer(info, TIMEOUT_US)
                when {
                    out == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED -> {
                        channels = codec.outputFormat.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
                        sampleRate = codec.outputFormat.getInteger(MediaFormat.KEY_SAMPLE_RATE)
                    }
                    out >= 0 -> {
                        if (info.size > 0) {
                            val buffer = codec.getOutputBuffer(out)!!
                            buffer.position(info.offset)
                            buffer.limit(info.offset + info.size)
                            val shorts = buffer.order(ByteOrder.nativeOrder()).asShortBuffer()
                            val pcm = ShortArray(shorts.remaining()).also { shorts.get(it) }
                            onPcm(pcm, channels, sampleRate, info.presentationTimeUs)
                        }
                        codec.releaseOutputBuffer(out, false)
                        if (info.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) return
                    }
                }
            }
        } finally {
            codec.release()
        }
    }

    companion object {
        const val MAX_BUCKETS = 1000
        private const val TIMEOUT_US = 10_000L
    }
}

/** Pure waveform math, unit-tested on the JVM. */
object Waveform {
    /**
     * Adds interleaved 16-bit [pcm] starting at [startUs] to [peaks], which
     * split [durationUs] into equal slices.
     */
    fun accumulate(
        peaks: DoubleArray,
        pcm: ShortArray,
        channels: Int,
        sampleRate: Int,
        startUs: Long,
        durationUs: Long,
    ) {
        if (channels <= 0 || sampleRate <= 0 || durationUs <= 0) return
        val frames = pcm.size / channels
        for (frame in 0 until frames) {
            val timeUs = startUs + frame * 1_000_000L / sampleRate
            val bucket = (timeUs * peaks.size / durationUs).toInt()
            if (bucket < 0 || bucket >= peaks.size) continue
            for (c in 0 until channels) {
                val level = abs(pcm[frame * channels + c].toInt()) / 32768.0
                if (level > peaks[bucket]) peaks[bucket] = level
            }
        }
    }

    /** Scales so the loudest slice is 1; silence stays 0. */
    fun normalized(peaks: DoubleArray): DoubleArray {
        val max = peaks.maxOrNull() ?: 0.0
        return if (max <= 0.0) peaks.copyOf() else DoubleArray(peaks.size) { peaks[it] / max }
    }
}
