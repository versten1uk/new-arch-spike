#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

// Force load our TurboModules by referencing their classes
// This prevents the linker from stripping them
@interface TurboModulesLoader : NSObject
@end

@implementation TurboModulesLoader

+ (void)load {
    NSLog(@"🔥 [TurboModulesLoader] Force-loading TurboModules...");
    
    // Reference the classes to force them to load
    Class calc = NSClassFromString(@"TurboCalculator");
    Class device = NSClassFromString(@"TurboDeviceInfo");
    
    if (calc) {
        NSLog(@"✅ [TurboModulesLoader] TurboCalculator class found");
    } else {
        NSLog(@"❌ [TurboModulesLoader] TurboCalculator class NOT found");
    }
    
    if (device) {
        NSLog(@"✅ [TurboModulesLoader] TurboDeviceInfo class found");
    } else {
        NSLog(@"❌ [TurboModulesLoader] TurboDeviceInfo class NOT found");
    }
}

@end

