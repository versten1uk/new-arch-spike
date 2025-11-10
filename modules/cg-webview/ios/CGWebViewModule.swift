import ExpoModulesCore
import Foundation

public class CGWebViewModule: Module {
    public func definition() -> ModuleDefinition {
        Name("CGWebViewManager")
        
        View(CGWebView.self) {
            Events("onCustomWebViewEvent")
            
            Prop("url") { (view: CGWebView, url: String?) in
                if let url = url {
                    view.setUrl(url)
                }
            }
        }
        
        Function("logWebViewEvent") { (message: String) -> String in
            NSLog("🌐 [CGWebView] Event: %@", message)
            
            // BRIDGELESS NATIVE-TO-NATIVE: Expo Module (cg-webview) → Expo Module (ExpoLogger)
            if let loggerClass = NSClassFromString("ExpoLoggerInterop") as? NSObject.Type {
                let logger = loggerClass.init()
                let selector = NSSelectorFromString("incrementCount")
                if logger.responds(to: selector) {
                    logger.perform(selector)
                    NSLog("✅ [BRIDGELESS] CGWebView → ExpoLogger: Incremented count")
                }
            }
            
            return "Event logged: \(message)"
        }
    }
}

