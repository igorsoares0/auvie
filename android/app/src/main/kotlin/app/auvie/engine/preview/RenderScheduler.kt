package app.auvie.engine.preview

import java.util.concurrent.atomic.AtomicBoolean

/**
 * Coalesces render requests: however many arrive before the render thread
 * gets to it, [render] runs once and reads the latest state.
 */
class RenderScheduler(
    private val post: (Runnable) -> Unit,
    private val render: () -> Unit,
) {
    private val pending = AtomicBoolean(false)

    fun request() {
        if (pending.compareAndSet(false, true)) {
            post(Runnable {
                pending.set(false)
                render()
            })
        }
    }
}
