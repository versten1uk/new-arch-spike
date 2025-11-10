package expo.modules.storage

import android.util.Log
import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

class ExpoStorageModule : Module() {
    private val storage = mutableMapOf<String, String>()

    override fun definition() = ModuleDefinition {
        Name("ExpoStorage")

        AsyncFunction("setItem") { key: String, value: String ->
            Log.d(TAG, "🔵 [ExpoStorage] setItem called with key='$key' value='$value'")
            
            // BRIDGELESS NATIVE-TO-NATIVE CALL: Expo Module → TurboModule
            var deviceModel = "unknown"
            
            try {
                Log.d(TAG, "🔍 [ExpoStorage] Looking for TurboDeviceInfo class...")
                
                // Direct instantiation using reflection (Android's NSClassFromString)
                val deviceInfoClass = Class.forName("com.turbodeviceinfo.TurboDeviceInfoModule")
                Log.d(TAG, "✓ [ExpoStorage] Found TurboDeviceInfo class, creating instance...")
                
                val constructor = deviceInfoClass.getConstructor(
                    com.facebook.react.bridge.ReactApplicationContext::class.java
                )
                val deviceInfo = constructor.newInstance(appContext.reactContext!!)
                
                Log.d(TAG, "🔍 [ExpoStorage] Checking if TurboDeviceInfo has getDeviceModel...")
                val method = deviceInfoClass.getMethod("getDeviceModel")
                
                Log.d(TAG, "✓ [ExpoStorage] TurboDeviceInfo has getDeviceModel, calling it...")
                deviceModel = method.invoke(deviceInfo) as String
                
                Log.d(TAG, "✅ [BRIDGELESS] ExpoStorage → TurboDeviceInfo: Got '$deviceModel'")
            } catch (e: Exception) {
                Log.e(TAG, "❌ [ExpoStorage] Failed to call TurboDeviceInfo: ${e.message}")
                e.printStackTrace()
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
