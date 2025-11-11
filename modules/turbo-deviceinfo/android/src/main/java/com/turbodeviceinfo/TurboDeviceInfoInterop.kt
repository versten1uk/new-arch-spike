package com.turbodeviceinfo

import android.content.Context
import android.os.Build
import android.util.Log

/**
 * Interop layer for TurboDeviceInfo
 * Allows Expo Modules to access device info without reflection
 * Similar to ExpoLoggerInterop pattern
 */
class TurboDeviceInfoInterop private constructor(private val context: Context) {
    
    fun getDeviceModel(): String {
        val model = "${Build.MANUFACTURER} ${Build.MODEL}"
        Log.d(TAG, "🔵 [TurboDeviceInfoInterop] getDeviceModel() = $model")
        return model
    }
    
    fun getDeviceName(): String {
        return Build.MODEL
    }
    
    fun getSystemVersion(): String {
        return Build.VERSION.RELEASE
    }
    
    fun getBundleId(context: Context): String {
        return context.packageName
    }
    
    companion object {
        private const val TAG = "TurboDeviceInfoInterop"
        
        @Volatile
        private var instance: TurboDeviceInfoInterop? = null
        
        @JvmStatic
        fun getInstance(context: Context): TurboDeviceInfoInterop {
            return instance ?: synchronized(this) {
                instance ?: TurboDeviceInfoInterop(context).also { instance = it }
            }
        }
    }
}

