package app.auvie.engine.export

import app.auvie.engine.media.PixelSize
import app.auvie.engine.pigeon.ExportFormat
import kotlin.math.floor
import kotlin.math.max
import kotlin.math.min
import kotlin.math.sqrt

/** A rectangle of output pixels rendered in one draw. */
data class Tile(val x: Int, val y: Int, val width: Int, val height: Int)

/** Pure sizing decisions of a photo export. */
object ExportPlanner {
    /** "Original" never exceeds this, whatever the camera. */
    const val MAX_PIXELS = 32_000_000L

    /** Largest tile side; well under GL_MAX_TEXTURE_SIZE / viewport limits. */
    const val TILE = 2048

    const val JPEG_QUALITY = 92

    /** [width]×[height] scaled down (never up) to at most [MAX_PIXELS]. */
    fun clampOutput(width: Int, height: Int): PixelSize {
        require(width > 0 && height > 0) { "Output must be positive, was ${width}x$height" }
        val pixels = width.toLong() * height
        if (pixels <= MAX_PIXELS) return PixelSize(width, height)
        val scale = sqrt(MAX_PIXELS.toDouble() / pixels)
        return PixelSize(
            max(1, floor(width * scale).toInt()),
            max(1, floor(height * scale).toInt()),
        )
    }

    /** Tiles covering a [width]×[height] output exactly, row by row. */
    fun tiles(width: Int, height: Int, tile: Int = TILE): List<Tile> {
        require(tile > 0) { "tile must be positive" }
        val result = ArrayList<Tile>()
        var y = 0
        while (y < height) {
            val h = min(tile, height - y)
            var x = 0
            while (x < width) {
                val w = min(tile, width - x)
                result += Tile(x, y, w, h)
                x += w
            }
            y += h
        }
        return result
    }

    /**
     * Bytes an export needs while running: the app copy plus the gallery
     * copy. Conservative per-pixel sizes (JPEG at quality 92, PNG of a photo).
     */
    fun requiredBytes(width: Int, height: Int, format: ExportFormat): Long {
        val pixels = width.toLong() * height
        val perPixel = when (format) {
            ExportFormat.JPEG -> 0.6
            ExportFormat.PNG -> 3.2
        }
        return (pixels * perPixel * 2).toLong()
    }

    fun extension(format: ExportFormat) = when (format) {
        ExportFormat.JPEG -> "jpg"
        ExportFormat.PNG -> "png"
    }

    fun mimeType(format: ExportFormat) = when (format) {
        ExportFormat.JPEG -> "image/jpeg"
        ExportFormat.PNG -> "image/png"
    }

    /** A safe file name: letters, digits, dot, dash and underscore only. */
    fun fileName(base: String, format: ExportFormat): String {
        val safe = base.trim().replace(Regex("[^A-Za-z0-9._-]+"), "_").trim('_').ifEmpty { "Auvie" }
        return "$safe.${extension(format)}"
    }
}
