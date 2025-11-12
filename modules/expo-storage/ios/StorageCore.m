#import "StorageCore.h"

@interface StorageCore()
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *storage;
@end

@implementation StorageCore

+ (instancetype)shared {
    static StorageCore *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _storage = [NSMutableDictionary dictionary];
        NSLog(@"🚀 [StorageCore] Initialized (Pure native, no RN dependencies)");
    }
    return self;
}

// ========================================
// BUSINESS LOGIC
// ========================================

- (void)setItem:(NSString *)key value:(NSString *)value {
    NSLog(@"📦 [StorageCore] setItem: '%@' = '%@'", key, value);
    self.storage[key] = value;
}

- (NSString *)getItem:(NSString *)key {
    return self.storage[key];
}

- (void)removeItem:(NSString *)key {
    [self.storage removeObjectForKey:key];
}

- (NSArray<NSString *> *)getAllKeys {
    return [self.storage allKeys];
}

- (void)clear {
    [self.storage removeAllObjects];
    NSLog(@"🔄 [StorageCore] Storage cleared");
}

@end

