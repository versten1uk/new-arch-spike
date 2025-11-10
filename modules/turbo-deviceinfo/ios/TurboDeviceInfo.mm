#import "TurboDeviceInfo.h"
#import <UIKit/UIKit.h>
#import "CustomDeviceInfoSpec.h"

@implementation TurboDeviceInfo

RCT_EXPORT_MODULE(CustomDeviceInfo)

- (NSString *)getDeviceName {
    return [[UIDevice currentDevice] name];
}

- (NSString *)getSystemVersion {
    return [[UIDevice currentDevice] systemVersion];
}

- (NSString *)getBundleId {
    return [[NSBundle mainBundle] bundleIdentifier];
}

- (NSString *)getDeviceModel {
    NSString *model = [[UIDevice currentDevice] model];
    NSLog(@"🔵 [CustomDeviceInfo] getDeviceModel() = %@", model);
    return model;
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params {
    return std::make_shared<facebook::react::NativeTurboDeviceInfoSpecJSI>(params);
}

@end


