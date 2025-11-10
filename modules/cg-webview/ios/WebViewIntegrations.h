#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

#ifdef RCT_NEW_ARCH_ENABLED
#import "WebViewIntegrationsSpec.h"
@interface WebViewIntegrations : NSObject <NativeWebViewIntegrationsSpec>
#else
@interface WebViewIntegrations : NSObject <RCTBridgeModule>
#endif

@end

