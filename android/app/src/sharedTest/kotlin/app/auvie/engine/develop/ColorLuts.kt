package app.auvie.engine.develop

import kotlin.math.roundToInt

/** Color mix LUTs for tests (the app builds them in Dart, color_mix.dart). */
object ColorLuts {
    /** The same hue shift, saturation and luminance (-1..1) at every hue. */
    fun uniform(hue: Double = 0.0, saturation: Double = 0.0, luminance: Double = 0.0): ByteArray =
        byHue { doubleArrayOf(hue, saturation, luminance) }

    /** [values] (hue shift, saturation, luminance) for each entry's hue in 0..1. */
    fun byHue(values: (Double) -> DoubleArray): ByteArray = ByteArray(DevelopSettings.LUT_BYTES).also { lut ->
        for (i in 0 until 256) {
            val v = values((i + 0.5) / 256)
            for (c in 0 until 3) {
                lut[i * 4 + c] = (DevelopSettings.COLOR_LUT_ZERO + v[c] * 127).roundToInt().coerceIn(1, 255).toByte()
            }
            lut[i * 4 + 3] = 255.toByte()
        }
    }
}
