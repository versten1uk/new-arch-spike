package expo.modules.storage

import android.util.Log
import com.moduleinterop.ModuleInterop
import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

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
class ExpoStorageModule : Module() {

    override fun definition() = ModuleDefinition {
        Name("ExpoStorage")

        AsyncFunction("setItem") { key: String, value: String ->
            Log.d(TAG, "🔵 [ExpoStorageModule] setItem called with key='$key' value='$value'")

            // BRIDGELESS NATIVE-TO-NATIVE CALL: Expo Module → ModuleInterop (NO REFLECTION!)
            val deviceModel = try {
                val interop = ModuleInterop.getInstance(appContext.reactContext!!)
                val model = interop.getDeviceModel()
                Log.d(TAG, "✅ [BRIDGELESS] ExpoStorage → ModuleInterop: Got '$model'")
                model
            } catch (e: Exception) {
                Log.e(TAG, "❌ [ExpoStorage] Failed to call ModuleInterop: ${e.message}")
                e.printStackTrace()
                "unknown"
            }

            // Store value WITH device model appended to prove the call worked
            val enrichedValue = "$value [Device: $deviceModel]"
            
            // Delegate to Core (which owns the state)
            StorageCore.getInstance().setItem(key, enrichedValue)
        }

        AsyncFunction("getItem") { key: String ->
            // Delegate to Core (which owns the state)
            StorageCore.getInstance().getItem(key)
        }

        AsyncFunction("removeItem") { key: String ->
            // Delegate to Core (which owns the state)
            StorageCore.getInstance().removeItem(key)
        }

        AsyncFunction("getAllKeys") {
            // Delegate to Core (which owns the state)
            StorageCore.getInstance().getAllKeys()
        }
    }

    companion object {
        private const val TAG = "ExpoStorage"
    }
}
