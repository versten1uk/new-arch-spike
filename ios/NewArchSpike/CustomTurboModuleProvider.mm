#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTLog.h>

// Import TurboModule headers
#import <TurboCalculator/TurboCalculator.h>
#import <TurboDeviceInfo/TurboDeviceInfo.h>

// Force the modules to be instantiated and registered
__attribute__((constructor))
static void registerCustomTurboModules(void) {
    NSLog(@"🔥 [CustomTurboModuleProvider] Registering custom TurboModules...");
    
    // Force load the classes
    [TurboCalculator class];
    [TurboDeviceInfo class];
    
    NSLog(@"✅ [CustomTurboModuleProvider] TurboModules registered!");
}

