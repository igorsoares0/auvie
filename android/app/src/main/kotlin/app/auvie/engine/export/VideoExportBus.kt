package app.auvie.engine.export

import app.auvie.engine.pigeon.ExportProgress
import kotlinx.coroutines.channels.BufferOverflow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.SharedFlow

/** Progress from the export worker to the plugin, inside the app process. */
object VideoExportBus {
    private val flow = MutableSharedFlow<ExportProgress>(
        extraBufferCapacity = 64,
        onBufferOverflow = BufferOverflow.DROP_OLDEST,
    )

    val progress: SharedFlow<ExportProgress> = flow

    fun emit(progress: ExportProgress) {
        flow.tryEmit(progress)
    }
}
