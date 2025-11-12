package expo.modules.storage

import android.util.Log
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
            
            // Delegate to Core (which owns the state)
            StorageCore.getInstance().setItem(key, value)
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
