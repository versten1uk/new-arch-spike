package com.turbodeviceinfo

import android.util.Log
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.module.annotations.ReactModule

/**
 * TurboDeviceInfoModule - Thin TurboModule wrapper
 * 
 * This is a THIN WRAPPER that exposes DeviceInfoCore to JavaScript.
 * All business logic lives in DeviceInfoCore.
 * 
 * Benefits:
 * - DeviceInfoCore can be called from JS (via this module) or natively (via ModuleInterop)
 * - DeviceInfoCore can be unit tested without React Native
 * - Logic is owned by DeviceInfoCore, not by the wrapper
 * 
 * Note: Android uses legacy module for simplicity.
 * iOS uses proper TurboModule with codegen (same delegation pattern).
 */
@ReactModule(name = TurboDeviceInfoModule.NAME)
class TurboDeviceInfoModule(reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext) {

    override fun getName(): String = NAME

    @ReactMethod(isBlockingSynchronousMethod = true)
    fun getDeviceName(): String {
        // Delegate to Core (which owns the logic)
        return DeviceInfoCore.getInstance(reactApplicationContext).getDeviceName()
    }

    @ReactMethod(isBlockingSynchronousMethod = true)
    fun getSystemVersion(): String {
        // Delegate to Core (which owns the logic)
        return DeviceInfoCore.getInstance(reactApplicationContext).getSystemVersion()
    }

    @ReactMethod(isBlockingSynchronousMethod = true)
    fun getBundleId(): String {
        // Delegate to Core (which owns the logic)
        return DeviceInfoCore.getInstance(reactApplicationContext).getBundleId()
    }

    @ReactMethod(isBlockingSynchronousMethod = true)
    fun getDeviceModel(): String {
        // Delegate to Core (which owns the logic)
        val model = DeviceInfoCore.getInstance(reactApplicationContext).getDeviceModel()
        Log.d(TAG, "🔵 [TurboDeviceInfoModule] getDeviceModel() = $model (from Core)")
        return model
    }

    companion object {
        const val NAME = "CustomDeviceInfo"
        private const val TAG = "TurboDeviceInfoModule"
    }
}
