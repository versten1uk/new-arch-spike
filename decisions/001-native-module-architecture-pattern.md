# ADR-001: Native Module Architecture Pattern for New Architecture (Bridgeless Mode)

**Status:** Proposed

**Date:** 2025-11-13

## Context

As we migrate our mobile application to React Native's New Architecture (0.77+) with bridgeless mode enabled, we need to establish a clear pattern for building and integrating native modules. Our application has multiple native modules (Firebase, AppsFlyer, Snowplow, CGWebView) that need to communicate with each other without relying on the JavaScript bridge.

**Key Problems:**

1. **Cross-Module Communication**: In bridgeless mode, traditional native module communication patterns via `RCTBridge` are deprecated. We need native-to-native communication without the JavaScript bridge.

2. **Module Type Confusion**: The ecosystem now has multiple types of native modules (legacy NativeModules, TurboModules, Expo Modules), with no clear guidance on when to use which type or how they interoperate.

3. **State Management**: Native singleton state persistence across JavaScript reloads is poorly documented, leading to state synchronization issues between native and JavaScript layers.

4. **Testing & Maintainability**: Existing native modules tightly couple React Native dependencies with business logic, making unit testing difficult without a full RN runtime.

5. **Backward Compatibility**: We need to maintain compatibility with the old architecture during the migration period.

**Mobile-Specific Constraints:**
- Must support both iOS and Android identically
- Must work on both old architecture (with bridge) and new architecture (bridgeless)
- Must not require C++ knowledge for simple modules
- Must support real-world npm TurboModules (like `react-native-webview`)
- Must enable compile-time safety (no reflection-based module discovery)

## Decision

We will adopt a **flexible Three-Layer Architecture Pattern** where each layer is **optional** depending on the module's requirements:

### Decision Tree: What Does Your Module Need?

```
Does your module have persistent state (e.g., counters, caches)?
├─ NO → Does another native module need to call it directly?
│       ├─ NO → ✅ Simple Module (Wrapper only)
│       └─ YES → ✅ Core + Wrapper (no ModuleInterop)
└─ YES → ✅ Core + Wrapper (+ ModuleInterop if calling others)

Does your module need to call OTHER native modules?
└─ YES → ✅ Use ModuleInterop facade
```

### Module Complexity Examples

**Simple Module (Wrapper Only):**
- Pure utility functions (e.g., string formatting, simple calculations)
- No persistent state, no cross-module calls
- **Layers needed**: Wrapper only (Expo or Turbo)
- **Example**: `StringUtils`, `MathHelpers`

**Medium Module (Core + Wrapper):**
- Has persistent state OR is called by other modules
- No need to call other modules
- **Layers needed**: Core + Wrapper
- **Example**: `ExpoLogger` (has log count state)

**Complex Module (Core + Wrapper + ModuleInterop):**
- Has state AND calls other native modules
- Needs native-to-native communication
- **Layers needed**: Core + Wrapper + ModuleInterop
- **Example**: `CGWebView` (tracks state, calls Firebase/AppsFlyer/Snowplow)

### Layer 1: Core Classes (Pure Native) - **OPTIONAL**

- **Purpose**: Contains ALL business logic and state
- **Dependencies**: ZERO React Native dependencies
  - ❌ **Don't import**: React Native framework code (e.g., `React`, `RCTBridge`, `react-native` packages)
  - ✅ **OK to import**: Third-party SDKs (e.g., `FirebaseAnalytics`, `AppsFlyer`) even if they have RN dependencies internally
  - **Why**: Enables unit testing without RN runtime, allows reuse in widgets/extensions, decouples business logic from RN lifecycle
- **Naming**: `[ModuleName]Core` (e.g., `ExpoLoggerCore`, `AppsFlyerCore`)
- **When to use**: ONLY if your module has **state** OR is called by other native modules
- **When NOT to use**: Simple stateless utility modules
- **Implementation**: Singleton pattern, pure Swift/Kotlin, no RN imports

**Example:**
```swift
// AppsFlyerCore.swift - ✅ GOOD
import AppsFlyerLib  // Third-party SDK - OK

class AppsFlyerCore {
    func trackEvent(_ name: String) {
        AppsFlyer.shared().logEvent(name, withValues: [:])  // Uses SDK API
    }
}

// ❌ BAD - Don't do this in Core:
// import React
// import RCTBridge
```

### Layer 2: Module Wrappers (Thin Adapters) - **ALWAYS REQUIRED**

- **Purpose**: Exposes functionality to JavaScript
- **Pattern**: Thin wrapper that delegates to Core (if it exists) or implements logic directly (if simple)
- **Naming**: `[ModuleName]Module` (e.g., `ExpoLoggerModule`, `AppsFlyerModule`)
- **Types**:
   - **Expo Modules** (Swift/Kotlin DSL) - Recommended for analytics, storage, logging
   - **TurboModules** (Codegen + JSI) - For performance-critical modules or npm packages
      - **iOS**: Objective-C++ wrapper (`RCT[ModuleName].mm`) that calls into Swift Core classes via bridging header
      - **Android**: Kotlin class that extends codegen-generated spec

**iOS TurboModule Pattern (Swift Core + ObjC++ Wrapper):**
```swift
// TurboCalculatorCore.swift - Business logic (pure Swift with @objc)
@objc(TurboCalculatorCore)
class TurboCalculatorCore: NSObject {
    @objc static let shared = TurboCalculatorCore()
    @objc(addA:b:) func add(_ a: Double, b: Double) -> Double { a + b }
}
```

```objc
// RCTTurboCalculator.mm - JSI binding wrapper
#import "NewArchSpike-Swift.h"

- (NSNumber *)add:(double)a b:(double)b {
    return @([[TurboCalculatorCore shared] addA:a b:b]);
}
```

This pattern aligns with production architecture (e.g., `CGSpotlight` module) and allows Swift business logic to be reused across native modules.

### Layer 3: ModuleInterop (Stateless Facade) - **OPTIONAL**

- **Purpose**: Single entry point for native-to-native calls
- **Location**: Lives inside the calling module (e.g., `cg-webview`)
  - **Note**: In the POC, `ModuleInterop` is a separate module for demonstration purposes. In production, it should be part of the calling module to avoid extra dependencies.
- **Pattern**: Stateless facade that delegates to Core classes
- **When to use**: ONLY when your module needs to call other native modules
- **When NOT to use**: Modules that only expose functionality to JavaScript
- **NO STATE OWNERSHIP** - just a routing layer
- **Scaling**: Split by domain to avoid god-objects (e.g., `AnalyticsInterop`, `StorageInterop`, `LoggingInterop`)

**Example structure inside `cg-webview`:**
```
cg-webview/
├── ios/
│   ├── CGWebViewModule.swift
│   ├── AnalyticsInterop.swift    // → Firebase, AppsFlyer, Snowplow
│   ├── StorageInterop.swift      // → Preferences, SecureStorage
│   └── LoggingInterop.swift      // → Logger, Crashlytics
└── android/
    ├── CGWebViewModule.kt
    ├── AnalyticsInterop.kt
    ├── StorageInterop.kt
    └── LoggingInterop.kt
```

### Communication Flow Example (Complex Module):
```
TurboCalculator.add()
  ↓ (native call, no bridge)
ModuleInterop.logInfo("message")
  ↓ (delegates)
ExpoLoggerCore.logInfo() ← State lives here
  ↑ (reads state)
ExpoLoggerModule.getLogCount() ← JavaScript
```

### Preventing Circular Dependencies

The three-layer architecture **prevents most circular dependencies by design** through unidirectional flow:

**Architecture rules that prevent cycles:**
1. **Wrapper → Core** (one-way only, Core never imports Wrapper)
2. **ModuleInterop → Core** (one-way only, Core never imports ModuleInterop)
3. **Core classes are isolated** (no React Native imports, no other Core imports)
4. **ModuleInterop is stateless** (just a router, owns no state)

**Potential risk scenario (what NOT to do):**

❌ **BAD - Could cause circular dependency:**
```swift
// FirebaseCore needs AppsFlyer data
class FirebaseCore {
    func track() {
        let userId = AppsFlyerCore.shared.getUserId()  // ❌ Core → Core dependency
    }
}

// AppsFlyerCore needs Firebase data
class AppsFlyerCore {
    func track() {
        let sessionId = FirebaseCore.shared.getSessionId()  // ❌ Circular!
    }
}
```

**Mitigation strategies:**

✅ **Strategy 1: Extract shared domain Core classes**
```swift
// UserSessionCore - single source of truth
class UserSessionCore {
    static let shared = UserSessionCore()
    var userId: String?
    var sessionId: String?
}

// Both analytics use it (no circular dependency)
class FirebaseCore {
    func track() {
        let userId = UserSessionCore.shared.userId  // ✅ One-way dependency
    }
}

class AppsFlyerCore {
    func track() {
        let sessionId = UserSessionCore.shared.sessionId  // ✅ One-way dependency
    }
}
```

✅ **Strategy 2: Dependency injection via initializer**
```swift
class FirebaseCore {
    private let sessionProvider: () -> String?
    
    init(sessionProvider: @escaping () -> String? = { UserSessionCore.shared.sessionId }) {
        self.sessionProvider = sessionProvider
    }
    
    func track() {
        let sessionId = sessionProvider()
    }
}
```

✅ **Strategy 3: Event bus pattern (for truly decoupled communication)**
```swift
// FirebaseCore posts events
NotificationCenter.default.post(name: .userLoggedIn, object: userId)

// AppsFlyerCore observes events
NotificationCenter.default.addObserver(
    forName: .userLoggedIn,
    object: nil,
    queue: nil
) { notification in
    // Handle user login
}
```

**Key rule:** Core classes should **never import other Core classes**. If multiple Core classes need shared data, extract it to a separate shared Core class that both depend on.

## Options Considered

### Option A: Convert Everything to TurboModules

Convert all native modules to TurboModules with C++ JSI implementation.

**Pros:**
- Best performance (direct JSI)
- Fully aligned with new architecture

**Cons:**
- Requires C++ knowledge for all developers
- Massive boilerplate (codegen specs, ObjC++, C++ JSI)
- Harder to maintain
- Overkill for simple analytics/logging modules
- Slower development velocity

**Reason for not choosing:** Too complex for non-performance-critical modules. Most analytics, logging, and storage modules don't need direct JSI access and would suffer from increased maintenance burden.

### Option B: Flexible Three-Layer Architecture (Core + Wrapper + Interop) - **SELECTED**

Separate concerns into Core classes (state/logic), thin wrappers (RN adapters), and ModuleInterop (stateless facade). Each layer is **optional** based on module requirements.

**Pros:**
- Clear separation of concerns
- **Flexible**: Simple modules only need a wrapper, complex modules use all layers
- Core classes are testable without RN runtime (when needed)
- Works on both old and new architecture
- Compile-time safety with direct imports
- Can use TurboModules where needed, Expo Modules elsewhere
- Same pattern on iOS and Android
- Maintainable and scalable
- Swift Core + ObjC++ pattern matches production architecture
- **Not overkill**: Only add complexity when actually needed

**Cons:**
- Requires discipline to follow pattern consistently
- More files for complex modules (Core + Wrapper + Interop references)
- Learning curve for team to understand when to use each layer
- iOS TurboModules require bridging header setup

### Option C: Expo Modules Only

Convert all modules to Expo Modules, including `cg-webview`.

**Pros:**
- Simplest code
- Best developer experience
- Minimal boilerplate

**Cons:**
- Cannot integrate with npm TurboModules like `react-native-webview`
- Less control over JSI layer for performance-critical components

**Reason for not choosing:** `cg-webview` needs to integrate with `react-native-webview` (a TurboModule from npm) and requires performance optimizations that benefit from TurboModule architecture. Pure Expo approach is too limiting.

## Consequences

### Positive

1. **Future-Proof Architecture**
   - Full compatibility with React Native New Architecture (0.77+)
   - Native-to-native communication works in bridgeless mode without JavaScript bridge
   - Can leverage performance improvements of new architecture

2. **Clear Architectural Boundaries**
   - Core classes own state and business logic
   - Wrappers are thin adapters to JavaScript
   - ModuleInterop is a stateless facade for cross-module calls
   - New team members can quickly understand where logic lives

3. **Improved Testability**
   - Core classes have zero RN dependencies → can unit test without RN runtime
   - Mock `ModuleInterop` in tests to verify cross-module calls
   - Better code coverage and faster test execution

4. **Backward Compatibility**
   - Same code works on old architecture (with bridge) and new architecture (bridgeless)
   - Gradual migration possible: can enable new architecture when ready
   - No big-bang rewrite required

5. **Compile-Time Safety**
   - Direct imports (no reflection) catch errors at compile time
   - Xcode/Android Studio can auto-complete and detect issues before runtime
   - Obfuscation (ProGuard/R8) works correctly

6. **Scalability**
   - Adding new modules follows the same pattern
   - Dependencies are explicit and manageable
   - Can split `ModuleInterop` if it grows too large

7. **Performance Improvements**
   - Native-to-native calls: ~10-100x faster than bridge calls (no serialization)
   - UI components (Fabric): Improved rendering performance
   - JSI calls: Direct C++ → JavaScript, no bridge overhead

8. **Production Architecture Alignment**
   - Swift Core + ObjC++ pattern matches existing production modules (e.g., `CGSpotlight`)
   - Allows Swift business logic reuse across native modules
   - ObjC++ wrapper handles TurboModule JSI requirements cleanly

### Negative

1. **Learning Curve**
   - Team needs to learn when to create Core classes vs direct implementation
   - Requires understanding of both TurboModules and Expo Modules
   - iOS developers need to understand Swift/ObjC++ bridging for TurboModules
   - *Mitigation*: This ADR provides clear decision trees. POC project serves as reference implementation. Training sessions for team.

2. **More Files for Complex Modules**
   - Simple modules: 1-2 files (just Wrapper)
   - Stateful modules: 3-4 files (Core + Wrapper iOS + Wrapper Android)
   - Complex modules: 5+ files (Core + Wrapper + ModuleInterop references)
   - iOS TurboModules require both Swift Core and ObjC++ wrapper files
   - More navigation between files during development for complex modules
   - *Mitigation*: Only use multi-layer architecture when actually needed (see decision tree). Clear file naming conventions. Generator scripts could automate boilerplate creation in the future.

3. **Configuration Overhead**
   - iOS Podspecs must declare dependencies explicitly
   - iOS TurboModules require bridging header configuration
   - Android Gradle build files must list all project dependencies
   - TurboModules require manual registration in `MainApplication.kt`
   - *Mitigation*: This is standard for native development. Autolinking handles most cases. POC documents all "gotchas."

4. **Requires Discipline**
   - Developers must follow the pattern consistently
   - Easy to accidentally add RN dependencies to Core classes
   - Bridging header imports must be in correct order
   - *Mitigation*: Code review checklist, team training, and strict PR reviews to enforce pattern.

5. **ModuleInterop Growth**
   - As more modules are added, `ModuleInterop` needs new facade methods
   - Could become large over time
   - *Mitigation*: `ModuleInterop` remains stateless and simple. Can be split into multiple interop classes if needed (e.g., `AnalyticsInterop`, `StorageInterop`).

### Impact on Team

**JavaScript Developers:**
- Module interfaces remain simple (no change from their perspective)
- Benefit from better performance in new architecture

**iOS Developers:**
- Need to understand Swift/ObjC++ interop for TurboModules
- Must understand bridging header setup and import order
- Must declare dependencies in Podspecs
- Benefit from clearer architecture and testable Core classes
- Can write business logic in Swift (matches production patterns)

**Android Developers:**
- Need to understand Kotlin TurboModule registration
- Must declare dependencies in Gradle
- Benefit from compile-time safety (no reflection)

**QA/Test Engineers:**
- Core classes can be unit tested independently
- Easier to mock native modules for integration tests

### Platform-Specific Considerations

**iOS:**
- Works with iOS 13+ (RN 0.77 requirement)
- Podspec configuration is critical for cross-module imports
- Framework-style imports required for codegen specs
- Bridging header must import base classes (e.g., `RCTAppDelegate`, `ExpoModulesCore`) before importing Swift-generated header
- TurboModule `.mm` files must import dependencies in correct order:
  ```objc
  #import "RCT[ModuleName].h"
  #import <React-RCTAppDelegate/RCTAppDelegate.h>  // Import BEFORE Swift header
  #import <ExpoModulesCore-Swift.h>                // Import BEFORE Swift header
  #import "NewArchSpike-Swift.h"                   // Import Swift bridging header LAST
  ```

**Android:**
- Works with Android API 24+ (RN 0.77 requirement)
- TurboModules must be registered manually in `MainApplication.kt`
- Gradle dependencies are more explicit than CocoaPods
- ProGuard/R8 obfuscation works correctly (no reflection)

### Migration Path

1. **Phase 1: Create Core Classes** - Extract business logic and state into `[ModuleName]Core`, remove RN dependencies, test independently
2. **Phase 2: Convert Wrappers** - Migrate analytics/logging/storage to Expo Modules, convert performance-critical to TurboModules (using Swift Core + ObjC++ pattern for iOS)
3. **Phase 3: Implement ModuleInterop** - Create `ModuleInterop` inside `cg-webview`, add facade methods, update callers
4. **Phase 4: Enable New Architecture** - Set `newArchEnabled=true`, test bridgeless mode, verify native-to-native communication

### Risk Assessment

**Low Risk:**
- Pattern proven in POC on RN 0.77.2 + Expo SDK 52
- Works identically on iOS and Android
- Backward compatible with old architecture
- Swift Core + ObjC++ pattern matches production architecture

**Medium Risk:**
- Team adoption requires training and discipline
- Third-party npm modules may not follow this pattern (handle case-by-case)
- Bridging header setup can be tricky initially (well-documented in POC)

## Related ADRs:
- Native modules architecture `decisions/004-native-modules-new-architecture.md`

## Links

**Proof of Concept Repository:** [NewArchSpike POC](https://github.com/versten1uk/new-arch-spike)

**Note on POC Structure:** The POC implements `ModuleInterop` as a separate module for demonstration simplicity. In production, `ModuleInterop` should be implemented inside the calling module (e.g., `cg-webview`) as described in Layer 3.

**Key Documentation:**
- [Architecture Documentation (README.md)](https://github.com/versten1uk/new-arch-spike/README.md)
- [React Native New Architecture Docs](https://reactnative.dev/docs/the-new-architecture/landing-page)
- [React Native TurboModule Tutorial (Kotlin)](https://reactnative.dev/docs/turbo-native-modules-introduction?platforms=android&android-language=kotlin)
- [Expo Modules API](https://docs.expo.dev/modules/overview/)

**Status:** ✅ Fully working on iOS and Android (RN 0.77.2 + Expo SDK 52)
