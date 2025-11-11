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

- (void)incrementLogCount;
- (int)getLogCount;

// ========================================
// DEVICE INFO INTEROP (from TurboDeviceInfo)
// ========================================

- (NSString *)getDeviceModel;
- (NSString *)getDeviceName;
- (NSString *)getSystemVersion;
- (NSString *)getBundleId;

@end

