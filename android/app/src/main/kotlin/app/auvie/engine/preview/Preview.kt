package app.auvie.engine.preview

import app.auvie.engine.develop.DevelopSettings

/** A developed photo or video shown in a Flutter `Texture`. Platform thread. */
interface Preview {
    val id: Long

    fun update(settings: DevelopSettings)

    fun setShowOriginal(original: Boolean)

    /** The next frame renders at [width]×[height]. */
    fun resize(width: Int, height: Int)

    fun dispose()
}
