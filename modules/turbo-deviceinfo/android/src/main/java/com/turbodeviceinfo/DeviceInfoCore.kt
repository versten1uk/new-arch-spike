package com.turbodeviceinfo

import android.content.Context
import android.os.Build
import android.util.Log

/**
 * DeviceInfoCore - Pure native business logic (minimal dependencies)
 * 
 * This class contains all device info logic.
 * It can be called from:
 * - TurboDeviceInfoModule (TurboModule for JavaScript)
 * - ModuleInterop (for other native modules like cg-webview)
 * - Unit tests
 */
class DeviceInfoCore private constructor(private val context: Context) {
    
    init {
        Log.d(TAG, "🚀 [DeviceInfoCore] Initialized (Pure native, minimal RN dependencies)")
    }
    
    // ========================================
    // BUSINESS LOGIC
    // ========================================
    
    fun getDeviceName(): String {
        return Build.MODEL
    }
    
    fun getSystemVersion(): String {
        return Build.VERSION.RELEASE
    }
    
    fun getBundleId(): String {
        return context.packageName
    }
    
    fun getDeviceModel(): String {
        val model = "${Build.MANUFACTURER} ${Build.MODEL}"
        Log.d(TAG, "🔵 [DeviceInfoCore] getDeviceModel() = $model")
        return model
    }
    
    companion object {
        private const val TAG = "DeviceInfoCore"
        
        @Volatile
        private var instance: DeviceInfoCore? = null
        
        @JvmStatic
        fun getInstance(context: Context): DeviceInfoCore {
            return instance ?: synchronized(this) {
                instance ?: DeviceInfoCore(context.applicationContext).also { instance = it }
            }
        }
    }
}

