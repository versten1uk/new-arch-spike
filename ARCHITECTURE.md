# 🏗️ Production-Ready Architecture for Module Communication

This POC demonstrates the **correct architecture** for cross-module communication in React Native New Architecture (bridgeless mode), with full backward compatibility for old architecture.

**✅ STATUS: FULLY WORKING ON iOS AND ANDROID (RN 0.77.2 + Expo SDK 52)**

---

## 📐 **Three-Layer Architecture**

### **Layer 1: Core Classes** (Pure Native)
- **Purpose**: Contains ALL business logic and state
- **Dependencies**: ZERO React Native dependencies
- **Benefits**:
  - Can be unit tested without RN runtime
  - Can be called from anywhere (JS modules, other native modules, tests)
  - Easy to maintain and debug

**Examples:**
- `ExpoLoggerCore` - Owns `logCount`, implements logging logic
- `DeviceInfoCore` - Implements device info retrieval logic
- `AppsFlyerCore` (production) - Wraps AppsFlyer SDK, owns tracking state
- `FirebaseCore` (production) - Wraps Firebase SDK, owns analytics state

---

### **Layer 2: Module Wrappers** (Thin Adapters)
- **Purpose**: Exposes Core classes to JavaScript
- **Types**: 
  - **Expo Modules** (Swift/Kotlin DSL) - for analytics, storage, logging
  - **TurboModules** (Codegen + JSI) - for performance-critical modules like webview
- **Pattern**: Thin wrapper that delegates ALL calls to Core

**Examples:**
```swift
// ExpoLoggerModule.swift (Thin Expo Module)
public class ExpoLoggerModule: Module {
    public func definition() -> ModuleDefinition {
        AsyncFunction("logInfo") { (message: String) in
            // Just delegate to Core
            ExpoLoggerCore.shared().logInfo(message)
        }
    }
}
```

```objc
// TurboDeviceInfo.mm (Thin TurboModule)
- (NSString *)getDeviceModel {
    // Just delegate to Core
    return [[DeviceInfoCore shared] getDeviceModel];
}
```

---

### **Layer 3: ModuleInterop** (Stateless Facade)
- **Purpose**: Provides a single entry point for native-to-native calls
- **Location**: Lives inside `cg-webview` in production
- **Pattern**: Stateless facade that delegates to Core classes
- **NO STATE OWNERSHIP** - just a routing layer

**Example:**
```kotlin
// ModuleInterop.kt (lives in cg-webview)
class ModuleInterop {
    fun logAppsFlyerEvent(name: String, params: Map<String, Any>) {
        // Delegate to AppsFlyerCore (which owns the logic)
        AppsFlyerCore.getInstance().logEvent(name, params)
    }
    
    fun getDeviceInfo(): DeviceInfo {
        // Delegate to DeviceInfoCore (which owns the logic)
        return DeviceInfoCore.getInstance().getDeviceInfo()
    }
}
```

---

## 🔄 **Communication Flow**

### **JavaScript → Native**
```
JavaScript
  ↓
ExpoLoggerModule (thin wrapper)
  ↓
ExpoLoggerCore (owns state & logic) ✅ State lives here!
```

### **Native → Native (Bridgeless)**
```
cg-webview (TurboModule)
  ↓
ModuleInterop (stateless facade)
  ↓
AppsFlyerCore (owns state & logic) ✅ State lives here!
```

### **Cross-Module Communication**
```
TurboCalculator.add()
  ↓
ModuleInterop.incrementLogCount()
  ↓
ExpoLoggerCore.logInfo() ✅ State incremented here!
  ↑
ExpoLoggerModule.getLogCount() reads from ExpoLoggerCore
```

---

## ✅ **Key Principles**

1. **Core classes OWN state** - never the wrappers or interop layer
2. **Module wrappers are THIN** - just adapters to JavaScript
3. **ModuleInterop is STATELESS** - just a facade for routing calls
4. **NO REFLECTION** - compile-time safety with direct imports
5. **Unit testable** - Core classes can be tested without React Native

---

## 🎯 **Production Migration Path**

### **For your cg-webview:**

1. **Create Core classes for each module:**
   ```
   AppsFlyerCore.kt/swift    - owns AppsFlyer state
   FirebaseCore.kt/swift     - owns Firebase state
   SnowplowCore.kt/swift     - owns Snowplow state
   ```

2. **Migrate existing modules to Expo Modules (recommended):**
   ```
   AppsFlyerModule (Expo) → AppsFlyerCore
   FirebaseModule (Expo) → FirebaseCore
   SnowplowModule (Expo) → SnowplowCore
   ```
   
   **Why Expo Modules?**
   - ✅ Less boilerplate than TurboModules
   - ✅ Auto backward compatibility
   - ✅ Easier to maintain
   - ✅ Perfect for analytics/tracking modules

3. **Create ModuleInterop inside cg-webview:**
   ```kotlin
   // Inside cg-webview module
   class ModuleInterop {
       fun trackEvent(name: String) {
           AppsFlyerCore.getInstance().logEvent(name)
           FirebaseCore.getInstance().logEvent(name)
           SnowplowCore.getInstance().track(name)
       }
   }
   ```

4. **cg-webview calls ModuleInterop (bridgeless):**
   ```kotlin
   // CGWebViewModule.kt (TurboModule)
   @ReactMethod
   fun onPageLoad(url: String) {
       // Direct native call (no bridge!)
       ModuleInterop.getInstance(context).trackEvent("page_loaded")
   }
   ```

---

## 📦 **Module Dependencies**

### **Production Structure:**
```
cg-webview (TurboModule + Fabric)
  ↓ depends on
module-interop (stateless facade)
  ↓ depends on
┌─────────────┬──────────────┬───────────────┐
↓             ↓              ↓               ↓
AppsFlyerCore FirebaseCore SnowplowCore CustomCore
↑             ↑              ↑               ↑
AppsFlyerModule FirebaseModule SnowplowModule CustomModule
(Expo)        (Expo)         (Expo)         (Expo)
```

### **Gradle Dependencies:**
```gradle
// module-interop/build.gradle
dependencies {
    implementation project(':appsflyer')  // Gets AppsFlyerCore
    implementation project(':firebase')   // Gets FirebaseCore
    implementation project(':snowplow')   // Gets SnowplowCore
}

// cg-webview/build.gradle
dependencies {
    implementation project(':module-interop')  // Single dependency!
}
```

---

## 🔁 **Backward Compatibility**

This architecture works on **both old and new architecture**:

| Component | Old Arch | New Arch |
|-----------|----------|----------|
| **TurboModule** | Falls back to legacy module | Full TurboModule with JSI |
| **Expo Module** | Falls back to bridge | Native calls |
| **Core classes** | ✅ Works (pure native) | ✅ Works (pure native) |
| **ModuleInterop** | ✅ Works (pure native) | ✅ Works (bridgeless) |

**The Core classes are ALWAYS native-to-native, regardless of architecture!**

---

## 🛠️ **Implementation Details & Gotchas**

### **1. iOS Podspec Configuration**

**For ModuleInterop (Objective-C module used by Swift):**
```ruby
s.pod_target_xcconfig = {
  "DEFINES_MODULE" => "YES"  # Required for Swift to import ObjC module
}
s.public_header_files = "ios/ModuleInterop.h"
```

**For ExpoLogger (exposes Core to other modules):**
```ruby
s.public_header_files = ["ios/ExpoLogger.h", "ios/ExpoLoggerCore.h"]
```

**For TurboModules (requires codegen):**
```ruby
s.compiler_flags = folly_compiler_flags + " -DRCT_NEW_ARCH_ENABLED=1"
s.pod_target_xcconfig = {
  "CLANG_CXX_LANGUAGE_STANDARD" => "c++20"
}
```

### **2. TurboModule Import Paths**

**❌ Wrong:**
```objc
#import "TurboCalculatorSpec.h"  // ❌ Won't find codegen output
```

**✅ Correct:**
```objc
#import <TurboCalculatorSpec/TurboCalculatorSpec.h>  // ✅ Framework-style import
```

### **4. Module Dependencies**

**Always declare dependencies in podspecs:**
```ruby
# ExpoStorage.podspec
s.dependency "ModuleInterop"  # Required for cross-module calls

# ModuleInterop.podspec
s.dependency "ExpoLogger"     # Access to ExpoLoggerCore
s.dependency "TurboDeviceInfo" # Access to DeviceInfoCore
```

**Gradle dependency:**
```gradle
dependencies {
    implementation project(':module-interop')
}
```

### **6. codegenConfig Placement**

**iOS needs it, Android doesn't for local modules:**
```json
{
  "codegenConfig": {
    "name": "TurboCalculatorSpec",
    "type": "modules",
    "jsSrcsDir": "src"
  }
}
```

- ✅ iOS: Uses codegen to generate protocol/spec headers
- ⚠️ Android: Use legacy modules for local TurboModules to avoid CMake issues

---

## 📊 **Communication Patterns**

### **Same Pod (Direct Call):**
```swift
// ExpoLoggerModule.swift
ExpoLoggerCore.shared().logInfo(message)  // ✅ Direct, same pod
```

### **Cross-Pod (Via ModuleInterop):**
```objc
// TurboCalculator.mm → ExpoLogger
[[ModuleInterop shared] incrementLogCount];  // ✅ Via facade
    ↓
ExpoLoggerCore.shared().logInfo()  // ModuleInterop delegates to Core
```

**The Core classes are ALWAYS native-to-native, regardless of architecture!**

---

## 🚀 **Next Steps for Production**

### **1. Apply to Your cg-webview:**

```
cg-webview (TurboModule + Fabric)
    ↓
ModuleInterop (lives in cg-webview)
    ↓
┌─────────────┬──────────────┬───────────────┐
↓             ↓              ↓               ↓
AppsFlyerCore FirebaseCore SnowplowCore AdsCore
```

### **2. Create Core Classes:**

For each SDK you're integrating:
- `AppsFlyerCore.kt/.m` - Wraps AppsFlyer SDK
- `FirebaseCore.kt/.m` - Wraps Firebase SDK
- `SnowplowCore.kt/.m` - Wraps Snowplow SDK

### **3. Migrate Existing Modules:**

- ✅ **Use Expo Modules** for analytics/tracking (easier to maintain)
- ✅ **Use TurboModules** for performance-critical modules (webview)
- ✅ **Each module delegates to its Core class**

### **4. Update cg-webview:**

```kotlin
// Inside cg-webview
@ReactMethod
fun onWebViewEvent(eventName: String, params: Map<String, Any>) {
    // BRIDGELESS: Direct native calls
    ModuleInterop.getInstance(context).apply {
        trackAppsFlyerEvent(eventName, params)
        trackFirebaseEvent(eventName, params)
        trackSnowplowEvent(eventName, params)
    }
}
```

### **5. Benefits You Get:**

- ✅ **Bridgeless mode ready** - Native-to-native, no JS bridge
- ✅ **Testable** - Core classes are pure native, unit test without RN
- ✅ **Maintainable** - Clear separation: Wrapper → Core
- ✅ **Backward compatible** - Works on old arch too
- ✅ **Scalable** - Add new modules by adding new Core classes

---

## 📝 **Summary**

This POC proves that:

1. ✅ **TurboModules and Expo Modules can communicate natively** (bridgeless)
2. ✅ **ModuleInterop is a clean facade** for cross-module calls
3. ✅ **Core classes own state and logic** - not wrappers or interop
4. ✅ **Works identically on iOS and Android**
5. ✅ **Production-ready architecture** for your cg-webview migration

**You can now confidently migrate your production app using this exact pattern!** 🎉
