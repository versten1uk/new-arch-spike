package com.turbocalculator

import android.util.Log
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.module.annotations.ReactModule
import com.simplelogger.SimpleLoggerModule

@ReactModule(name = TurboCalculatorModule.NAME)
class TurboCalculatorModule(private val reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext) {

    override fun getName(): String = NAME

    @ReactMethod(isBlockingSynchronousMethod = true)
    fun add(a: Double, b: Double): Double {
        val result = a + b
        
        // DIRECT NATIVE-TO-NATIVE CALL: TurboModule calling Native Module
        // This works in bridgeless mode!
        val logger = reactContext.getNativeModule(SimpleLoggerModule::class.java)
        logger?.logNatively("[NATIVE] TurboCalculator.add($a, $b) = $result")
        
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
            return 0.0
        }
        return a / b
    }

    companion object {
        const val NAME = "TurboCalculator"
    }
}

