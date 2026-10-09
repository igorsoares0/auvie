package app.auvie.engine.export

import android.graphics.Bitmap
import android.graphics.Canvas
import android.net.Uri
import app.auvie.engine.develop.DevelopSettings
import app.auvie.engine.gl.GlEngine
import app.auvie.engine.media.MediaLoader
import app.auvie.engine.pigeon.ExportFormat
import app.auvie.engine.pigeon.ExportRequest
import app.auvie.engine.pigeon.ExportResult
import kotlin.coroutines.coroutineContext
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ensureActive
import kotlinx.coroutines.withContext

/**
 * Full-size photo export: decode only what the crop needs → upload →
 * free the bitmap → render tile by tile into one output → encode → copy
 * metadata → save to the gallery. Cancellable between steps and tiles.
 */
class PhotoExporter(
    private val engine: GlEngine,
    private val loader: MediaLoader,
    private val store: ExportStore,
    private val gallery: GallerySaver,
    private val metadata: MetadataCopier,
    private val tileSize: Int = ExportPlanner.TILE,
) {
    /** [progress] gets (0…1, stage) with stage decode, render, encode or save. */
    suspend fun export(request: ExportRequest, progress: (Double, String) -> Unit): ExportResult {
        val settings = DevelopSettings.from(request.params)
        val size = ExportPlanner.clampOutput(request.outputWidth.toInt(), request.outputHeight.toInt())
        val uri = Uri.parse(request.uri)

        progress(0.0, STAGE_DECODE)
        val maxTexture = engine.thread.call { engine.maxTextureSize }
        val decodePx = minOf(request.decodeMaxPx.toInt(), maxTexture)
        val decoded = withContext(Dispatchers.IO) { loader.decodePhoto(uri, decodePx) }
        coroutineContext.ensureActive()
        val source = try {
            engine.thread.call { engine.upload(decoded.bitmap) }
        } finally {
            decoded.bitmap.recycle()
        }

        val output: Bitmap
        try {
            progress(RENDER_START, STAGE_RENDER)
            output = Bitmap.createBitmap(size.width, size.height, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(output)
            val tiles = ExportPlanner.tiles(size.width, size.height, tileSize)
            try {
                tiles.forEachIndexed { i, tile ->
                    coroutineContext.ensureActive()
                    val part = engine.thread.call {
                        engine.renderTile(source, settings, size.width, size.height, tile)
                    }
                    canvas.drawBitmap(part, tile.x.toFloat(), tile.y.toFloat(), null)
                    part.recycle()
                    progress(RENDER_START + (ENCODE_START - RENDER_START) * (i + 1) / tiles.size, STAGE_RENDER)
                }
            } catch (e: Throwable) {
                output.recycle()
                throw e
            }
        } finally {
            engine.thread.call { source.release() }
        }

        val file = store.newFile(ExportPlanner.fileName(request.fileName, request.format))
        try {
            progress(ENCODE_START, STAGE_ENCODE)
            withContext(Dispatchers.IO) {
                try {
                    file.outputStream().use {
                        val format = when (request.format) {
                            ExportFormat.JPEG -> Bitmap.CompressFormat.JPEG
                            ExportFormat.PNG -> Bitmap.CompressFormat.PNG
                        }
                        check(output.compress(format, ExportPlanner.JPEG_QUALITY, it)) { "Encoding failed" }
                    }
                } finally {
                    output.recycle()
                }
                if (request.keepMetadata && request.format == ExportFormat.JPEG) {
                    metadata.copy(uri, file)
                }
            }
            coroutineContext.ensureActive()

            progress(SAVE_START, STAGE_SAVE)
            val mediaUri = withContext(Dispatchers.IO) {
                gallery.save(file, file.name, ExportPlanner.mimeType(request.format))
            }
            progress(1.0, STAGE_SAVE)
            return ExportResult(
                mediaUri = mediaUri.toString(),
                filePath = file.absolutePath,
                width = size.width.toLong(),
                height = size.height.toLong(),
                bytes = file.length(),
            )
        } catch (e: Throwable) {
            file.delete()
            throw e
        }
    }

    companion object {
        const val STAGE_DECODE = "decode"
        const val STAGE_RENDER = "render"
        const val STAGE_ENCODE = "encode"
        const val STAGE_SAVE = "save"
        private const val RENDER_START = 0.25
        private const val ENCODE_START = 0.75
        private const val SAVE_START = 0.92
    }
}
