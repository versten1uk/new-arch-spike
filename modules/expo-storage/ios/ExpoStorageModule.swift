import ExpoModulesCore
import Foundation
import ModuleInterop

/**
 * ExpoStorageModule - Thin Expo Module wrapper
 * 
 * This is a THIN WRAPPER that exposes StorageCore to JavaScript.
 * All business logic and state live in StorageCore.
 * 
 * Benefits:
 * - StorageCore can be called from JS (via this module) or natively (via ModuleInterop)
 * - StorageCore can be unit tested without React Native
 * - State is owned by StorageCore, not by the wrapper
 */
public class ExpoStorageModule: Module {
    
    public func definition() -> ModuleDefinition {
        Name("ExpoStorage")
        
        AsyncFunction("setItem") { (key: String, value: String) in
            print("🔵 [ExpoStorageModule] setItem called with key='\(key)' value='\(value)'")
            
            // BRIDGELESS NATIVE-TO-NATIVE CALL: Expo Module → ModuleInterop (NO REFLECTION!)
            let deviceModel = ModuleInterop.shared().getDeviceModel()
            print("✅ [BRIDGELESS] ExpoStorage → ModuleInterop: Got '\(deviceModel)'")
            
            // Store value WITH device model appended to prove the call worked
            let enrichedValue = "\(value) [Device: \(deviceModel)]"
            
            // Delegate to Core (which owns the state)
            StorageCore.shared().setItem(key, value: enrichedValue)
        }
        
        AsyncFunction("getItem") { (key: String) -> String? in
            // Delegate to Core (which owns the state)
            return StorageCore.shared().getItem(key)
        }
        
        AsyncFunction("removeItem") { (key: String) in
            // Delegate to Core (which owns the state)
            StorageCore.shared().removeItem(key)
        }
        
        AsyncFunction("getAllKeys") { () -> [String] in
            // Delegate to Core (which owns the state)
            return StorageCore.shared().getAllKeys() as? [String] ?? []
        }
    }
}
