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
    
    init {
        Log.d(TAG, "🚀 [ExpoLoggerCore] Initialized (Pure native, no RN dependencies)")
    }
    
    // Reset count (useful for development when app reloads)
    fun resetCount() {
        logCount = 0
        Log.d(TAG, "🔄 [ExpoLoggerCore] Count reset to 0")
    }
    
    // ========================================
    // BUSINESS LOGIC
    // ========================================
    
    fun logInfo(message: String) {
        Log.i(TAG, message)
        logCount++
        Log.d(TAG, "✅ [ExpoLoggerCore] Info logged, count now: $logCount")
    }
    
    fun logWarning(message: String) {
        Log.w(TAG, message)
        logCount++
        Log.d(TAG, "⚠️ [ExpoLoggerCore] Warning logged, count now: $logCount")
    }
    
    fun logError(message: String) {
        Log.e(TAG, message)
        logCount++
        Log.d(TAG, "❌ [ExpoLoggerCore] Error logged, count now: $logCount")
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

