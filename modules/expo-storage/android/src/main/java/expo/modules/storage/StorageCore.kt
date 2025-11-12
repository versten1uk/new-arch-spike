package expo.modules.storage

import android.util.Log

/**
 * StorageCore - Pure native business logic (NO React Native dependencies)
 * 
 * This class owns the storage state and contains all storage logic.
 * It can be called from:
 * - ExpoStorageModule (Expo Module for JavaScript)
 * - ModuleInterop (for other native modules if needed)
 * - Unit tests (no RN runtime needed)
 */
class StorageCore private constructor() {
    
    private val storage = mutableMapOf<String, String>()
    
    init {
        Log.d(TAG, "🚀 [StorageCore] Initialized (Pure native, no RN dependencies)")
    }
    
    // ========================================
    // BUSINESS LOGIC
    // ========================================
    
    fun setItem(key: String, value: String) {
        Log.d(TAG, "📦 [StorageCore] setItem: '$key' = '$value'")
        storage[key] = value
    }
    
    fun getItem(key: String): String? {
        return storage[key]
    }
    
    fun removeItem(key: String) {
        storage.remove(key)
    }
    
    fun getAllKeys(): List<String> {
        return storage.keys.toList()
    }
    
    fun clear() {
        storage.clear()
        Log.d(TAG, "🔄 [StorageCore] Storage cleared")
    }
    
    companion object {
        private const val TAG = "StorageCore"
        
        @Volatile
        private var instance: StorageCore? = null
        
        @JvmStatic
        fun getInstance(): StorageCore {
            return instance ?: synchronized(this) {
                instance ?: StorageCore().also { instance = it }
            }
        }
    }
}

