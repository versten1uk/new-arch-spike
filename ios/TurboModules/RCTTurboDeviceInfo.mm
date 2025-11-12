//  RCTTurboDeviceInfo.mm
//  NewArchSpike

#import "RCTTurboDeviceInfo.h"
#import <UIKit/UIKit.h>
#import <React/RCTLog.h>

@implementation RCTTurboDeviceInfo

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
    return std::make_shared<facebook::react::NativeTurboDeviceInfoSpecJSI>(params);
}

- (NSString *)getDeviceModel {
    // Implement directly using iOS APIs (TurboModules should be self-contained)
    NSString *model = [[UIDevice currentDevice] model];
    RCTLogInfo(@"🔵 [TurboDeviceInfo] getDeviceModel() = %@", model);
    return model;
}

- (NSString *)getDeviceName {
    return [[UIDevice currentDevice] name];
}

- (NSString *)getSystemVersion {
    return [[UIDevice currentDevice] systemVersion];
}

- (NSString *)getBundleId {
    return [[NSBundle mainBundle] bundleIdentifier] ?: @"";
}

+ (NSString *)moduleName {
    return @"TurboDeviceInfo";
}

@end

