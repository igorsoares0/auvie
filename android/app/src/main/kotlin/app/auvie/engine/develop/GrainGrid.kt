package app.auvie.engine.develop

/**
 * Grain cells across an output of [width]×[height]: one cell per pixel up to
 * [MAX_CELLS_SHORT_SIDE] on the shorter side, so a preview and a full-size
 * export of the same photo get grain of the same relative size.
 */
object GrainGrid {
    const val MAX_CELLS_SHORT_SIDE = 1200

    fun cells(width: Int, height: Int): Pair<Float, Float> {
        val shortSide = minOf(width, height).coerceAtLeast(1)
        val scale = minOf(1f, MAX_CELLS_SHORT_SIDE.toFloat() / shortSide)
        return width * scale to height * scale
    }
}
