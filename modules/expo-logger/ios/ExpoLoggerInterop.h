#import <Foundation/Foundation.h>

// Objective-C++ interop layer for ExpoLogger
// Allows TurboModules to call ExpoLogger methods
@interface ExpoLoggerInterop : NSObject

+ (instancetype)shared;
- (void)incrementCount;
- (int)getCount;

@end

