import ExpoModulesCore
import UIKit
import WebKit

// Custom WebView component that wraps WKWebView
// This demonstrates how cg-webview (Expo Module) wraps react-native-webview (TurboModule)
class CGWebView: ExpoView {
    private var webView: WKWebView?
    private var url: String?
    private let label = UILabel()
    
    required init(appContext: AppContext? = nil) {
        super.init(appContext: appContext)
        backgroundColor = .white
        
        // Add label to show this is our custom wrapper
        label.text = "CGWebView (Expo Module)\nWrapping RNWebView (TurboModule)"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
        ])
        
        NSLog("🌐 [CGWebView] Native view initialized")
        
        // Log to ExpoLogger to prove module communication
        if let loggerClass = NSClassFromString("ExpoLoggerInterop") as? NSObject.Type {
            let logger = loggerClass.init()
            let selector = NSSelectorFromString("incrementCount")
            if logger.responds(to: selector) {
                logger.perform(selector)
                NSLog("✅ [BRIDGELESS] CGWebView init → ExpoLogger")
            }
        }
    }
    
    func setUrl(_ url: String) {
        self.url = url
        NSLog("🌐 [CGWebView] URL set to: %@", url)
        label.text = "CGWebView (Expo Module)\nWrapping: \(url)"
    }
}

