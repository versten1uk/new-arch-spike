import ExpoModulesCore
import os.log

public class ExpoLoggerModule: Module {
    private let logger = OSLog(subsystem: "com.newarchspike", category: "ExpoLogger")
    
    public func definition() -> ModuleDefinition {
        Name("ExpoLogger")
        
        AsyncFunction("logInfo") { (message: String) in
            os_log("%{public}@", log: self.logger, type: .info, message)
            // BRIDGELESS: Increment count via interop (shared with TurboModules)
            ExpoLoggerInterop.shared().incrementCount()
        }
        
        AsyncFunction("logWarning") { (message: String) in
            os_log("%{public}@", log: self.logger, type: .default, message)
            ExpoLoggerInterop.shared().incrementCount()
        }
        
        AsyncFunction("logError") { (message: String) in
            os_log("%{public}@", log: self.logger, type: .error, message)
            ExpoLoggerInterop.shared().incrementCount()
        }
        
        AsyncFunction("getLogCount") { () -> Int in
            // BRIDGELESS: Read count via interop (TurboModules can write to this!)
            let count = ExpoLoggerInterop.shared().getCount()
            NSLog("📊 [BRIDGELESS] ExpoLogger.getLogCount() = %d", count)
            return Int(count)
        }
    }
}
