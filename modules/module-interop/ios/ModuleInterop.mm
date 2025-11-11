#import "ModuleInterop.h"
#import <ExpoLogger/ExpoLoggerCore.h>
#import <TurboDeviceInfo/DeviceInfoCore.h>
#import <React/RCTLog.h>

@implementation ModuleInterop

+ (instancetype)shared {
    static ModuleInterop *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        NSLog(@"🚀 [ModuleInterop] Initialized centralized interop layer (STATELESS FACADE)");
    });
    return sharedInstance;
}

// ========================================
// LOGGER INTEROP (delegates to ExpoLoggerCore)
// ========================================

- (void)incrementLogCount {
    // Delegate to ExpoLoggerCore (which owns the state)
    [[ExpoLoggerCore shared] logInfo:@"[ModuleInterop] Log triggered"];
    NSLog(@"✅ [BRIDGELESS] ModuleInterop → ExpoLoggerCore: Delegated log call");
}

- (int)getLogCount {
    // Delegate to ExpoLoggerCore (which owns the state)
    return [[ExpoLoggerCore shared] getLogCount];
}

// ========================================
// DEVICE INFO INTEROP (delegates to DeviceInfoCore)
// ========================================

- (NSString *)getDeviceModel {
    // Delegate to DeviceInfoCore (which owns the logic)
    return [[DeviceInfoCore shared] getDeviceModel];
}

- (NSString *)getDeviceName {
    return [[DeviceInfoCore shared] getDeviceName];
}

- (NSString *)getSystemVersion {
    return [[DeviceInfoCore shared] getSystemVersion];
}

- (NSString *)getBundleId {
    return [[DeviceInfoCore shared] getBundleId];
}

@end

