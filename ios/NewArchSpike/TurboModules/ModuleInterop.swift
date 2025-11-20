import Foundation
import ExpoLogger
import ExpoStorage

/**
 * Centralized Interop Layer for all module-to-module communication
 *
 * This class provides a single entry point for cross-module calls,
 * eliminating the need for reflection or direct module dependencies.
 *
 * In production, this will live inside cg-webview and provide access
 * to AppsFlyer, Firebase, Snowplow, and other modules.
 */
@objc class ModuleInterop: NSObject {
    @objc static let shared = ModuleInterop()
    
    private override init() {
        super.init()
        // Private initializer to enforce singleton pattern
    }
    
    // ========================================
    // LOGGER INTEROP (delegates to ExpoLoggerCore)
    // ========================================
    
    @objc func logInfo(_ message: String) {
        ExpoLoggerCore.shared.logInfo(message)
    }
    
    @objc func getLogCount() -> Int {
        return ExpoLoggerCore.shared.getLogCount()
    }
    
    @objc func resetCount() {
        ExpoLoggerCore.shared.resetCount()
    }
    
    // ========================================
    // STORAGE INTEROP (delegates to StorageCore)
    // ========================================
    
    @objc func setItem(_ key: String, value: String) {
        StorageCore.shared.setItem(key, value: value)
    }
    
    @objc func getItem(_ key: String) -> String? {
        return StorageCore.shared.getItem(key)
    }
}

