package com.turbocalculator

import android.util.Log
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.module.annotations.ReactModule

// Legacy module for Android (works with new arch too)
// iOS uses proper TurboModule with codegen
@ReactModule(name = TurboCalculatorModule.NAME)
class TurboCalculatorModule(reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext) {

    override fun getName(): String = NAME

    @ReactMethod(isBlockingSynchronousMethod = true)
    fun add(a: Double, b: Double): Double {
        val result = a + b
        Log.d(TAG, "🔵 [TurboCalculator] add called: $a + $b = $result")
        
        // BRIDGELESS NATIVE-TO-NATIVE CALL: TurboModule → Expo Module
        try {
            // Get ExpoLoggerInterop using reflection (Android's equivalent to NSClassFromString)
            val interopClass = Class.forName("expo.modules.logger.ExpoLoggerInterop")
            val getInstance = interopClass.getMethod("getInstance", android.content.Context::class.java)
            val interop = getInstance.invoke(null, reactApplicationContext)
            
            val incrementMethod = interopClass.getMethod("incrementCount")
            incrementMethod.invoke(interop)
            
            Log.d(TAG, "✅ [BRIDGELESS] TurboCalculator → ExpoLogger: Incremented count")
        } catch (e: Exception) {
            Log.e(TAG, "❌ [TurboCalculator] Failed to call ExpoLogger: ${e.message}")
            e.printStackTrace()
        }
        
        return result
    }

    @ReactMethod(isBlockingSynchronousMethod = true)
    fun subtract(a: Double, b: Double): Double {
        return a - b
    }

    @ReactMethod(isBlockingSynchronousMethod = true)
    fun multiply(a: Double, b: Double): Double {
        return a * b
    }

    @ReactMethod(isBlockingSynchronousMethod = true)
    fun divide(a: Double, b: Double): Double {
        if (b == 0.0) {
            Log.e(TAG, "❌ [TurboCalculator] Division by zero")
            return 0.0
        }
        return a / b
    }

    companion object {
        const val NAME = "TurboCalculator"
        private const val TAG = "TurboCalculator"
    }
}
