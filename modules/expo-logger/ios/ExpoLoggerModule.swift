import ExpoModulesCore

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
public class ExpoLoggerModule: Module {
    
    public func definition() -> ModuleDefinition {
        Name("ExpoLogger")
        
        AsyncFunction("logInfo") { (message: String) in
            // Delegate to Core (which owns the logic and state)
            ExpoLoggerCore.shared.logInfo(message)
        }
        
        AsyncFunction("logWarning") { (message: String) in
            // Delegate to Core (which owns the logic and state)
            ExpoLoggerCore.shared.logWarning(message)
        }
        
        AsyncFunction("logError") { (message: String) in
            // Delegate to Core (which owns the logic and state)
            ExpoLoggerCore.shared.logError(message)
        }
        
        AsyncFunction("getLogCount") { () -> Int in
            let count = ExpoLoggerCore.shared.getLogCount()
            return Int(count)
        }
        
        AsyncFunction("resetLogCount") { () in
            // Reset count (useful for development/testing)
            ExpoLoggerCore.shared.resetCount()
        }
    }
}
