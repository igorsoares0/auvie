package app.auvie.engine.develop

import app.auvie.engine.media.PixelSize
import kotlin.math.hypot
import kotlin.math.max
import kotlin.math.roundToInt

/**
 * The crop/turn/flip/straighten transform computed in Dart
 * (lib/core/models/crop_geometry.dart): output uv → source uv as
 * `[a, b, c, d, tx, ty]`, meaning `x' = a·x + b·y + tx`, `y' = c·x + d·y + ty`.
 */
object Geometry {
    val IDENTITY = doubleArrayOf(1.0, 0.0, 0.0, 1.0, 0.0, 0.0)

    fun validated(values: DoubleArray): DoubleArray {
        require(values.size == 6) { "geometry needs 6 values, got ${values.size}" }
        require(values.all { it.isFinite() }) { "geometry must be finite" }
        return values
    }

    /** Column-major 3×3 matrix for `glUniformMatrix3fv`. */
    fun toMatrix3(g: DoubleArray): FloatArray = floatArrayOf(
        g[0].toFloat(), g[2].toFloat(), 0f,
        g[1].toFloat(), g[3].toFloat(), 0f,
        g[4].toFloat(), g[5].toFloat(), 1f,
    )

    /**
     * Size of the cropped area in source pixels for a [sourceWidth]×[sourceHeight]
     * source, fitted within [maxPx] on its longer side.
     */
    fun outputSize(g: DoubleArray, sourceWidth: Int, sourceHeight: Int, maxPx: Int): PixelSize {
        val width = hypot(g[0] * sourceWidth, g[2] * sourceHeight)
        val height = hypot(g[1] * sourceWidth, g[3] * sourceHeight)
        return PixelSize(max(1, width.roundToInt()), max(1, height.roundToInt())).fitWithin(maxPx)
    }
}
