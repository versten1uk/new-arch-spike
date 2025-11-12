#import <Foundation/Foundation.h>

/**
 * StorageCore - Pure native business logic (NO React Native dependencies)
 * 
 * This class owns the storage state and contains all storage logic.
 * It can be called from:
 * - ExpoStorageModule (Expo Module for JavaScript)
 * - ModuleInterop (for other native modules if needed)
 * - Unit tests (no RN runtime needed)
 */
@interface StorageCore : NSObject

+ (instancetype)shared;

// Storage operations
- (void)setItem:(NSString *)key value:(NSString *)value;
- (NSString *)getItem:(NSString *)key;
- (void)removeItem:(NSString *)key;
- (NSArray<NSString *> *)getAllKeys;
- (void)clear;

@end

