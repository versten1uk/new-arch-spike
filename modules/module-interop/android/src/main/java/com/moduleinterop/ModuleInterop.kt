package com.moduleinterop

import android.content.Context
import android.util.Log
import expo.modules.logger.ExpoLoggerCore
import expo.modules.storage.StorageCore

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
    
    fun logInfo(message: String) {
        // Delegate to ExpoLoggerCore (which owns the state)
        ExpoLoggerCore.getInstance().logInfo(message)
        Log.d(TAG, "✅ [BRIDGELESS] ModuleInterop → ExpoLoggerCore: Logged '$message'")
    }
    
    fun getLogCount(): Int {
        // Delegate to ExpoLoggerCore (which owns the state)
        return ExpoLoggerCore.getInstance().getLogCount()
    }
    
    fun resetCount() {
        // Delegate to ExpoLoggerCore (which owns the state)
        ExpoLoggerCore.getInstance().resetCount()
        Log.d(TAG, "✅ [BRIDGELESS] ModuleInterop → ExpoLoggerCore: Reset log count")
    }
    
    // ========================================
    // STORAGE INTEROP (delegates to StorageCore)
    // ========================================
    
    fun setItem(key: String, value: String) {
        // Delegate to StorageCore (which owns the state)
        StorageCore.getInstance().setItem(key, value)
        Log.d(TAG, "✅ [BRIDGELESS] ModuleInterop → StorageCore: Set '$key'='$value'")
    }
    
    fun getItem(key: String): String? {
        // Delegate to StorageCore (which owns the state)
        return StorageCore.getInstance().getItem(key)
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

