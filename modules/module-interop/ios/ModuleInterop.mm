#import "ModuleInterop.h"
#import <ExpoLogger/ExpoLoggerCore.h>
#import <ExpoStorage/StorageCore.h>

@implementation ModuleInterop

+ (instancetype)shared {
    static ModuleInterop *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

// ========================================
// LOGGER INTEROP (delegates to ExpoLoggerCore)
// ========================================

- (void)logInfo:(NSString *)message {
    [[ExpoLoggerCore shared] logInfo:message];
}

- (int)getLogCount {
    return [[ExpoLoggerCore shared] getLogCount];
}

- (void)resetCount {
    [[ExpoLoggerCore shared] resetCount];
}

// ========================================
// STORAGE INTEROP (delegates to StorageCore)
// ========================================

- (void)setItem:(NSString *)key value:(NSString *)value {
    [[StorageCore shared] setItem:key value:value];
}

- (NSString *)getItem:(NSString *)key {
    return [[StorageCore shared] getItem:key];
}

@end

