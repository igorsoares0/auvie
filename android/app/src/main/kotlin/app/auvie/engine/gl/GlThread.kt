package app.auvie.engine.gl

import android.os.Handler
import android.os.HandlerThread
import java.util.concurrent.FutureTask
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlinx.coroutines.suspendCancellableCoroutine

/** The single thread that owns the EGL context. All GL calls run here. */
class GlThread(name: String = "AuvieGL") {
    private val thread = HandlerThread(name).apply { start() }
    private val handler = Handler(thread.looper)

    val isCurrent: Boolean get() = Thread.currentThread() == thread

    fun post(block: Runnable) {
        handler.post(block)
    }

    /** Runs [block] on the GL thread and waits for it. */
    fun <T> runBlocking(block: () -> T): T {
        if (isCurrent) return block()
        val task = FutureTask(block)
        handler.post(task)
        return try {
            task.get()
        } catch (e: java.util.concurrent.ExecutionException) {
            throw e.cause ?: e
        }
    }

    suspend fun <T> call(block: () -> T): T = suspendCancellableCoroutine { cont ->
        handler.post {
            try {
                cont.resume(block())
            } catch (e: Throwable) {
                cont.resumeWithException(e)
            }
        }
    }

    fun quit() {
        thread.quitSafely()
    }
}
