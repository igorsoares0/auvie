package app.auvie.engine.develop

import kotlin.math.abs
import kotlin.math.floor
import kotlin.math.pow
import kotlin.math.sqrt

/**
 * CPU mirror of develop.frag steps 2-5 (no sharpen, no grain), used as the
 * test oracle. Keep the constants and order identical to the shader.
 */
object DevelopReference {
    private const val EXPOSURE_STOPS = 2.0
    private const val WHITE_BALANCE = 0.15
    private const val BRIGHTNESS_POWER = 0.8
    private const val TONE_AMOUNT = 0.25
    private const val FADE_LIFT = 0.15
    private const val VIGNETTE_AMOUNT = 0.6
    private const val VIGNETTE_START = 0.35
    private val LUMA = doubleArrayOf(0.2126, 0.7152, 0.0722)

    /** [rgb] and the result are sRGB in 0..1; [u], [v] are texture coordinates. */
    fun develop(
        rgb: DoubleArray,
        s: DevelopSettings,
        u: Double = 0.5,
        v: Double = 0.5,
        aspect: Double = 1.0,
    ): DoubleArray {
        // 2. Light, in linear.
        val gain = 2.0.pow(s.exposure * EXPOSURE_STOPS)
        val wb = doubleArrayOf(
            1 + s.temperature * WHITE_BALANCE,
            1 - s.tint * WHITE_BALANCE,
            1 - s.temperature * WHITE_BALANCE,
        )
        var c = DoubleArray(3) { toSrgb((toLinear(rgb[it]) * gain * wb[it]).coerceIn(0.0, 1.0)) }

        // 3. Tone and color.
        val power = 2.0.pow(-s.brightness * BRIGHTNESS_POWER)
        c = DoubleArray(3) { c[it].pow(power) }
        val l = luma(c)
        val tone = (s.shadows * (1 - smoothstep(0.0, 0.5, l)) + s.highlights * smoothstep(0.5, 1.0, l)) * TONE_AMOUNT
        c = DoubleArray(3) { (c[it] + tone - 0.5) * (1 + s.contrast) + 0.5 }
        val l2 = luma(c)
        c = DoubleArray(3) { (l2 + (c[it] - l2) * (1 + s.saturation)).coerceIn(0.0, 1.0) }

        // 4. Curves (linear interpolation, like GL_LINEAR on the LUT texture).
        c = DoubleArray(3) { curve(s.curveLut, c[it], it) }

        // 5. Fade and vignette.
        c = DoubleArray(3) { c[it] + s.fade * FADE_LIFT * (1 - c[it]) }
        val dx = (u - 0.5) * aspect
        val dy = v - 0.5
        val d = sqrt(dx * dx + dy * dy) / sqrt((aspect * 0.5).pow(2) + 0.25)
        val vig = smoothstep(VIGNETTE_START, 1.0, d) * VIGNETTE_AMOUNT
        c = DoubleArray(3) {
            if (s.vignette >= 0) c[it] * (1 - s.vignette * vig)
            else c[it] + (-s.vignette) * vig * (1 - c[it])
        }
        return DoubleArray(3) { c[it].coerceIn(0.0, 1.0) }
    }

    /** Convenience for 0-255 colors. */
    fun develop255(rgb: IntArray, s: DevelopSettings, u: Double = 0.5, v: Double = 0.5, aspect: Double = 1.0): IntArray {
        val out = develop(DoubleArray(3) { rgb[it] / 255.0 }, s, u, v, aspect)
        return IntArray(3) { Math.round(out[it] * 255).toInt() }
    }

    private fun luma(c: DoubleArray) = c[0] * LUMA[0] + c[1] * LUMA[1] + c[2] * LUMA[2]

    private fun toLinear(c: Double) = if (c < 0.04045) c / 12.92 else ((c + 0.055) / 1.055).pow(2.4)

    private fun toSrgb(c: Double) = if (c < 0.0031308) c * 12.92 else 1.055 * c.pow(1 / 2.4) - 0.055

    private fun smoothstep(e0: Double, e1: Double, x: Double): Double {
        val t = ((x - e0) / (e1 - e0)).coerceIn(0.0, 1.0)
        return t * t * (3 - 2 * t)
    }

    private fun curve(lut: ByteArray, value: Double, channel: Int): Double {
        val x = value * 255
        val i0 = floor(x).toInt().coerceIn(0, 255)
        val i1 = minOf(i0 + 1, 255)
        val f = x - i0
        val a = (lut[i0 * 4 + channel].toInt() and 0xFF) / 255.0
        val b = (lut[i1 * 4 + channel].toInt() and 0xFF) / 255.0
        return a + (b - a) * f
    }

    fun maxChannelDifference(a: IntArray, b: IntArray): Int = (0 until 3).maxOf { abs(a[it] - b[it]) }
}
