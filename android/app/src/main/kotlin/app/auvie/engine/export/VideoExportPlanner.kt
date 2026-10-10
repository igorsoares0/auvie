package app.auvie.engine.export

import app.auvie.engine.pigeon.DevelopParams
import app.auvie.engine.pigeon.ExportLayer
import app.auvie.engine.pigeon.LayerBlend
import app.auvie.engine.pigeon.VideoExportRequest
import java.util.Base64
import org.json.JSONArray
import org.json.JSONObject

/** Pure decisions of a video export, and its job file for the worker. */
object VideoExportPlanner {
    /** Longer side limit for "Original" (most H.264 encoders stop at 4K). */
    const val MAX_SIDE = 3840

    const val AUDIO_BITRATE = 128_000
    const val MIME_TYPE = "video/mp4"

    fun validate(request: VideoExportRequest) {
        val width = request.outputWidth
        val height = request.outputHeight
        require(width > 0 && height > 0 && width % 2 == 0L && height % 2 == 0L) {
            "Video output must be even and positive, was ${width}x$height"
        }
        require(maxOf(width, height) <= MAX_SIDE) { "Video output over $MAX_SIDE px: ${width}x$height" }
        require(request.trimStartMs >= 0 && request.trimEndMs > request.trimStartMs) {
            "Invalid trim ${request.trimStartMs}…${request.trimEndMs}"
        }
        require(request.videoBitrate in 100_000..200_000_000) { "Invalid bitrate ${request.videoBitrate}" }
        request.layers.forEach { layer ->
            LayerCompositor.validate(layer)
            val start = layer.startMs
            val end = layer.endMs
            require((start == null) == (end == null) && (start == null || end!! > start)) {
                "Layer ${layer.path} has an invalid time range $start…$end"
            }
        }
    }

    /** Bytes needed while exporting: the app copy plus the gallery copy, with 10% slack. */
    fun requiredBytes(videoBitrate: Long, durationMs: Long, includeAudio: Boolean): Long {
        val bitrate = videoBitrate + if (includeAudio) AUDIO_BITRATE else 0
        return (bitrate * durationMs / 8_000.0 * 2 * 1.1).toLong()
    }

    /**
     * Whether a layer shows on the frame at [presentationTimeUs], which
     * Media3 counts from the trim start. Layer times are in the original clip.
     */
    fun layerVisible(layer: ExportLayer, presentationTimeUs: Long, trimStartMs: Long): Boolean {
        val start = layer.startMs ?: return true
        val end = layer.endMs ?: return true
        val mediaMs = trimStartMs + presentationTimeUs / 1000
        return mediaMs in start until end
    }

    fun fileName(base: String): String {
        val safe = base.trim().replace(Regex("[^A-Za-z0-9._-]+"), "_").trim('_').ifEmpty { "Auvie" }
        return "$safe.mp4"
    }

    // The job file: WorkManager's Data is limited to 10 KB.

    fun toJson(request: VideoExportRequest): String = JSONObject().apply {
        put("uri", request.uri)
        put("params", paramsJson(request.params))
        put("outputWidth", request.outputWidth)
        put("outputHeight", request.outputHeight)
        put("trimStartMs", request.trimStartMs)
        put("trimEndMs", request.trimEndMs)
        put("includeAudio", request.includeAudio)
        put("videoBitrate", request.videoBitrate)
        put("fileName", request.fileName)
        put("layers", JSONArray().apply { request.layers.forEach { put(layerJson(it)) } })
    }.toString()

    fun fromJson(json: String): VideoExportRequest {
        val o = JSONObject(json)
        val layers = o.getJSONArray("layers")
        return VideoExportRequest(
            uri = o.getString("uri"),
            params = params(o.getJSONObject("params")),
            outputWidth = o.getLong("outputWidth"),
            outputHeight = o.getLong("outputHeight"),
            trimStartMs = o.getLong("trimStartMs"),
            trimEndMs = o.getLong("trimEndMs"),
            includeAudio = o.getBoolean("includeAudio"),
            videoBitrate = o.getLong("videoBitrate"),
            fileName = o.getString("fileName"),
            layers = (0 until layers.length()).map { layer(layers.getJSONObject(it)) },
        )
    }

    private val PARAM_NAMES = listOf(
        "exposure", "brightness", "contrast", "highlights", "shadows", "saturation",
        "temperature", "tint", "sharpen", "grain", "fade", "vignette",
    )

    private fun paramsJson(p: DevelopParams) = JSONObject().apply {
        val values = listOf(
            p.exposure, p.brightness, p.contrast, p.highlights, p.shadows, p.saturation,
            p.temperature, p.tint, p.sharpen, p.grain, p.fade, p.vignette,
        )
        PARAM_NAMES.zip(values).forEach { (name, value) -> put(name, value) }
        put("curveLut", Base64.getEncoder().encodeToString(p.curveLut))
        put("geometry", JSONArray().apply { p.geometry.forEach { put(it) } })
    }

    private fun params(o: JSONObject): DevelopParams {
        val v = PARAM_NAMES.map { o.getDouble(it) }
        val geometry = o.getJSONArray("geometry")
        return DevelopParams(
            exposure = v[0], brightness = v[1], contrast = v[2], highlights = v[3],
            shadows = v[4], saturation = v[5], temperature = v[6], tint = v[7],
            sharpen = v[8], grain = v[9], fade = v[10], vignette = v[11],
            curveLut = Base64.getDecoder().decode(o.getString("curveLut")),
            geometry = DoubleArray(geometry.length()) { geometry.getDouble(it) },
        )
    }

    private fun layerJson(l: ExportLayer) = JSONObject().apply {
        put("path", l.path)
        put("left", l.left)
        put("top", l.top)
        put("width", l.width)
        put("height", l.height)
        put("blend", l.blend.name)
        put("opacity", l.opacity)
        l.startMs?.let { put("startMs", it) }
        l.endMs?.let { put("endMs", it) }
    }

    private fun layer(o: JSONObject) = ExportLayer(
        path = o.getString("path"),
        left = o.getDouble("left"),
        top = o.getDouble("top"),
        width = o.getDouble("width"),
        height = o.getDouble("height"),
        blend = LayerBlend.valueOf(o.getString("blend")),
        opacity = o.getDouble("opacity"),
        startMs = if (o.has("startMs")) o.getLong("startMs") else null,
        endMs = if (o.has("endMs")) o.getLong("endMs") else null,
    )
}
