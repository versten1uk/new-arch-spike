#import "TurboCalculator.h"
#import <ModuleInterop/ModuleInterop.h>
#import <TurboCalculatorSpec/TurboCalculatorSpec.h>

@implementation TurboCalculator

RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup {
    NSLog(@"🔥 [TurboCalculator] requiresMainQueueSetup called");
    return NO;
}

- (NSNumber *)add:(double)a b:(double)b {
    double result = a + b;
    NSLog(@"🔵 [TurboCalculator] add called: %.0f + %.0f = %.0f", a, b, result);
    
        // BRIDGELESS NATIVE-TO-NATIVE CALL: TurboModule → ModuleInterop
        [[ModuleInterop shared] incrementLogCount];
        NSLog(@"✅ [BRIDGELESS] TurboCalculator → ModuleInterop: Incremented log count");
    
    return @(result);
}

- (NSNumber *)subtract:(double)a b:(double)b {
    return @(a - b);
}

- (NSNumber *)multiply:(double)a b:(double)b {
    return @(a * b);
}

- (NSNumber *)divide:(double)a b:(double)b {
    if (b == 0) {
        NSLog(@"❌ [TurboCalculator] Division by zero");
        return @(0);
    }
    return @(a / b);
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params {
    NSLog(@"🎯 [TurboCalculator] getTurboModule called! Creating JSI binding...");
    return std::make_shared<facebook::react::NativeTurboCalculatorSpecJSI>(params);
}

@end

