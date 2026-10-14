package app.auvie.engine.develop

import kotlin.math.max
import kotlin.math.min

/**
 * How strong grain and sharpen are at 1, and how fine the grain is. The
 * defaults ship; the engine lab changes them live (for every preview and
 * export in the process) to calibrate.
 */
object DevelopTuning {
    const val DEFAULT_GRAIN_AMOUNT = 0.3f
    const val DEFAULT_SHARPEN_AMOUNT = 2.4f
    const val DEFAULT_GRAIN_CELLS = 1000

    /** The sharpen radius is the photo's shorter side over this, at least 1 px. */
    const val SHARPEN_RADIUS_DIVISOR = 1000f

    @Volatile var grainAmount = DEFAULT_GRAIN_AMOUNT
    @Volatile var sharpenAmount = DEFAULT_SHARPEN_AMOUNT

    /** Grain cells across the output's shorter side, at most one per pixel. */
    @Volatile var grainCells = DEFAULT_GRAIN_CELLS

    fun reset() {
        grainAmount = DEFAULT_GRAIN_AMOUNT
        sharpenAmount = DEFAULT_SHARPEN_AMOUNT
        grainCells = DEFAULT_GRAIN_CELLS
    }

    /** Sharpen neighbour offset in source uv for a [width]×[height] source. */
    fun sharpenStep(width: Int, height: Int): Pair<Float, Float> {
        val radius = max(1f, min(width, height) / SHARPEN_RADIUS_DIVISOR)
        return radius / width to radius / height
    }
}
