package expo.modules.logger

import android.util.Log
import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

class ExpoLoggerModule : Module() {
    private var logCount = 0
    private val TAG = "ExpoLogger"

    override fun definition() = ModuleDefinition {
        Name("ExpoLogger")

        AsyncFunction("logInfo") { message: String ->
            Log.i(TAG, message)
            logCount++
        }

        AsyncFunction("logWarning") { message: String ->
            Log.w(TAG, message)
            logCount++
        }

        AsyncFunction("logError") { message: String ->
            Log.e(TAG, message)
            logCount++
        }

        AsyncFunction("getLogCount") {
            logCount
        }
    }
}

