package app.auvie.engine.media

import kotlin.math.max
import kotlin.math.roundToInt

data class PixelSize(val width: Int, val height: Int) {
    /** This size scaled down (never up) so the longer side is at most [maxPx]. */
    fun fitWithin(maxPx: Int): PixelSize {
        require(maxPx > 0) { "maxPx must be positive, was $maxPx" }
        val longer = max(width, height)
        if (longer <= maxPx) return this
        val scale = maxPx.toDouble() / longer
        return PixelSize(
            (width * scale).roundToInt().coerceAtLeast(1),
            (height * scale).roundToInt().coerceAtLeast(1),
        )
    }

    fun rotated(degrees: Int): PixelSize =
        if (degrees % 180 != 0) PixelSize(height, width) else this
}
