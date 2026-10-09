package app.auvie.engine.export

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.BlendMode
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.RectF
import app.auvie.engine.pigeon.ExportLayer
import app.auvie.engine.pigeon.LayerBlend
import java.io.IOException
import kotlin.math.roundToInt

/**
 * Composites the elements Flutter rasterized (text, brush, stickers,
 * overlays, frames) over the developed photo, bottom first, each with its
 * blend mode and opacity. One layer in memory at a time.
 */
object LayerCompositor {
    fun blendMode(blend: LayerBlend): BlendMode = when (blend) {
        LayerBlend.NORMAL -> BlendMode.SRC_OVER
        LayerBlend.SCREEN -> BlendMode.SCREEN
        LayerBlend.MULTIPLY -> BlendMode.MULTIPLY
        LayerBlend.OVERLAY -> BlendMode.OVERLAY
        LayerBlend.SOFT_LIGHT -> BlendMode.SOFT_LIGHT
    }

    fun validate(layer: ExportLayer) {
        require(layer.path.isNotBlank()) { "Layer without a file" }
        require(
            listOf(layer.left, layer.top, layer.width, layer.height).all { it.isFinite() } &&
                layer.width > 0 && layer.height > 0,
        ) { "Layer ${layer.path} has an invalid rect" }
        require(layer.opacity in 0.0..1.0) { "Layer opacity must be 0…1, was ${layer.opacity}" }
    }

    /**
     * Draws [layers] onto [output]. Rects are in the requested output's
     * pixels; [scale] maps them to [output] if it was capped smaller.
     */
    fun compose(output: Bitmap, layers: List<ExportLayer>, scale: Float = 1f, onLayer: (Int) -> Unit = {}) {
        val canvas = Canvas(output)
        layers.forEachIndexed { i, layer ->
            validate(layer)
            val bitmap = BitmapFactory.decodeFile(layer.path)
                ?: throw IOException("Cannot read layer ${layer.path}")
            try {
                val paint = Paint(Paint.FILTER_BITMAP_FLAG or Paint.ANTI_ALIAS_FLAG).apply {
                    alpha = (layer.opacity * 255).roundToInt()
                    blendMode = blendMode(layer.blend)
                }
                val rect = RectF(
                    (layer.left * scale).toFloat(),
                    (layer.top * scale).toFloat(),
                    ((layer.left + layer.width) * scale).toFloat(),
                    ((layer.top + layer.height) * scale).toFloat(),
                )
                canvas.drawBitmap(bitmap, null, rect, paint)
            } finally {
                bitmap.recycle()
            }
            onLayer(i)
        }
    }
}
