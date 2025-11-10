package expo.modules.logger

import android.util.Log
import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

class ExpoLoggerModule : Module() {
    override fun definition() = ModuleDefinition {
        Name("ExpoLogger")

        AsyncFunction("logInfo") { message: String ->
            Log.i(TAG, message)
            // BRIDGELESS: Increment count via interop (shared with TurboModules)
            ExpoLoggerInterop.getInstance(appContext.reactContext!!).incrementCount()
        }

        AsyncFunction("logWarning") { message: String ->
            Log.w(TAG, message)
            ExpoLoggerInterop.getInstance(appContext.reactContext!!).incrementCount()
        }

        AsyncFunction("logError") { message: String ->
            Log.e(TAG, message)
            ExpoLoggerInterop.getInstance(appContext.reactContext!!).incrementCount()
        }

        AsyncFunction("getLogCount") {
            // BRIDGELESS: Read count via interop (TurboModules can write to this!)
            val count = ExpoLoggerInterop.getInstance(appContext.reactContext!!).getCount()
            Log.d(TAG, "📊 [BRIDGELESS] ExpoLogger.getLogCount() = $count")
            count
        }
    }

    companion object {
        private const val TAG = "ExpoLogger"
    }
}
