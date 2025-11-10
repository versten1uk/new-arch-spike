import UIKit
import React_RCTAppDelegate
import ExpoModulesCore

@main
class AppDelegate: RCTAppDelegate {
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    self.moduleName = "NewArchSpike"
    self.initialProps = [:]
    
    // Log Expo modules being loaded
    let provider = ExpoModulesProvider()
    let moduleClasses = provider.getModuleClasses()
    print("🔥 [EXPO] Loading \(moduleClasses.count) Expo modules:")
    for moduleClass in moduleClasses {
      print("🔥 [EXPO] - \(String(describing: moduleClass))")
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  override func bundleURL() -> URL? {
    #if DEBUG
    return URL(string: "http://localhost:8081/index.bundle?platform=ios")
    #else
    return Bundle.main.url(forResource: "main", withExtension: "jsbundle")
    #endif
  }
}
