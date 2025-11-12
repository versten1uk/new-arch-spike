#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

// Using bridge module interface (works on both old and new arch)
// For production cg-webview, use proper TurboModule with codegen
@interface TurboCalculator : NSObject <RCTBridgeModule>

@end

