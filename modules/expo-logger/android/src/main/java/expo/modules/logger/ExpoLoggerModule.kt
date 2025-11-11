package expo.modules.logger

import android.util.Log
import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

/**
 * ExpoLoggerModule - Thin Expo Module wrapper
 * 
 * This is a THIN WRAPPER that exposes ExpoLoggerCore to JavaScript.
 * All business logic lives in ExpoLoggerCore.
 * 
 * Benefits:
 * - ExpoLoggerCore can be called from JS (via this module) or natively (via ModuleInterop)
 * - ExpoLoggerCore can be unit tested without React Native
 * - State is owned by ExpoLoggerCore, not by the wrapper
 */
class ExpoLoggerModule : Module() {
    override fun definition() = ModuleDefinition {
        Name("ExpoLogger")

        AsyncFunction("logInfo") { message: String ->
            // Delegate to Core (which owns the logic and state)
            ExpoLoggerCore.getInstance().logInfo(message)
        }

        AsyncFunction("logWarning") { message: String ->
            // Delegate to Core (which owns the logic and state)
            ExpoLoggerCore.getInstance().logWarning(message)
        }

        AsyncFunction("logError") { message: String ->
            // Delegate to Core (which owns the logic and state)
            ExpoLoggerCore.getInstance().logError(message)
        }

        AsyncFunction("getLogCount") {
            // Delegate to Core (which owns the state)
            val count = ExpoLoggerCore.getInstance().getLogCount()
            Log.d(TAG, "📊 [ExpoLoggerModule] getLogCount() = $count (from Core)")
            count
        }
        
        AsyncFunction("resetLogCount") {
            // Reset count (useful for development/testing)
            ExpoLoggerCore.getInstance().resetCount()
        }
    }

    companion object {
        private const val TAG = "ExpoLoggerModule"
    }
}
