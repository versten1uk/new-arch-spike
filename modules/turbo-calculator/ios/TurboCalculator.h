#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

#ifdef RCT_NEW_ARCH_ENABLED
#import <TurboCalculatorSpec/TurboCalculatorSpec.h>
@interface TurboCalculator : NSObject <NativeTurboCalculatorSpec>
#else
@interface TurboCalculator : NSObject <RCTBridgeModule>
#endif

@end

