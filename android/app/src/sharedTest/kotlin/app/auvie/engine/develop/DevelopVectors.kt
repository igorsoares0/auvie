package app.auvie.engine.develop

import org.json.JSONObject

/** test_fixtures/develop_vectors.json, shared with the Dart tests. */
class DevelopVectors(val parameters: List<String>, val vectors: List<Vector>) {
    class Vector(
        val name: String,
        val settings: DevelopSettings,
        val input: IntArray,
        val expected: IntArray,
        val u: Double,
        val v: Double,
    ) {
        override fun toString() = name
    }

    companion object {
        val INVERT_LUT: ByteArray = ByteArray(DevelopSettings.LUT_BYTES) { i ->
            (if (i % 4 == 3) 255 else 255 - i / 4).toByte()
        }

        fun parse(json: String): DevelopVectors {
            val root = JSONObject(json)
            val parameters = root.getJSONArray("parameters").let { a -> List(a.length()) { a.getString(it) } }
            val vectors = root.getJSONArray("vectors").let { a ->
                List(a.length()) { i ->
                    val o = a.getJSONObject(i)
                    val params = o.getJSONObject("params")
                    val values = params.keys().asSequence().associateWith { params.getDouble(it) }
                    val lut = when (o.optString("curve", "")) {
                        "invert" -> INVERT_LUT
                        "" -> DevelopSettings.IDENTITY_LUT
                        else -> error("Unknown curve ${o.getString("curve")}")
                    }
                    val uv = o.optJSONArray("uv")
                    Vector(
                        name = o.getString("name"),
                        settings = DevelopSettings.fromMap(values, lut),
                        input = o.getJSONArray("input").let { c -> IntArray(3) { c.getInt(it) } },
                        expected = o.getJSONArray("expected").let { c -> IntArray(3) { c.getInt(it) } },
                        u = uv?.getDouble(0) ?: 0.5,
                        v = uv?.getDouble(1) ?: 0.5,
                    )
                }
            }
            return DevelopVectors(parameters, vectors)
        }
    }
}
