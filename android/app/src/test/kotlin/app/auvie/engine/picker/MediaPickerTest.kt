package app.auvie.engine.picker

import com.google.common.truth.Truth.assertThat
import java.io.File
import java.nio.file.Files
import org.junit.Test

class MediaPickerTest {
    private val files = Files.createTempDirectory("files").toFile()
    private val media = File(files, "projects/media").apply { mkdirs() }

    @Test
    fun `only the app's own copies can be deleted`() {
        assertThat(MediaPicker.isPrivateCopy(File(media, "a.jpg"), media)).isTrue()
        assertThat(MediaPicker.isPrivateCopy(File(files, "auvie.db"), media)).isFalse()
        assertThat(MediaPicker.isPrivateCopy(File(media, "sub/a.jpg"), media)).isFalse()
        // A path that climbs out of the folder doesn't count.
        assertThat(MediaPicker.isPrivateCopy(File(media, "../../auvie.db"), media)).isFalse()
    }
}
