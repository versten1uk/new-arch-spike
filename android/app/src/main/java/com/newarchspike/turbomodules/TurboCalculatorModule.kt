package com.newarchspike.turbomodules

import com.facebook.react.bridge.ReactApplicationContext
import com.moduleinterop.ModuleInterop
import com.newarchspike.specs.NativeTurboCalculatorSpec

/**
 * TurboCalculator - Proper Kotlin TurboModule (following official docs)
 * 
 * Extends the generated NativeTurboCalculatorSpec abstract class
 * No C++ needed - pure Kotlin TurboModule!
 */
class TurboCalculatorModule(reactContext: ReactApplicationContext) : 
    NativeTurboCalculatorSpec(reactContext) {

    override fun getName() = NAME

    override fun add(a: Double, b: Double): Double {
        val result = a + b

        // BRIDGELESS NATIVE-TO-NATIVE CALL: TurboModule → ModuleInterop → ExpoLogger
        try {
            val interop = ModuleInterop.getInstance(reactApplicationContext)
            interop.logInfo("TurboCalculator: $a + $b = $result")
        } catch (e: Exception) {
            // Failed to call ModuleInterop
        }

        return result
    }

    override fun subtract(a: Double, b: Double): Double {
        return a - b
    }

    override fun multiply(a: Double, b: Double): Double {
        return a * b
    }

    override fun divide(a: Double, b: Double): Double {
        if (b == 0.0) {
            return 0.0
        }
        return a / b
    }

    companion object {
        const val NAME = "TurboCalculator"
    }
}

