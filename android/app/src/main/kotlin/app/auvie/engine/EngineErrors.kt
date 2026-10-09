package app.auvie.engine

import app.auvie.engine.pigeon.FlutterError
import java.io.FileNotFoundException
import java.io.IOException

/** Error codes sent to Dart (see lib/core/native/media_engine.dart). */
object EngineErrors {
    const val DECODE_FAILED = "decode_failed"
    const val MEDIA_UNAVAILABLE = "media_unavailable"
    const val NO_ACTIVITY = "no_activity"
    const val PICKER_BUSY = "picker_busy"
    const val INVALID_PARAMS = "invalid_params"
    const val UNKNOWN_TEXTURE = "unknown_texture"

    /** Runs [block] and maps platform exceptions to [FlutterError]s. */
    suspend fun <T> mapping(uri: String, block: suspend () -> T): T =
        try {
            block()
        } catch (e: FlutterError) {
            throw e
        } catch (e: SecurityException) {
            throw FlutterError(MEDIA_UNAVAILABLE, "No access to $uri: ${e.message}")
        } catch (e: FileNotFoundException) {
            throw FlutterError(MEDIA_UNAVAILABLE, "Missing $uri: ${e.message}")
        } catch (e: IOException) {
            throw FlutterError(DECODE_FAILED, "Could not read $uri: ${e.message}")
        } catch (e: IllegalArgumentException) {
            throw FlutterError(INVALID_PARAMS, e.message)
        }
}
