#import "ExpoLoggerInterop.h"

@implementation ExpoLoggerInterop {
    int logCount;
}

+ (instancetype)shared {
    static ExpoLoggerInterop *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        logCount = 0;
    }
    return self;
}

- (void)incrementCount {
    logCount++;
    NSLog(@"✅ [BRIDGELESS ExpoLoggerInterop] Count incremented to: %d", logCount);
}

- (int)getCount {
    return logCount;
}

@end

