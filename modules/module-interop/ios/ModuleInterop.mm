#import "ModuleInterop.h"
#import <ExpoLogger/ExpoLoggerCore.h>
#import <ExpoStorage/StorageCore.h>
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

- (void)logInfo:(NSString *)message {
    // Delegate to ExpoLoggerCore (which owns the state)
    [[ExpoLoggerCore shared] logInfo:message];
    NSLog(@"✅ [BRIDGELESS] ModuleInterop → ExpoLoggerCore: Logged '%@'", message);
}

- (int)getLogCount {
    // Delegate to ExpoLoggerCore (which owns the state)
    return [[ExpoLoggerCore shared] getLogCount];
}

- (void)resetCount {
    // Delegate to ExpoLoggerCore (which owns the state)
    [[ExpoLoggerCore shared] resetCount];
    NSLog(@"✅ [BRIDGELESS] ModuleInterop → ExpoLoggerCore: Reset log count");
}

// ========================================
// STORAGE INTEROP (delegates to StorageCore)
// ========================================

- (void)setItem:(NSString *)key value:(NSString *)value {
    // Delegate to StorageCore (which owns the state)
    [[StorageCore shared] setItem:key value:value];
    NSLog(@"✅ [BRIDGELESS] ModuleInterop → StorageCore: Set '%@'='%@'", key, value);
}

- (NSString *)getItem:(NSString *)key {
    // Delegate to StorageCore (which owns the state)
    return [[StorageCore shared] getItem:key];
}

@end

