package app.auvie.engine.develop

import com.google.common.truth.Truth.assertThat
import com.google.common.truth.Truth.assertWithMessage
import java.io.File
import org.junit.Test

class DevelopReferenceTest {
    private val fixture = DevelopVectors.parse(
        File(System.getProperty("fixtures.dir"), "develop_vectors.json").readText(),
    )

    @Test
    fun `fixture parameters match DevelopSettings order`() {
        assertThat(fixture.parameters).containsExactlyElementsIn(DevelopSettings.PARAMETERS).inOrder()
    }

    @Test
    fun `reference matches every vector`() {
        assertThat(fixture.vectors).isNotEmpty()
        for (vector in fixture.vectors) {
            val actual = DevelopReference.develop255(vector.input, vector.settings, vector.u, vector.v)
            assertWithMessage("${vector.name}: got ${actual.toList()}")
                .that(DevelopReference.maxChannelDifference(actual, vector.expected))
                .isAtMost(1)
        }
    }

    @Test
    fun `neutral is identity for every gray level`() {
        for (level in 0..255) {
            val gray = intArrayOf(level, level, level)
            assertThat(DevelopReference.develop255(gray, DevelopSettings.NEUTRAL).toList())
                .isEqualTo(gray.toList())
        }
    }

    @Test
    fun `vignette is symmetric`() {
        val s = DevelopSettings(vignette = 0.7f)
        val gray = intArrayOf(150, 150, 150)
        val a = DevelopReference.develop255(gray, s, 0.1, 0.2, aspect = 1.5)
        val b = DevelopReference.develop255(gray, s, 0.9, 0.8, aspect = 1.5)
        assertThat(a.toList()).isEqualTo(b.toList())
    }
}
