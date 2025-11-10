package com.turbodeviceinfo

import android.os.Build
import android.util.Log
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.module.annotations.ReactModule

// Legacy module for Android (works with new arch too)
// iOS uses proper TurboModule with codegen
@ReactModule(name = TurboDeviceInfoModule.NAME)
class TurboDeviceInfoModule(reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext) {

    override fun getName(): String = NAME

    @ReactMethod(isBlockingSynchronousMethod = true)
    fun getDeviceName(): String {
        return Build.MODEL
    }

    @ReactMethod(isBlockingSynchronousMethod = true)
    fun getSystemVersion(): String {
        return Build.VERSION.RELEASE
    }

    @ReactMethod(isBlockingSynchronousMethod = true)
    fun getBundleId(): String {
        return reactApplicationContext.packageName
    }

    @ReactMethod(isBlockingSynchronousMethod = true)
    fun getDeviceModel(): String {
        val model = "${Build.MANUFACTURER} ${Build.MODEL}"
        Log.d(TAG, "🔵 [CustomDeviceInfo] getDeviceModel() = $model")
        return model
    }

    companion object {
        const val NAME = "CustomDeviceInfo"
        private const val TAG = "CustomDeviceInfo"
    }
}
