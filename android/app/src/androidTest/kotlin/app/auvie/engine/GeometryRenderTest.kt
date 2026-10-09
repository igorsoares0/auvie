package app.auvie.engine

import android.graphics.Bitmap
import android.graphics.Color
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import app.auvie.engine.develop.DevelopReference
import app.auvie.engine.develop.DevelopSettings
import app.auvie.engine.gl.GlEngine
import com.google.common.truth.Truth.assertThat
import com.google.common.truth.Truth.assertWithMessage
import org.junit.AfterClass
import org.junit.BeforeClass
import org.junit.Test
import org.junit.runner.RunWith

/** The crop geometry on the GPU, and tiled renders matching whole ones. */
@RunWith(AndroidJUnit4::class)
class GeometryRenderTest {
    companion object {
        private lateinit var engine: GlEngine

        @BeforeClass
        @JvmStatic
        fun setUp() {
            engine = GlEngine(InstrumentationRegistry.getInstrumentation().targetContext.assets)
        }

        @AfterClass
        @JvmStatic
        fun tearDown() = engine.release()

        private val RED = Color.rgb(220, 30, 30)
        private val GREEN = Color.rgb(30, 200, 60)
        private val BLUE = Color.rgb(40, 60, 210)
        private val WHITE = Color.rgb(250, 250, 250)
    }

    /** 200×100: red | green on top, blue | white below. */
    private val quadrants = Bitmap.createBitmap(200, 100, Bitmap.Config.ARGB_8888).apply {
        for (x in 0 until 200) for (y in 0 until 100) {
            setPixel(
                x, y,
                when {
                    x < 100 && y < 50 -> RED
                    y < 50 -> GREEN
                    x < 100 -> BLUE
                    else -> WHITE
                },
            )
        }
    }

    private fun render(geometry: DoubleArray, width: Int, height: Int, tile: Int = 2048): Bitmap =
        engine.thread.runBlocking {
            engine.renderToBitmap(
                quadrants, DevelopSettings(geometry = geometry), width, height, tile,
            )
        }

    /** Colour at the centre of each output quadrant: TL, TR, BL, BR. */
    private fun corners(b: Bitmap) = listOf(
        b.getPixel(b.width / 4, b.height / 4),
        b.getPixel(b.width * 3 / 4, b.height / 4),
        b.getPixel(b.width / 4, b.height * 3 / 4),
        b.getPixel(b.width * 3 / 4, b.height * 3 / 4),
    )

    private fun assertColors(actual: List<Int>, expected: List<Int>) {
        actual.zip(expected).forEachIndexed { i, (a, e) ->
            val diff = DevelopReference.maxChannelDifference(
                intArrayOf(Color.red(a), Color.green(a), Color.blue(a)),
                intArrayOf(Color.red(e), Color.green(e), Color.blue(e)),
            )
            assertWithMessage("quadrant $i").that(diff).isAtMost(2)
        }
    }

    @Test
    fun identityKeepsTheImage() {
        assertColors(corners(render(doubleArrayOf(1.0, 0.0, 0.0, 1.0, 0.0, 0.0), 200, 100)), listOf(RED, GREEN, BLUE, WHITE))
    }

    @Test
    fun aCropShowsOnlyItsArea() {
        // Right half: left of the output is green/white only.
        val out = render(doubleArrayOf(0.5, 0.0, 0.0, 1.0, 0.5, 0.0), 100, 100)
        assertColors(corners(out), listOf(GREEN, GREEN, WHITE, WHITE))
    }

    @Test
    fun aQuarterTurnRotatesClockwise() {
        // Same matrix as Dart's CropGeometry for quarterTurns = 1.
        val out = render(doubleArrayOf(0.0, 1.0, -1.0, 0.0, 0.0, 1.0), 100, 200)
        assertColors(corners(out), listOf(BLUE, RED, WHITE, GREEN))
    }

    @Test
    fun aFlipMirrors() {
        val out = render(doubleArrayOf(-1.0, 0.0, 0.0, 1.0, 1.0, 0.0), 200, 100)
        assertColors(corners(out), listOf(GREEN, RED, WHITE, BLUE))
    }

    @Test
    fun tilesMatchAWholeRender() {
        val gradient = Bitmap.createBitmap(300, 200, Bitmap.Config.ARGB_8888)
        for (x in 0 until 300) for (y in 0 until 200) {
            gradient.setPixel(x, y, Color.rgb(x * 255 / 299, y * 255 / 199, 128))
        }
        // Vignette and grain depend on the position in the whole output.
        val settings = DevelopSettings(vignette = 0.8f, grain = 0.5f, exposure = 0.2f)
        val (whole, tiled) = engine.thread.runBlocking {
            engine.renderToBitmap(gradient, settings, 300, 200, 2048) to
                engine.renderToBitmap(gradient, settings, 300, 200, 64)
        }
        var worst = 0
        for (x in 0 until 300) for (y in 0 until 200) {
            val a = whole.getPixel(x, y)
            val b = tiled.getPixel(x, y)
            worst = maxOf(
                worst,
                DevelopReference.maxChannelDifference(
                    intArrayOf(Color.red(a), Color.green(a), Color.blue(a)),
                    intArrayOf(Color.red(b), Color.green(b), Color.blue(b)),
                ),
            )
        }
        assertThat(worst).isAtMost(1)
    }
}
