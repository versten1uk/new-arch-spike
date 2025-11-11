#import <Foundation/Foundation.h>

/**
 * DeviceInfoCore - Pure native business logic (NO React Native dependencies)
 * 
 * This class contains all device info logic.
 * It can be called from:
 * - TurboDeviceInfo (TurboModule for JavaScript)
 * - ModuleInterop (for other native modules like cg-webview)
 * - Unit tests (no RN runtime needed)
 */
@interface DeviceInfoCore : NSObject

+ (instancetype)shared;

// Business logic
- (NSString *)getDeviceName;
- (NSString *)getSystemVersion;
- (NSString *)getBundleId;
- (NSString *)getDeviceModel;

@end

