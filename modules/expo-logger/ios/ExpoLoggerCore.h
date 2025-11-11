#import <Foundation/Foundation.h>

/**
 * ExpoLoggerCore - Pure native business logic (NO React Native dependencies)
 * 
 * This class owns the logger state and contains all business logic.
 * It can be called from:
 * - ExpoLoggerModule (Expo Module for JavaScript)
 * - ModuleInterop (for other native modules like cg-webview)
 * - Unit tests (no RN runtime needed)
 */
@interface ExpoLoggerCore : NSObject

+ (instancetype)shared;

// Business logic
- (void)logInfo:(NSString *)message;
- (void)logWarning:(NSString *)message;
- (void)logError:(NSString *)message;

// State management
- (int)getLogCount;
- (void)resetCount;

@end

