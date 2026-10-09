package app.auvie.engine.preview

import com.google.common.truth.Truth.assertThat
import org.junit.Test

class RenderSchedulerTest {
    private val posted = ArrayDeque<Runnable>()
    private var renders = 0
    private val scheduler = RenderScheduler(posted::addLast) { renders++ }

    @Test
    fun `many requests before the frame render once`() {
        repeat(5) { scheduler.request() }
        assertThat(posted).hasSize(1)

        posted.removeFirst().run()
        assertThat(renders).isEqualTo(1)
    }

    @Test
    fun `a request after the render schedules another`() {
        scheduler.request()
        posted.removeFirst().run()
        scheduler.request()
        assertThat(posted).hasSize(1)
        posted.removeFirst().run()
        assertThat(renders).isEqualTo(2)
    }

    @Test
    fun `a request during the render is not lost`() {
        val reentrant = ArrayDeque<Runnable>()
        lateinit var s: RenderScheduler
        s = RenderScheduler(reentrant::addLast) {
            renders++
            if (renders == 1) s.request()
        }
        s.request()
        reentrant.removeFirst().run()
        assertThat(reentrant).hasSize(1)
    }
}
