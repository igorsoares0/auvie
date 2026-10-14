# R8 rules for Auvie's own code. Flutter, Media3, WorkManager and RevenueCat
# ship their own consumer rules; these cover what they can't know about.

# The Pigeon bridge: classes are built from message lists by generated code,
# kept whole so a renamed field can never break a message.
-keep class app.auvie.engine.pigeon.** { *; }

# WorkManager creates the export worker by name, from its stored request.
-keep class app.auvie.engine.export.VideoExportWorker { public <init>(...); }

# Media3 creates GL effects through their interfaces; keep ours readable in
# Play Console stack traces.
-keepnames class app.auvie.engine.** { *; }

# Kotlin metadata isn't needed at runtime.
-dontwarn kotlinx.coroutines.debug.**
