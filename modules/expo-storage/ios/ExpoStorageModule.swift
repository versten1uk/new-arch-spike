import ExpoModulesCore
import Foundation
import ModuleInterop

public class ExpoStorageModule: Module {
    private var storage: [String: String] = [:]
    
    public func definition() -> ModuleDefinition {
        Name("ExpoStorage")
        
        AsyncFunction("setItem") { (key: String, value: String) in
            print("🔵 [ExpoStorage] setItem called with key='\(key)' value='\(value)'")
            
            // BRIDGELESS NATIVE-TO-NATIVE CALL: Expo Module → ModuleInterop (NO REFLECTION!)
            let deviceModel = ModuleInterop.shared().getDeviceModel()
            print("✅ [BRIDGELESS] ExpoStorage → ModuleInterop: Got '\(deviceModel)'")
            
            // Store value WITH device model appended to prove the call worked
            let enrichedValue = "\(value) [Device: \(deviceModel)]"
            self.storage[key] = enrichedValue
            
            print("📦 [ExpoStorage] Stored: '\(key)' = '\(enrichedValue)'")
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
