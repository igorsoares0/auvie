package app.auvie.engine.gl

import android.opengl.GLES30

/**
 * A linked GLSL program with cached uniform locations. [defines] are added
 * to both shaders right after `#version`. GL thread only.
 */
class ShaderProgram(vertexSource: String, fragmentSource: String, defines: List<String> = emptyList()) {
    val id: Int
    private val uniforms = HashMap<String, Int>()

    init {
        val vertex = compile(GLES30.GL_VERTEX_SHADER, withDefines(vertexSource, defines))
        val fragment = compile(GLES30.GL_FRAGMENT_SHADER, withDefines(fragmentSource, defines))
        id = GLES30.glCreateProgram()
        GLES30.glAttachShader(id, vertex)
        GLES30.glAttachShader(id, fragment)
        GLES30.glLinkProgram(id)
        GLES30.glDeleteShader(vertex)
        GLES30.glDeleteShader(fragment)
        val status = IntArray(1)
        GLES30.glGetProgramiv(id, GLES30.GL_LINK_STATUS, status, 0)
        if (status[0] == 0) {
            val log = GLES30.glGetProgramInfoLog(id)
            GLES30.glDeleteProgram(id)
            error("Shader link failed: $log")
        }
    }

    fun use() = GLES30.glUseProgram(id)

    fun attribute(name: String): Int = GLES30.glGetAttribLocation(id, name)

    fun uniform(name: String): Int = uniforms.getOrPut(name) {
        GLES30.glGetUniformLocation(id, name)
    }

    fun set(name: String, value: Float) = GLES30.glUniform1f(uniform(name), value)

    fun set(name: String, x: Float, y: Float) = GLES30.glUniform2f(uniform(name), x, y)

    fun set(name: String, value: Int) = GLES30.glUniform1i(uniform(name), value)

    fun set(name: String, value: Boolean) = set(name, if (value) 1 else 0)

    fun setMatrix4(name: String, value: FloatArray) =
        GLES30.glUniformMatrix4fv(uniform(name), 1, false, value, 0)

    fun release() = GLES30.glDeleteProgram(id)

    private fun compile(type: Int, source: String): Int {
        val shader = GLES30.glCreateShader(type)
        GLES30.glShaderSource(shader, source)
        GLES30.glCompileShader(shader)
        val status = IntArray(1)
        GLES30.glGetShaderiv(shader, GLES30.GL_COMPILE_STATUS, status, 0)
        if (status[0] == 0) {
            val log = GLES30.glGetShaderInfoLog(shader)
            GLES30.glDeleteShader(shader)
            val kind = if (type == GLES30.GL_VERTEX_SHADER) "vertex" else "fragment"
            error("$kind shader compile failed: $log")
        }
        return shader
    }

    companion object {
        /** [source] with `#define NAME` lines inserted after its `#version` line. */
        fun withDefines(source: String, defines: List<String>): String {
            if (defines.isEmpty()) return source
            val lines = defines.joinToString("") { "#define $it\n" }
            val version = Regex("^\\s*#version[^\\n]*\\n").find(source)
                ?: return lines + source
            return source.substring(0, version.range.last + 1) + lines +
                source.substring(version.range.last + 1)
        }
    }
}
