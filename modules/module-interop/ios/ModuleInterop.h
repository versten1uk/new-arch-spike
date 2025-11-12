#import <Foundation/Foundation.h>

/**
 * Centralized Interop Layer for all module-to-module communication
 * 
 * This class provides a single entry point for cross-module calls,
 * eliminating the need for reflection or direct module dependencies.
 * 
 * In production, this will live inside cg-webview and provide access
 * to AppsFlyer, Firebase, Snowplow, and other modules.
 */
@interface ModuleInterop : NSObject

// Singleton
+ (instancetype)shared;

// ========================================
// LOGGER INTEROP (from ExpoLogger)
// ========================================

- (void)logInfo:(NSString *)message;
- (int)getLogCount;
- (void)resetCount;

// ========================================
// STORAGE INTEROP (from ExpoStorage)
// ========================================

- (void)setItem:(NSString *)key value:(NSString *)value;
- (NSString *)getItem:(NSString *)key;

@end

