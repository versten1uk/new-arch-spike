import Foundation

/**
 * StorageCore - Pure native business logic (NO React Native dependencies)
 * 
 * This class owns the storage state and contains all storage logic.
 * It can be called from:
 * - ExpoStorageModule (Expo Module for JavaScript)
 * - ModuleInterop (for other native modules if needed)
 * - Unit tests (no RN runtime needed)
 */
public class StorageCore {
    public static let shared = StorageCore()
    
    private var storage: [String: String] = [:]
    
    private init() {
        // Initialize with empty storage
    }
    
    // ========================================
    // BUSINESS LOGIC
    // ========================================
    
    public func setItem(_ key: String, value: String) {
        storage[key] = value
    }
    
    public func getItem(_ key: String) -> String? {
        return storage[key]
    }
    
    public func removeItem(_ key: String) {
        storage.removeValue(forKey: key)
    }
    
    public func getAllKeys() -> [String] {
        return Array(storage.keys)
    }
    
    public func clear() {
        storage.removeAll()
    }
}

