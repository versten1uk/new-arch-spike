package com.moduleinterop

import android.content.Context
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
        ExpoLoggerCore.getInstance().logInfo(message)
    }
    
    fun getLogCount(): Int {
        return ExpoLoggerCore.getInstance().getLogCount()
    }
    
    fun resetCount() {
        ExpoLoggerCore.getInstance().resetCount()
    }
    
    // ========================================
    // STORAGE INTEROP (delegates to StorageCore)
    // ========================================
    
    fun setItem(key: String, value: String) {
        StorageCore.getInstance().setItem(key, value)
    }
    
    fun getItem(key: String): String? {
        return StorageCore.getInstance().getItem(key)
    }
    
    // ========================================
    // SINGLETON
    // ========================================
    
    companion object {
        @Volatile
        private var instance: ModuleInterop? = null
        
        @JvmStatic
        fun getInstance(context: Context): ModuleInterop {
            return instance ?: synchronized(this) {
                instance ?: ModuleInterop(context).also { 
                    instance = it
                }
            }
        }
    }
}

