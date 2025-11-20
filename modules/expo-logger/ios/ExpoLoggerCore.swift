import Foundation
import os.log

/**
 * ExpoLoggerCore - Pure native business logic (NO React Native dependencies)
 * 
 * This class owns the logger state and contains all business logic.
 * It can be called from:
 * - ExpoLoggerModule (Expo Module for JavaScript)
 * - ModuleInterop (for other native modules like cg-webview)
 * - Unit tests (no RN runtime needed)
 */
public class ExpoLoggerCore {
    public static let shared = ExpoLoggerCore()
    
    private var logCount: Int = 0
    private let logger: os.Logger
    
    private init() {
        self.logger = os.Logger(subsystem: "com.newarchspike", category: "ExpoLogger")
    }
    
    // Manual reset for development/testing
    public func resetCount() {
        logCount = 0
    }
    
    // ========================================
    // BUSINESS LOGIC
    // ========================================
    
    public func logInfo(_ message: String) {
        logger.info("\(message, privacy: .public)")
        logCount += 1
    }
    
    public func logWarning(_ message: String) {
        logger.warning("\(message, privacy: .public)")
        logCount += 1
    }
    
    public func logError(_ message: String) {
        logger.error("\(message, privacy: .public)")
        logCount += 1
    }
    
    // ========================================
    // STATE MANAGEMENT
    // ========================================
    
    public func getLogCount() -> Int {
        return logCount
    }
}

