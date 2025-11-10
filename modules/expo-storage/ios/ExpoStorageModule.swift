import ExpoModulesCore
import Foundation

public class ExpoStorageModule: Module {
    private var storage: [String: String] = [:]
    
    public func definition() -> ModuleDefinition {
        Name("ExpoStorage")
        
        AsyncFunction("setItem") { (key: String, value: String) in
            NSLog("🔵 [ExpoStorage] setItem called with key='%@' value='%@'", key, value)
            
            // BRIDGELESS NATIVE-TO-NATIVE CALL: Expo Module → TurboModule
            var deviceModel = "unknown"
            
            // Direct instantiation of TurboDeviceInfo (BRIDGELESS approach)
            NSLog("🔍 [ExpoStorage] Looking for TurboDeviceInfo class...")
            if let turboDeviceInfoClass = NSClassFromString("TurboDeviceInfo") as? NSObject.Type {
                NSLog("✓ [ExpoStorage] Found TurboDeviceInfo class, creating instance...")
                let turboDeviceInfo = turboDeviceInfoClass.init()
                let selector = NSSelectorFromString("getDeviceModel")
                
                NSLog("🔍 [ExpoStorage] Checking if TurboDeviceInfo responds to getDeviceModel...")
                if turboDeviceInfo.responds(to: selector) {
                    NSLog("✓ [ExpoStorage] TurboDeviceInfo responds to getDeviceModel, calling it...")
                    if let result = turboDeviceInfo.perform(selector)?.takeUnretainedValue() as? String {
                        deviceModel = result
                        NSLog("✅ [BRIDGELESS] ExpoStorage → TurboDeviceInfo: Got '%@'", result)
                    } else {
                        NSLog("❌ [ExpoStorage] perform() returned nil or not a String")
                    }
                } else {
                    NSLog("❌ [ExpoStorage] TurboDeviceInfo does NOT respond to getDeviceModel")
                }
            } else {
                NSLog("❌ [ExpoStorage] TurboDeviceInfo class NOT FOUND")
            }
            
            // Store value WITH device model appended to prove the call worked
            let enrichedValue = "\(value) [Device: \(deviceModel)]"
            self.storage[key] = enrichedValue
            
            NSLog("📦 [ExpoStorage] Stored: '%@' = '%@'", key, enrichedValue)
        }
        
        AsyncFunction("getItem") { (key: String) -> String? in
            return self.storage[key]
        }
        
        AsyncFunction("removeItem") { (key: String) in
            self.storage.removeValue(forKey: key)
        }
        
        AsyncFunction("getAllKeys") { () -> [String] in
            return Array(self.storage.keys)
        }
    }
}
