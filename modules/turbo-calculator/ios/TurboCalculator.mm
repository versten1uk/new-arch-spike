#import "TurboCalculator.h"
#import <ModuleInterop/ModuleInterop.h>

@implementation TurboCalculator

RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup {
    return NO;
}

RCT_EXPORT_SYNCHRONOUS_TYPED_METHOD(NSNumber *, add:(double)a b:(double)b) {
    double result = a + b;
    NSLog(@"🔵 [TurboCalculator] add called: %.0f + %.0f = %.0f", a, b, result);
    
    // BRIDGELESS NATIVE-TO-NATIVE CALL: Module → ModuleInterop
    [[ModuleInterop shared] incrementLogCount];
    NSLog(@"✅ [BRIDGELESS] TurboCalculator → ModuleInterop: Incremented log count");
    
    return @(result);
}

RCT_EXPORT_SYNCHRONOUS_TYPED_METHOD(NSNumber *, subtract:(double)a b:(double)b) {
    return @(a - b);
}

RCT_EXPORT_SYNCHRONOUS_TYPED_METHOD(NSNumber *, multiply:(double)a b:(double)b) {
    return @(a * b);
}

RCT_EXPORT_SYNCHRONOUS_TYPED_METHOD(NSNumber *, divide:(double)a b:(double)b) {
    if (b == 0) {
        NSLog(@"❌ [TurboCalculator] Division by zero");
        return @(0);
    }
    return @(a / b);
}

@end

