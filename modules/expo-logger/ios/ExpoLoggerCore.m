#import "ExpoLoggerCore.h"
#import <os/log.h>

@interface ExpoLoggerCore()
@property (nonatomic, assign) int logCount;
@property (nonatomic, strong) os_log_t logger;
@end

@implementation ExpoLoggerCore

+ (instancetype)shared {
    static ExpoLoggerCore *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _logCount = 0;
        _logger = os_log_create("com.newarchspike", "ExpoLogger");
    }
    return self;
}

// Manual reset for development/testing
- (void)resetCount {
    _logCount = 0;
}

// ========================================
// BUSINESS LOGIC
// ========================================

- (void)logInfo:(NSString *)message {
    os_log_with_type(self.logger, OS_LOG_TYPE_INFO, "%{public}@", message);
    self.logCount++;
}

- (void)logWarning:(NSString *)message {
    os_log_with_type(self.logger, OS_LOG_TYPE_DEFAULT, "%{public}@", message);
    self.logCount++;
}

- (void)logError:(NSString *)message {
    os_log_with_type(self.logger, OS_LOG_TYPE_ERROR, "%{public}@", message);
    self.logCount++;
}

// ========================================
// STATE MANAGEMENT
// ========================================

- (int)getLogCount {
    return self.logCount;
}

@end

