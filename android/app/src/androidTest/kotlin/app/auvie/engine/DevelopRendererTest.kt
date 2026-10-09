package app.auvie.engine

import android.graphics.Bitmap
import android.graphics.Color
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import app.auvie.engine.develop.DevelopReference
import app.auvie.engine.develop.DevelopSettings
import app.auvie.engine.develop.DevelopVectors
import app.auvie.engine.gl.GlEngine
import com.google.common.truth.Truth.assertThat
import com.google.common.truth.Truth.assertWithMessage
import kotlin.math.sqrt
import org.junit.AfterClass
import org.junit.BeforeClass
import org.junit.Test
import org.junit.runner.RunWith

/** develop.frag on the device GPU, checked against the CPU reference. */
@RunWith(AndroidJUnit4::class)
class DevelopRendererTest {
    companion object {
        private lateinit var engine: GlEngine
        private lateinit var fixture: DevelopVectors

        /** Max difference per channel between GPU and CPU, out of 255. */
        private const val TOLERANCE = 2

        @BeforeClass
        @JvmStatic
        fun setUp() {
            val instrumentation = InstrumentationRegistry.getInstrumentation()
            engine = GlEngine(instrumentation.targetContext.assets)
            fixture = DevelopVectors.parse(
                instrumentation.context.assets.open("develop_vectors.json").bufferedReader().use { it.readText() },
            )
        }

        @AfterClass
        @JvmStatic
        fun tearDown() = engine.release()
    }

    private fun render(bitmap: Bitmap, settings: DevelopSettings): Bitmap =
        engine.thread.runBlocking { engine.renderToBitmap(bitmap, settings) }

    private fun solid(width: Int, height: Int, rgb: IntArray): Bitmap =
        Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888).apply {
            eraseColor(Color.rgb(rgb[0], rgb[1], rgb[2]))
        }

    private fun rgbAt(bitmap: Bitmap, x: Int, y: Int): IntArray {
        val p = bitmap.getPixel(x, y)
        return intArrayOf(Color.red(p), Color.green(p), Color.blue(p))
    }

    @Test
    fun everyVectorMatchesTheReferenceAcrossTheFrame() {
        val (w, h) = 16 to 12
        val samples = listOf(0 to 0, w - 1 to h - 1, w / 2 to h / 2, 3 to 9, w - 1 to 0)
        for (vector in fixture.vectors) {
            val out = render(solid(w, h, vector.input), vector.settings)
            for ((x, y) in samples) {
                val expected = DevelopReference.develop255(
                    vector.input, vector.settings,
                    u = (x + 0.5) / w, v = (y + 0.5) / h, aspect = w.toDouble() / h,
                )
                val actual = rgbAt(out, x, y)
                assertWithMessage("${vector.name} at ($x,$y): gpu ${actual.toList()} cpu ${expected.toList()}")
                    .that(DevelopReference.maxChannelDifference(actual, expected))
                    .isAtMost(TOLERANCE)
            }
        }
    }

    @Test
    fun neutralKeepsAGradientAndRowOrder() {
        val w = 256
        val h = 4
        val gradient = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
        for (x in 0 until w) for (y in 0 until h) {
            gradient.setPixel(x, y, Color.rgb(x, if (y == 0) 255 else 0, 255 - x))
        }
        val out = render(gradient, DevelopSettings.NEUTRAL)
        for (x in 0 until w step 15) for (y in 0 until h) {
            assertWithMessage("($x,$y)")
                .that(DevelopReference.maxChannelDifference(rgbAt(out, x, y), rgbAt(gradient, x, y)))
                .isAtMost(1)
        }
    }

    @Test
    fun sharpenLeavesFlatAreasAndBoostsEdges() {
        val flat = render(solid(8, 8, intArrayOf(120, 120, 120)), DevelopSettings(sharpen = 1f))
        assertThat(rgbAt(flat, 4, 4).toList()).isEqualTo(listOf(120, 120, 120))

        val edge = Bitmap.createBitmap(8, 8, Bitmap.Config.ARGB_8888)
        for (x in 0 until 8) for (y in 0 until 8) {
            edge.setPixel(x, y, if (x < 4) Color.rgb(80, 80, 80) else Color.rgb(170, 170, 170))
        }
        val out = render(edge, DevelopSettings(sharpen = 1f))
        assertThat(rgbAt(out, 3, 4)[0]).isLessThan(80)
        assertThat(rgbAt(out, 4, 4)[0]).isGreaterThan(170)
    }

    @Test
    fun grainKeepsTheMeanAndIsDeterministic() {
        val gray = solid(256, 256, intArrayOf(128, 128, 128))
        val none = stats(render(gray, DevelopSettings.NEUTRAL))
        val light = stats(render(gray, DevelopSettings(grain = 0.3f)))
        val heavy = render(gray, DevelopSettings(grain = 1f))
        val heavyStats = stats(heavy)

        assertThat(none.second).isLessThan(0.5)
        assertThat(heavyStats.first).isWithin(2.0).of(128.0)
        assertThat(heavyStats.second).isGreaterThan(light.second)
        assertThat(light.second).isGreaterThan(none.second)

        val again = render(gray, DevelopSettings(grain = 1f))
        assertThat(again.sameAs(heavy)).isTrue()
    }

    /** Mean and standard deviation of the red channel. */
    private fun stats(bitmap: Bitmap): Pair<Double, Double> {
        val values = IntArray(bitmap.width * bitmap.height)
        bitmap.getPixels(values, 0, bitmap.width, 0, 0, bitmap.width, bitmap.height)
        val reds = values.map { Color.red(it).toDouble() }
        val mean = reds.average()
        val variance = reds.sumOf { (it - mean) * (it - mean) } / reds.size
        return mean to sqrt(variance)
    }
}
