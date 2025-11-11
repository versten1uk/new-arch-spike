package expo.modules.storage

import android.util.Log
import com.turbodeviceinfo.TurboDeviceInfoInterop
import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

class ExpoStorageModule : Module() {
    private val storage = mutableMapOf<String, String>()

    override fun definition() = ModuleDefinition {
        Name("ExpoStorage")

        AsyncFunction("setItem") { key: String, value: String ->
            Log.d(TAG, "🔵 [ExpoStorage] setItem called with key='$key' value='$value'")
            
            // BRIDGELESS NATIVE-TO-NATIVE CALL: Expo Module → TurboModule (NO REFLECTION!)
            val deviceModel = try {
                val interop = TurboDeviceInfoInterop.getInstance(appContext.reactContext!!)
                val model = interop.getDeviceModel()
                Log.d(TAG, "✅ [BRIDGELESS] ExpoStorage → TurboDeviceInfo: Got '$model'")
                model
            } catch (e: Exception) {
                Log.e(TAG, "❌ [ExpoStorage] Failed to call TurboDeviceInfo: ${e.message}")
                e.printStackTrace()
                "unknown"
            }
            
            // Store value WITH device model appended to prove the call worked
            val enrichedValue = "$value [Device: $deviceModel]"
            storage[key] = enrichedValue
            
            Log.d(TAG, "📦 [ExpoStorage] Stored: '$key' = '$enrichedValue'")
        }

        AsyncFunction("getItem") { key: String ->
            storage[key]
        }

        AsyncFunction("removeItem") { key: String ->
            storage.remove(key)
        }

        AsyncFunction("getAllKeys") {
            storage.keys.toList()
        }
    }

    companion object {
        private const val TAG = "ExpoStorage"
    }
}
