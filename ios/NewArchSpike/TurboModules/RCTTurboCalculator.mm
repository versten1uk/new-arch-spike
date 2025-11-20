//  RCTTurboCalculator.mm
//  NewArchSpike
//
//  TurboModule wrapper - delegates to Swift Core

#import "RCTTurboCalculator.h"

// Import these BEFORE Swift header so NewArchSpike-Swift.h can see them
#import <React-RCTAppDelegate/RCTAppDelegate.h>
#import <ExpoModulesCore-Swift.h>

#import "NewArchSpike-Swift.h"

@implementation RCTTurboCalculator

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
    return std::make_shared<facebook::react::NativeTurboCalculatorSpecJSI>(params);
}

- (NSNumber *)add:(double)a b:(double)b {
    // Delegate to Swift Core (business logic)
    double result = [[TurboCalculatorCore shared] addA:a b:b];
    
    // BRIDGELESS NATIVE-TO-NATIVE CALL: TurboModule → ModuleInterop → ExpoLogger
    [[ModuleInterop shared] logInfo:[NSString stringWithFormat:@"TurboCalculator: %.0f + %.0f = %.0f", a, b, result]];
    
    return @(result);
}

- (NSNumber *)subtract:(double)a b:(double)b {
    // Delegate to Swift Core
    return @([[TurboCalculatorCore shared] subtractA:a b:b]);
}

- (NSNumber *)multiply:(double)a b:(double)b {
    // Delegate to Swift Core
    return @([[TurboCalculatorCore shared] multiplyA:a b:b]);
}

- (NSNumber *)divide:(double)a b:(double)b {
    // Delegate to Swift Core
    return @([[TurboCalculatorCore shared] divideA:a b:b]);
}

+ (NSString *)moduleName {
    return @"TurboCalculator";
}

@end

