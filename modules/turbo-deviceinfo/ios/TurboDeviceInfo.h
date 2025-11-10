#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

#ifdef RCT_NEW_ARCH_ENABLED
#import "CustomDeviceInfoSpec.h"
@interface TurboDeviceInfo : NSObject <NativeTurboDeviceInfoSpec>
#else
@interface TurboDeviceInfo : NSObject <RCTBridgeModule>
#endif

@end

