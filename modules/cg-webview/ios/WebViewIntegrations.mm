#import "WebViewIntegrations.h"
#import <React/RCTLog.h>

// POC: This simulates how cg-webview accesses Firebase, Snowplow, AppsFlyer
// But we use our POC modules: ExpoLogger, TurboCalculator, CustomDeviceInfo
// Pattern: OLD ARCH = self.bridge, NEW ARCH = NSClassFromString (BRIDGELESS)

@implementation WebViewIntegrations

RCT_EXPORT_MODULE(WebViewIntegrations)

+ (BOOL)requiresMainQueueSetup
{
    return NO;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

// ============================================================================
// PATTERN 1: WebViewIntegrations → ExpoLogger (Expo Module)
// Real use case: cg-webview → Firebase Analytics
// ============================================================================
RCT_EXPORT_METHOD(getLoggerCount:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        NSLog(@"🌐 [WebViewIntegrations] Getting ExpoLogger count (like Firebase App Instance ID)...");
        
        // BRIDGELESS: Direct class lookup instead of self.bridge
        if (NSClassFromString(@"ExpoLoggerInterop")) {
            Class loggerClass = NSClassFromString(@"ExpoLoggerInterop");
            SEL sharedSelector = NSSelectorFromString(@"shared");
            SEL getCountSelector = NSSelectorFromString(@"getCount");
            
            if ([loggerClass respondsToSelector:sharedSelector]) {
                id sharedInstance = ((id (*)(id, SEL))[loggerClass methodForSelector:sharedSelector])(loggerClass, sharedSelector);
                
                if ([sharedInstance respondsToSelector:getCountSelector]) {
                    int count = ((int (*)(id, SEL))[sharedInstance methodForSelector:getCountSelector])(sharedInstance, getCountSelector);
                    NSLog(@"✅ [BRIDGELESS] WebViewIntegrations → ExpoLogger: count = %d", count);
                    resolve(@(count));
                    return;
                }
            }
        }
        
        NSLog(@"❌ [WebViewIntegrations] ExpoLogger not found");
        resolve(@0);
    } @catch (NSException *exception) {
        NSLog(@"❌ [WebViewIntegrations] Error: %@", exception);
        reject(@"ERROR", @"Failed to get logger count", nil);
    }
}

// ============================================================================
// PATTERN 2: WebViewIntegrations → TurboCalculator (Turbo Module)
// Real use case: cg-webview → Another TurboModule
// ============================================================================
RCT_EXPORT_METHOD(performCalculation:(double)a
                  b:(double)b
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        NSLog(@"🌐 [WebViewIntegrations] Calling TurboCalculator...");
        
        // BRIDGELESS: Direct instantiation (TurboModules are NSObject subclasses)
        if (NSClassFromString(@"TurboCalculator")) {
            Class calcClass = NSClassFromString(@"TurboCalculator");
            id calculator = [[calcClass alloc] init];
            
            SEL addSelector = NSSelectorFromString(@"add:b:");
            if ([calculator respondsToSelector:addSelector]) {
                // Use NSInvocation for methods with multiple arguments
                NSMethodSignature *signature = [calculator methodSignatureForSelector:addSelector];
                NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
                [invocation setTarget:calculator];
                [invocation setSelector:addSelector];
                [invocation setArgument:&a atIndex:2];
                [invocation setArgument:&b atIndex:3];
                [invocation invoke];
                
                NSNumber *__unsafe_unretained result;
                [invocation getReturnValue:&result];
                
                NSLog(@"✅ [BRIDGELESS] WebViewIntegrations → TurboCalculator: %.0f + %.0f = %@", a, b, result);
                resolve(result);
                return;
            }
        }
        
        NSLog(@"❌ [WebViewIntegrations] TurboCalculator not found");
        resolve(@0);
    } @catch (NSException *exception) {
        NSLog(@"❌ [WebViewIntegrations] Error: %@", exception);
        reject(@"ERROR", @"Failed to perform calculation", nil);
    }
}

// ============================================================================
// PATTERN 3: WebViewIntegrations → CustomDeviceInfo (Turbo Module)
// Real use case: cg-webview → Device info for tracking
// ============================================================================
- (NSString *)getDeviceModel
{
    @try {
        NSLog(@"🌐 [WebViewIntegrations] Getting device model...");
        
        // BRIDGELESS: Direct instantiation
        if (NSClassFromString(@"TurboDeviceInfo")) {
            Class deviceClass = NSClassFromString(@"TurboDeviceInfo");
            id deviceInfo = [[deviceClass alloc] init];
            
            SEL selector = NSSelectorFromString(@"getDeviceModel");
            if ([deviceInfo respondsToSelector:selector]) {
                NSString *model = [deviceInfo performSelector:selector];
                NSLog(@"✅ [BRIDGELESS] WebViewIntegrations → CustomDeviceInfo: %@", model);
                return model;
            }
        }
        
        NSLog(@"❌ [WebViewIntegrations] CustomDeviceInfo not found");
        return @"unknown";
    } @catch (NSException *exception) {
        NSLog(@"❌ [WebViewIntegrations] Error: %@", exception);
        return @"error";
    }
}

// ============================================================================
// PATTERN 4: WebViewIntegrations → ExpoLogger (write operation)
// Real use case: cg-webview → AppsFlyer event tracking
// ============================================================================
RCT_EXPORT_METHOD(logEvent:(NSString *)eventName)
{
    @try {
        NSLog(@"🌐 [WebViewIntegrations] Logging event: %@", eventName);
        
        // BRIDGELESS: Direct class lookup
        if (NSClassFromString(@"ExpoLoggerInterop")) {
            Class loggerClass = NSClassFromString(@"ExpoLoggerInterop");
            SEL sharedSelector = NSSelectorFromString(@"shared");
            SEL incrementSelector = NSSelectorFromString(@"incrementCount");
            
            if ([loggerClass respondsToSelector:sharedSelector]) {
                id sharedInstance = ((id (*)(id, SEL))[loggerClass methodForSelector:sharedSelector])(loggerClass, sharedSelector);
                
                if ([sharedInstance respondsToSelector:incrementSelector]) {
                    ((void (*)(id, SEL))[sharedInstance methodForSelector:incrementSelector])(sharedInstance, incrementSelector);
                    NSLog(@"✅ [BRIDGELESS] WebViewIntegrations → ExpoLogger: Logged '%@'", eventName);
                }
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"❌ [WebViewIntegrations] Error: %@", exception);
    }
}

@end

