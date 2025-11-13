//  RCTTurboCalculator.mm
//  NewArchSpike

#import "RCTTurboCalculator.h"
#import <ModuleInterop/ModuleInterop.h>

@implementation RCTTurboCalculator

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
    return std::make_shared<facebook::react::NativeTurboCalculatorSpecJSI>(params);
}

- (NSNumber *)add:(double)a b:(double)b {
    double result = a + b;
    
    // BRIDGELESS NATIVE-TO-NATIVE CALL: TurboModule → ModuleInterop → ExpoLogger
    [[ModuleInterop shared] logInfo:[NSString stringWithFormat:@"TurboCalculator: %.0f + %.0f = %.0f", a, b, result]];
    
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
        return @(0);
    }
    return @(a / b);
}

+ (NSString *)moduleName {
    return @"TurboCalculator";
}

@end

