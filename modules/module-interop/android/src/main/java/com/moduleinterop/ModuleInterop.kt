package com.moduleinterop

import android.content.Context
import android.util.Log
import expo.modules.logger.ExpoLoggerCore
import com.turbodeviceinfo.DeviceInfoCore

/**
 * Centralized Interop Layer for all module-to-module communication
 * 
 * This class provides a single entry point for cross-module calls,
 * eliminating the need for reflection or direct module dependencies.
 * 
 * IMPORTANT: This is a STATELESS FACADE - it delegates to Core classes.
 * Each Core class owns its own state and business logic.
 * 
 * In production, this will live inside cg-webview and provide access
 * to AppsFlyer, Firebase, Snowplow, and other modules.
 */
class ModuleInterop private constructor(private val context: Context) {
    
    // ========================================
    // LOGGER INTEROP (delegates to ExpoLoggerCore)
    // ========================================
    
    fun incrementLogCount() {
        // Delegate to ExpoLoggerCore (which owns the state)
        ExpoLoggerCore.getInstance().logInfo("[ModuleInterop] Log triggered")
        Log.d(TAG, "✅ [BRIDGELESS] ModuleInterop → ExpoLoggerCore: Delegated log call")
    }
    
    fun getLogCount(): Int {
        // Delegate to ExpoLoggerCore (which owns the state)
        return ExpoLoggerCore.getInstance().getLogCount()
    }
    
    // ========================================
    // DEVICE INFO INTEROP (delegates to DeviceInfoCore)
    // ========================================
    
    fun getDeviceModel(): String {
        // Delegate to DeviceInfoCore (which owns the logic)
        return DeviceInfoCore.getInstance(context).getDeviceModel()
    }
    
    fun getDeviceName(): String {
        return DeviceInfoCore.getInstance(context).getDeviceName()
    }
    
    fun getSystemVersion(): String {
        return DeviceInfoCore.getInstance(context).getSystemVersion()
    }
    
    fun getBundleId(): String {
        return DeviceInfoCore.getInstance(context).getBundleId()
    }
    
    // ========================================
    // SINGLETON
    // ========================================
    
    companion object {
        private const val TAG = "ModuleInterop"
        
        @Volatile
        private var instance: ModuleInterop? = null
        
        @JvmStatic
        fun getInstance(context: Context): ModuleInterop {
            return instance ?: synchronized(this) {
                instance ?: ModuleInterop(context).also { 
                    instance = it
                    Log.d(TAG, "🚀 [ModuleInterop] Initialized centralized interop layer (STATELESS FACADE)")
                }
            }
        }
    }
}

