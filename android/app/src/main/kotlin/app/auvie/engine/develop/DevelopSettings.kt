package app.auvie.engine.develop

import app.auvie.engine.pigeon.DevelopParams

/**
 * Validated develop parameters: the 12 adjustments of
 * lib/core/models/adjustment.dart (same ranges) plus the curve LUT.
 */
class DevelopSettings(
    val exposure: Float = 0f,
    val brightness: Float = 0f,
    val contrast: Float = 0f,
    val highlights: Float = 0f,
    val shadows: Float = 0f,
    val saturation: Float = 0f,
    val temperature: Float = 0f,
    val tint: Float = 0f,
    val sharpen: Float = 0f,
    val grain: Float = 0f,
    val fade: Float = 0f,
    val vignette: Float = 0f,
    curveLut: ByteArray = IDENTITY_LUT,
) {
    /** 256x1 RGBA. */
    val curveLut: ByteArray = curveLut.also {
        require(it.size == LUT_BYTES) { "curveLut must be $LUT_BYTES bytes, was ${it.size}" }
    }

    override fun equals(other: Any?): Boolean =
        other is DevelopSettings && values() == other.values() &&
            curveLut.contentEquals(other.curveLut)

    override fun hashCode(): Int = 31 * values().hashCode() + curveLut.contentHashCode()

    override fun toString(): String = "DevelopSettings(${PARAMETERS.zip(values())})"

    fun values(): List<Float> = listOf(
        exposure, brightness, contrast, highlights, shadows, saturation,
        temperature, tint, sharpen, grain, fade, vignette,
    )

    companion object {
        const val LUT_BYTES = 256 * 4

        /** Parameter names, in the order of Dart's `Adjustment.values`. */
        val PARAMETERS = listOf(
            "exposure", "brightness", "contrast", "highlights", "shadows", "saturation",
            "temperature", "tint", "sharpen", "grain", "fade", "vignette",
        )

        /** Parameters that go from 0 to 1; the others go from -1 to 1. */
        private val UNIPOLAR = setOf("sharpen", "grain", "fade")

        val IDENTITY_LUT: ByteArray = ByteArray(LUT_BYTES) { i ->
            (if (i % 4 == 3) 255 else i / 4).toByte()
        }

        val NEUTRAL = DevelopSettings()

        /** Builds settings from named values, clamping each to its range. */
        fun fromMap(values: Map<String, Double>, curveLut: ByteArray = IDENTITY_LUT): DevelopSettings {
            val unknown = values.keys - PARAMETERS.toSet()
            require(unknown.isEmpty()) { "Unknown parameters: $unknown" }
            fun v(name: String): Float {
                val min = if (name in UNIPOLAR) 0.0 else -1.0
                return (values[name] ?: 0.0).coerceIn(min, 1.0).toFloat()
            }
            return DevelopSettings(
                exposure = v("exposure"),
                brightness = v("brightness"),
                contrast = v("contrast"),
                highlights = v("highlights"),
                shadows = v("shadows"),
                saturation = v("saturation"),
                temperature = v("temperature"),
                tint = v("tint"),
                sharpen = v("sharpen"),
                grain = v("grain"),
                fade = v("fade"),
                vignette = v("vignette"),
                curveLut = curveLut,
            )
        }

        fun from(p: DevelopParams): DevelopSettings = fromMap(
            mapOf(
                "exposure" to p.exposure,
                "brightness" to p.brightness,
                "contrast" to p.contrast,
                "highlights" to p.highlights,
                "shadows" to p.shadows,
                "saturation" to p.saturation,
                "temperature" to p.temperature,
                "tint" to p.tint,
                "sharpen" to p.sharpen,
                "grain" to p.grain,
                "fade" to p.fade,
                "vignette" to p.vignette,
            ),
            p.curveLut,
        )
    }
}
