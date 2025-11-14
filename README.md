https://github.com/user-attachments/assets/5e1462b3-ea2c-4f12-81e3-dfc6b60d366f


---

# 🏗️ Production-Ready Architecture for Module Communication

This POC demonstrates the **correct architecture** for cross-module communication in React Native New Architecture (bridgeless mode), with full backward compatibility for old architecture.

**✅ STATUS: FULLY WORKING ON iOS AND ANDROID (RN 0.77.2 + Expo SDK 52)**

---

## 📐 **Three-Layer Architecture**

### **Layer 1: Core Classes** (Pure Native) - **ONLY for Stateful Modules**
- **Purpose**: Contains ALL business logic and state
- **Dependencies**: ZERO React Native dependencies
- **When to use**: ONLY if your module has **state** or **complex business logic**
- **Benefits**:
  - Can be called from anywhere (JS modules, other native modules)
  - Easy to maintain and debug
  - State persists across JS reloads

**Examples:**
- ✅ `ExpoLoggerCore` - Owns `logCount` state, implements logging logic
- ✅ `StorageCore` - Owns `storage` map state
- ✅ `AppsFlyerCore` (production) - Wraps AppsFlyer SDK, owns tracking state
- ✅ `FirebaseCore` (production) - Wraps Firebase SDK, owns analytics state

**When NOT to use Core classes:**
- ❌ **Stateless modules** with no cross-module dependencies
- ❌ **Simple wrappers** with no business logic
- ❌ **One-off utilities** that don't need cross-module access

**Note on TurboModules:**
For iOS TurboModules, we use the **Swift Core + ObjC++ Wrapper** pattern to align with production architecture:
- Swift Core (`TurboCalculatorCore.swift`) - Business logic with `@objc` exposure
- ObjC++ Wrapper (`RCTTurboCalculator.mm`) - Thin JSI binding that delegates to Swift Core

This pattern allows Swift business logic to be reused across native modules while the ObjC++ wrapper handles TurboModule JSI requirements.

**Decision Tree: Do I need a Core class?**

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
// TurboDeviceInfo.mm (Stateless TurboModule - direct implementation)
- (NSString *)getDeviceModel {
    // Self-contained, uses iOS APIs directly
    return [[UIDevice currentDevice] model];
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
// ModuleInterop.kt (lives in cg-webview in production)
class ModuleInterop {
    // Logger facade
    fun logInfo(message: String) {
        ExpoLoggerCore.getInstance().logInfo(message)
    }
    
    fun getLogCount(): Int {
        return ExpoLoggerCore.getInstance().getLogCount()
    }
    
    // Storage facade
    fun setItem(key: String, value: String) {
        StorageCore.getInstance().setItem(key, value)
    }
    
    fun getItem(key: String): String? {
        return StorageCore.getInstance().getItem(key)
    }
    
    // Production: Add your modules here
    fun trackAppsFlyerEvent(name: String, params: Map<String, Any>) {
        AppsFlyerCore.getInstance().logEvent(name, params)
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

### **Cross-Module Communication (Bridgeless)**
```
TurboCalculator.add()
  ↓ (native call, no bridge)
ModuleInterop.logInfo("message")
  ↓ (delegates)
ExpoLoggerCore.logInfo() ✅ State incremented here!
  ↑ (reads state)
ExpoLoggerModule.getLogCount() ← JavaScript calls this
```

**Key Point:** TurboModule → ModuleInterop → ExpoCore is **100% native, bridgeless!**

---

## ✅ **Key Principles**

1. **Core classes OWN state** - never the wrappers or interop layer
2. **Module wrappers are THIN** - just adapters to JavaScript
3. **ModuleInterop is STATELESS** - just a facade for routing calls
4. **NO REFLECTION** - compile-time safety with direct imports

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

## 📂 **POC Module Structure**

This POC demonstrates both patterns (with and without Core):

| Module | Type | Has Core? | Reason |
|--------|------|-----------|--------|
| **ExpoLogger** | Expo | ✅ `ExpoLoggerCore` | Has **state** (`logCount`) + used by TurboCalculator via ModuleInterop |
| **ExpoStorage** | Expo | ✅ `StorageCore` | Has **state** (`storage` map) |
| **TurboCalculator** | Turbo | ✅ `TurboCalculatorCore.swift` | **Swift + ObjC++ pattern** (production alignment) |
| **TurboDeviceInfo** | Turbo | ✅ `TurboDeviceInfoCore.swift` | **Swift + ObjC++ pattern** (production alignment) |
| **ModuleInterop** | Facade | N/A | **Stateless facade** - delegates to Core classes |

**For Production:**
- ✅ **All stateful modules** use Core classes (Logger, Storage, Analytics)
- ✅ **Stateless modules** can use direct implementation (Calculator, DeviceInfo)
- ✅ **ModuleInterop** remains a stateless facade that routes to Core classes

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
# ModuleInterop.podspec - declares what it uses
s.dependency "ExpoLogger"     # Access to ExpoLoggerCore
s.dependency "ExpoStorage"    # Access to StorageCore
```

**Gradle dependencies:**
```gradle
# module-interop/build.gradle - declares what it uses
dependencies {
    implementation project(':expo-logger')   # Access to ExpoLoggerCore
    implementation project(':expo-storage')  # Access to StorageCore
}

# app/build.gradle - TurboModules need ModuleInterop
dependencies {
    implementation project(':module-interop')  # For TurboCalculator to call ExpoLogger
}
```

### **6. TurboModules: App-Level Implementation (Critical!)**

**Following [official React Native docs](https://reactnative.dev/docs/turbo-native-modules-introduction?platforms=ios&android-language=kotlin):**

**✅ CORRECT: Implement TurboModules at app level**

1. **Specs in `specs/` directory at app root:**
   ```
   specs/NativeTurboCalculator.ts
   specs/NativeTurboDeviceInfo.ts
   ```

2. **`codegenConfig` in app's `package.json`:**
   ```json
   {
     "codegenConfig": {
       "name": "AppSpecs",
       "type": "modules",
       "jsSrcsDir": "specs",
       "android": {
         "javaPackageName": "com.newarchspike.specs"
       },
       "ios": {
         "modulesProvider": {
           "TurboCalculator": "RCTTurboCalculator",
           "TurboDeviceInfo": "RCTTurboDeviceInfo"
         }
       }
     }
   }
   ```

3. **Kotlin implementation in `android/app/src/main/java/.../turbomodules/`:**
   ```kotlin
   // TurboCalculatorModule.kt - Extends generated spec
   class TurboCalculatorModule(reactContext: ReactApplicationContext) : 
       NativeTurboCalculatorSpec(reactContext) {
       
       override fun getName() = NAME
       override fun add(a: Double, b: Double): Double = a + b
   }
   ```

4. **iOS implementation in `ios/TurboModules/`:**
   
   **Swift Core** (business logic):
   ```swift
   // TurboCalculatorCore.swift
   @objc(TurboCalculatorCore)
   class TurboCalculatorCore: NSObject {
       @objc static let shared = TurboCalculatorCore()
       @objc(addA:b:) func add(_ a: Double, b: Double) -> Double { a + b }
   }
   ```
   
   **ObjC++ Wrapper** (JSI binding):
   ```objc
   // RCTTurboCalculator.mm - Delegates to Swift Core
   #import "NewArchSpike-Swift.h"
   
   - (NSNumber *)add:(double)a b:(double)b {
       return @([[TurboCalculatorCore shared] addA:a b:b]);
   }
   ```

5. **Register with `TurboReactPackage` in `MainApplication.kt`:**
   ```kotlin
   override fun getPackages(): List<ReactPackage> =
       PackageList(this).packages.apply {
           add(TurboCalculatorPackage())
           add(TurboDeviceInfoPackage())
       }
   ```

**Why app-level?**
- ✅ No CMake/C++ complexity for local modules
- ✅ Codegen works cleanly on both platforms
- ✅ Follows official React Native pattern
- ✅ Easier to maintain and test

**❌ WRONG: Library modules with `codegenConfig`**
- Creates CMake issues on Android
- Requires C++/JSI implementation
- Overcomplicated for simple modules

---

## 📊 **Communication Patterns**

### **Same Pod (Direct Call):**
```swift
// ExpoLoggerModule.swift
ExpoLoggerCore.shared().logInfo(message)  // ✅ Direct, same pod
```

### **Cross-Module (Via ModuleInterop):**
```objc
// TurboCalculator.mm → ModuleInterop → ExpoLogger
[[ModuleInterop shared] logInfo:@"TurboCalculator: 10 + 5 = 15"];  // ✅ Via facade
    ↓ (ModuleInterop delegates)
ExpoLoggerCore.shared().logInfo(@"...")  // Core owns state, increments count
```

**This is 100% native-to-native bridgeless communication!**

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
- ✅ **Maintainable** - Clear separation: Wrapper → Core
- ✅ **Backward compatible** - Works on old arch too
- ✅ **Scalable** - Add new modules by adding new Core classes

---

## 📝 **Summary**

This POC proves that:

1. ✅ **TurboModules and Expo Modules can communicate natively** (bridgeless)
2. ✅ **ModuleInterop is a clean facade** for cross-module calls
3. ✅ **Core classes own state and logic** - not wrappers or interop
4. ✅ **Works identically on iOS and Android** (proven with logs above)
5. ✅ **Kotlin TurboModules work perfectly** (following official React Native docs)
6. ✅ **Production-ready architecture** for your cg-webview migration

**You can now confidently migrate your production app using this exact pattern!** 🎉

---

## 🤔 **Should cg-webview be a TurboModule or Expo Module?**

Now that we've proven TurboModule ↔ Expo Module communication works, you have both options:

### **Option A: cg-webview as Expo Module** ⭐ **Recommended**

**Architecture:**
```
react-native-webview (TurboModule from npm)
         ↓ nativeConfig
    cg-webview (Expo Module wrapper)
         ↓ uses
    ModuleInterop → Firebase, AppsFlyer, etc. (Expo Modules)
```

**Pros:**
- ✅ Simpler, cleaner code (Swift/Kotlin with Expo's DSL)
- ✅ Easier to maintain
- ✅ Better developer experience (no Codegen complexity)
- ✅ Works perfectly with `nativeConfig` to inject into `react-native-webview`
- ✅ Can call other Expo Modules via `ModuleInterop` ← **We proved this!**

**Cons:**
- None significant for this use case

### **Option B: cg-webview as TurboModule + Fabric**

**Architecture:**
```
react-native-webview (TurboModule from npm)
         ↓ uses as component
    cg-webview (TurboModule + Fabric)
         ↓ uses
    ModuleInterop → Firebase, AppsFlyer, etc. (Expo Modules)
```

**Pros:**
- ✅ More aligned with `react-native-webview` architecture (both TurboModules)
- ✅ Direct JSI access (potentially better performance)
- ✅ Can still call Expo Modules via `ModuleInterop` ← **We proved this!**

**Cons:**
- ❌ More complex (Codegen specs, ObjC++, Fabric component setup)
- ❌ Harder to maintain
- ❌ More boilerplate

### **Recommendation:**

**Start with Option A (Expo Module)** because:
1. **Communication works perfectly** - This POC proves TurboModules can call Expo Modules
2. **Simpler maintenance** - Focus on business logic, not boilerplate
3. **Faster iteration** - Expo's DSL is more ergonomic
4. **Still production-ready** - Expo Modules are battle-tested
5. **You can migrate later** - If needed, convert to TurboModule later

**Key Insight:** The choice is based on **developer experience**, not technical limitations. `ModuleInterop` enables seamless communication regardless!
