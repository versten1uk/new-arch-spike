#import "TurboDeviceInfo.h"
#import "DeviceInfoCore.h"

/**
 * TurboDeviceInfo - Thin Module wrapper
 *
 * This is a THIN WRAPPER that exposes DeviceInfoCore to JavaScript.
 * All business logic lives in DeviceInfoCore.
 *
 * Benefits:
 * - DeviceInfoCore can be called from JS (via this module) or natively (via ModuleInterop)
 * - DeviceInfoCore can be unit tested without React Native
 * - Logic is owned by DeviceInfoCore, not by the wrapper
 */
@implementation TurboDeviceInfo

RCT_EXPORT_MODULE(CustomDeviceInfo)

+ (BOOL)requiresMainQueueSetup {
    return NO;
}

RCT_EXPORT_SYNCHRONOUS_TYPED_METHOD(NSString *, getDeviceName) {
    // Delegate to Core (which owns the logic)
    return [[DeviceInfoCore shared] getDeviceName];
}

RCT_EXPORT_SYNCHRONOUS_TYPED_METHOD(NSString *, getSystemVersion) {
    // Delegate to Core (which owns the logic)
    return [[DeviceInfoCore shared] getSystemVersion];
}

RCT_EXPORT_SYNCHRONOUS_TYPED_METHOD(NSString *, getBundleId) {
    // Delegate to Core (which owns the logic)
    return [[DeviceInfoCore shared] getBundleId];
}

RCT_EXPORT_SYNCHRONOUS_TYPED_METHOD(NSString *, getDeviceModel) {
    // Delegate to Core (which owns the logic)
    NSString *model = [[DeviceInfoCore shared] getDeviceModel];
    NSLog(@"🔵 [TurboDeviceInfo] getDeviceModel() = %@ (from Core)", model);
    return model;
}

@end


