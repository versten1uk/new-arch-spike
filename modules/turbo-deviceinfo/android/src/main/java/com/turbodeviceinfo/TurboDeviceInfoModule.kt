package com.turbodeviceinfo

import android.os.Build
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.module.annotations.ReactModule

@ReactModule(name = TurboDeviceInfoModule.NAME)
class TurboDeviceInfoModule(private val reactContext: ReactApplicationContext) :
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
        return reactContext.packageName
    }

    @ReactMethod(isBlockingSynchronousMethod = true)
    fun getDeviceModel(): String {
        return getDeviceModelNative()
    }
    
    // Native-only method - can be called directly from other native modules
    // This works in bridgeless mode!
    fun getDeviceModelNative(): String {
        return "${Build.MANUFACTURER} ${Build.MODEL}"
    }

    companion object {
        const val NAME = "TurboDeviceInfo"
    }
}

