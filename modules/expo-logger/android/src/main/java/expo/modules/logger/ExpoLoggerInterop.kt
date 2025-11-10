package expo.modules.logger

import android.content.Context
import android.util.Log

/**
 * Interop layer for ExpoLogger
 * Allows TurboModules to access ExpoLogger's state
 * Similar to iOS's ExpoLoggerInterop.mm
 */
class ExpoLoggerInterop private constructor(private val context: Context) {
    
    private var logCount: Int = 0
    
    fun incrementCount() {
        logCount++
        Log.d(TAG, "✅ [BRIDGELESS ExpoLoggerInterop] Count incremented to: $logCount")
    }
    
    fun getCount(): Int {
        return logCount
    }
    
    companion object {
        private const val TAG = "ExpoLoggerInterop"
        
        @Volatile
        private var instance: ExpoLoggerInterop? = null
        
        @JvmStatic
        fun getInstance(context: Context): ExpoLoggerInterop {
            return instance ?: synchronized(this) {
                instance ?: ExpoLoggerInterop(context).also { instance = it }
            }
        }
    }
}

