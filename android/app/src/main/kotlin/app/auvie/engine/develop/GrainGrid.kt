package app.auvie.engine.develop

/**
 * Grain cells across an output of [width]×[height]: one cell per pixel up to
 * [maxCells] on the shorter side, so a preview and a full-size export of the
 * same photo get grain of the same relative size.
 */
object GrainGrid {
    fun cells(
        width: Int,
        height: Int,
        maxCells: Int = DevelopTuning.grainCells,
    ): Pair<Float, Float> {
        val shortSide = minOf(width, height).coerceAtLeast(1)
        val scale = minOf(1f, maxCells.toFloat() / shortSide)
        return width * scale to height * scale
    }
}
