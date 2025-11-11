package com.turbocalculator

import android.util.Log
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.module.annotations.ReactModule
import com.moduleinterop.ModuleInterop

// Legacy module for Android (works with new arch too)
// iOS uses proper TurboModule with codegen
@ReactModule(name = TurboCalculatorModule.NAME)
class TurboCalculatorModule(reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext) {

    override fun getName(): String = NAME

    @ReactMethod(isBlockingSynchronousMethod = true)
    fun add(a: Double, b: Double): Double {
        val result = a + b

        // BRIDGELESS NATIVE-TO-NATIVE CALL: TurboModule → ModuleInterop (NO REFLECTION!)
        try {
            val interop = ModuleInterop.getInstance(reactApplicationContext)
            interop.incrementLogCount()
            Log.d(TAG, "✅ [BRIDGELESS] TurboCalculator → ModuleInterop: Incremented log count")
        } catch (e: Exception) {
            Log.e(TAG, "❌ [TurboCalculator] Failed to call ModuleInterop: ${e.message}")
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
