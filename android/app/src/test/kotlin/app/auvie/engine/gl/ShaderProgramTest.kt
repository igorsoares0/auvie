package app.auvie.engine.gl

import com.google.common.truth.Truth.assertThat
import org.junit.Test

class ShaderProgramTest {
    @Test
    fun `defines go right after the version line`() {
        val source = "#version 300 es\n// comment\nprecision highp float;\n"
        assertThat(ShaderProgram.withDefines(source, listOf("EXTERNAL_SOURCE", "A 2")))
            .isEqualTo("#version 300 es\n#define EXTERNAL_SOURCE\n#define A 2\n// comment\nprecision highp float;\n")
    }

    @Test
    fun `no defines leave the source alone`() {
        assertThat(ShaderProgram.withDefines("#version 300 es\nx", emptyList())).isEqualTo("#version 300 es\nx")
    }

    @Test
    fun `sources without a version get the defines first`() {
        assertThat(ShaderProgram.withDefines("void main() {}", listOf("X"))).isEqualTo("#define X\nvoid main() {}")
    }
}
