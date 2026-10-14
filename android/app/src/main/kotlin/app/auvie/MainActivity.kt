package app.auvie

import android.content.pm.ApplicationInfo
import android.os.Bundle
import android.os.StrictMode
import app.auvie.engine.AuvieEnginePlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        if (applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE != 0) {
            // Disk or network on the main thread risks an ANR: log it while
            // developing, so it is caught before it ships.
            StrictMode.setThreadPolicy(
                StrictMode.ThreadPolicy.Builder().detectDiskReads().detectDiskWrites()
                    .detectNetwork().penaltyLog().build(),
            )
        }
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(AuvieEnginePlugin())
    }
}
