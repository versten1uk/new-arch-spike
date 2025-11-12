package com.newarchspike.turbomodules

import android.os.Build
import android.util.Log
import com.facebook.react.bridge.ReactApplicationContext
import com.newarchspike.specs.NativeTurboDeviceInfoSpec

/**
 * TurboDeviceInfo - Proper Kotlin TurboModule (following official docs)
 * 
 * Extends the generated NativeTurboDeviceInfoSpec abstract class
 * No C++ needed - pure Kotlin TurboModule!
 * 
 * Implements device info directly using Android APIs (self-contained)
 */
class TurboDeviceInfoModule(reactContext: ReactApplicationContext) : 
    NativeTurboDeviceInfoSpec(reactContext) {

    override fun getName() = NAME

    override fun getDeviceModel(): String {
        // Implement directly using Android APIs (TurboModules should be self-contained)
        val model = "${Build.MANUFACTURER} ${Build.MODEL}"
        Log.d(TAG, "🔵 [TurboDeviceInfo] getDeviceModel() = $model")
        return model
    }

    override fun getDeviceName(): String {
        return Build.MODEL
    }

    override fun getSystemVersion(): String {
        return Build.VERSION.RELEASE
    }

    override fun getBundleId(): String {
        return reactApplicationContext.packageName
    }

    companion object {
        const val NAME = "TurboDeviceInfo"
        private const val TAG = "TurboDeviceInfo"
    }
}

