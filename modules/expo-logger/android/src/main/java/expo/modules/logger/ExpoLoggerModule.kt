package expo.modules.logger

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
            ExpoLoggerCore.getInstance().logInfo(message)
        }

        AsyncFunction("logWarning") { message: String ->
            ExpoLoggerCore.getInstance().logWarning(message)
        }

        AsyncFunction("logError") { message: String ->
            ExpoLoggerCore.getInstance().logError(message)
        }

        AsyncFunction("getLogCount") {
            ExpoLoggerCore.getInstance().getLogCount()
        }
        
        AsyncFunction("resetLogCount") {
            ExpoLoggerCore.getInstance().resetCount()
        }
    }
}
