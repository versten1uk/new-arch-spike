package expo.modules.logger

import android.util.Log

/**
 * ExpoLoggerCore - Pure native business logic (NO React Native dependencies)
 * 
 * This class owns the logger state and contains all business logic.
 * It can be called from:
 * - ExpoLoggerModule (Expo Module for JavaScript)
 * - ModuleInterop (for other native modules like cg-webview)
 * - Unit tests (no RN runtime needed)
 */
class ExpoLoggerCore private constructor() {
    
    private var logCount: Int = 0
    
    // Reset count (useful for development when app reloads)
    fun resetCount() {
        logCount = 0
    }
    
    // ========================================
    // BUSINESS LOGIC
    // ========================================
    
    fun logInfo(message: String) {
        Log.i(TAG, message)
        logCount++
    }
    
    fun logWarning(message: String) {
        Log.w(TAG, message)
        logCount++
    }
    
    fun logError(message: String) {
        Log.e(TAG, message)
        logCount++
    }
    
    // ========================================
    // STATE MANAGEMENT
    // ========================================
    
    fun getLogCount(): Int {
        return logCount
    }
    
    companion object {
        private const val TAG = "ExpoLoggerCore"
        
        @Volatile
        private var instance: ExpoLoggerCore? = null
        
        @JvmStatic
        fun getInstance(): ExpoLoggerCore {
            return instance ?: synchronized(this) {
                instance ?: ExpoLoggerCore().also { instance = it }
            }
        }
    }
}

