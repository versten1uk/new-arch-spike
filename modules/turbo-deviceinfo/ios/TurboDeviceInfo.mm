#import "TurboDeviceInfo.h"
#import "DeviceInfoCore.h"
#import <CustomDeviceInfoSpec/CustomDeviceInfoSpec.h>

/**
 * TurboDeviceInfo - Thin TurboModule wrapper
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

- (NSString *)getDeviceName {
    // Delegate to Core (which owns the logic)
    return [[DeviceInfoCore shared] getDeviceName];
}

- (NSString *)getSystemVersion {
    // Delegate to Core (which owns the logic)
    return [[DeviceInfoCore shared] getSystemVersion];
}

- (NSString *)getBundleId {
    // Delegate to Core (which owns the logic)
    return [[DeviceInfoCore shared] getBundleId];
}

- (NSString *)getDeviceModel {
    // Delegate to Core (which owns the logic)
    NSString *model = [[DeviceInfoCore shared] getDeviceModel];
    NSLog(@"🔵 [TurboDeviceInfo] getDeviceModel() = %@ (from Core)", model);
    return model;
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params {
    return std::make_shared<facebook::react::NativeTurboDeviceInfoSpecJSI>(params);
}

@end


