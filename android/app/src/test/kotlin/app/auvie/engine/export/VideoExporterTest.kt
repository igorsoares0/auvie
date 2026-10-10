package app.auvie.engine.export

import androidx.media3.transformer.ExportException
import app.auvie.engine.EngineErrors
import app.auvie.engine.pigeon.LayerBlend
import com.google.common.truth.Truth.assertThat
import org.junit.Test

class VideoExporterTest {
    @Test
    fun `Transformer errors map to engine errors`() {
        fun code(c: Int, cause: String? = null) = VideoExporter.errorCode(c, cause)
        assertThat(code(ExportException.ERROR_CODE_DECODING_FORMAT_UNSUPPORTED)).isEqualTo(EngineErrors.DECODE_FAILED)
        assertThat(code(ExportException.ERROR_CODE_DECODER_INIT_FAILED)).isEqualTo(EngineErrors.DECODE_FAILED)
        assertThat(code(ExportException.ERROR_CODE_IO_FILE_NOT_FOUND)).isEqualTo(EngineErrors.MEDIA_UNAVAILABLE)
        assertThat(code(ExportException.ERROR_CODE_IO_NO_PERMISSION)).isEqualTo(EngineErrors.MEDIA_UNAVAILABLE)
        assertThat(code(ExportException.ERROR_CODE_MUXING_FAILED, "write failed: ENOSPC")).isEqualTo(EngineErrors.STORAGE_FULL)
        assertThat(code(ExportException.ERROR_CODE_ENCODER_INIT_FAILED)).isEqualTo(EngineErrors.EXPORT_FAILED)
    }

    @Test
    fun `every blend has its own shader mode`() {
        val modes = LayerBlend.entries.map(LayerEffect::blendIndex)
        assertThat(modes).containsExactly(0, 1, 2, 3, 4).inOrder()
    }
}
