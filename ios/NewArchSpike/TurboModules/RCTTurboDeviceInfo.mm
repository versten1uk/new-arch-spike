//  RCTTurboDeviceInfo.mm
//  NewArchSpike
//
//  TurboModule wrapper - delegates to Swift Core

#import "RCTTurboDeviceInfo.h"

// Import these BEFORE Swift header so NewArchSpike-Swift.h can see them
#import <React-RCTAppDelegate/RCTAppDelegate.h>
#import <ExpoModulesCore-Swift.h>

#import "NewArchSpike-Swift.h"

@implementation RCTTurboDeviceInfo

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
    return std::make_shared<facebook::react::NativeTurboDeviceInfoSpecJSI>(params);
}

- (NSString *)getDeviceModel {
    // Delegate to Swift Core
    return [[TurboDeviceInfoCore shared] getDeviceModel];
}

- (NSString *)getDeviceName {
    // Delegate to Swift Core
    return [[TurboDeviceInfoCore shared] getDeviceName];
}

- (NSString *)getSystemVersion {
    // Delegate to Swift Core
    return [[TurboDeviceInfoCore shared] getSystemVersion];
}

- (NSString *)getBundleId {
    // Delegate to Swift Core
    return [[TurboDeviceInfoCore shared] getBundleId];
}

+ (NSString *)moduleName {
    return @"TurboDeviceInfo";
}

@end

