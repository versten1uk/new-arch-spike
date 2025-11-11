#import "DeviceInfoCore.h"
#import <UIKit/UIKit.h>

@implementation DeviceInfoCore

+ (instancetype)shared {
    static DeviceInfoCore *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        NSLog(@"🚀 [DeviceInfoCore] Initialized (Pure native, no RN dependencies)");
    }
    return self;
}

// ========================================
// BUSINESS LOGIC
// ========================================

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
    NSLog(@"🔵 [DeviceInfoCore] getDeviceModel() = %@", model);
    return model;
}

@end

