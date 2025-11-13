# ADR-001: Native Module Architecture Pattern for New Architecture (Bridgeless Mode)

**Status:** Accepted

**Date:** 2025-11-12

## Context

As we migrate our mobile application to React Native's New Architecture (0.77+) with bridgeless mode enabled, we need to establish a clear, production-ready pattern for building and integrating native modules. Our application has multiple native modules (Firebase, AppsFlyer, Snowplow, `cg-webview`) that need to communicate with each other without relying on the JavaScript bridge.

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

We will adopt a **Three-Layer Architecture Pattern** for all native modules:

### Layer 1: Core Classes (Pure Native)
- **Purpose**: Contains ALL business logic and state
- **Dependencies**: ZERO React Native dependencies
- **Naming**: `[ModuleName]Core` (e.g., `ExpoLoggerCore`, `AppsFlyerCore`)
- **When to use**: ONLY if your module has **state** OR is called by other native modules
- **Implementation**: Singleton pattern, pure Swift/Kotlin, no RN imports

### Layer 2: Module Wrappers (Thin Adapters)
- **Purpose**: Exposes Core classes to JavaScript
- **Pattern**: Thin wrapper that delegates ALL calls to Core
- **Types**:
  - **Expo Modules** (Swift/Kotlin DSL) - Recommended for analytics, storage, logging
  - **TurboModules** (Codegen + JSI) - For performance-critical modules or npm packages

### Layer 3: ModuleInterop (Stateless Facade)
- **Purpose**: Single entry point for native-to-native calls
- **Location**: Lives inside the calling module (e.g., `cg-webview`)
- **Pattern**: Stateless facade that delegates to Core classes
- **NO STATE OWNERSHIP** - just a routing layer

**Communication Flow:**
```
TurboCalculator.add()
  ↓ (native call, no bridge)
ModuleInterop.logInfo("message")
  ↓ (delegates)
ExpoLoggerCore.logInfo() ← State lives here
  ↑ (reads state)
ExpoLoggerModule.getLogCount() ← JavaScript
```

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

### Option B: Use Reflection for Cross-Module Communication (Android)

Use Android's `ReactContext.getNativeModule()` with reflection to discover modules at runtime.

**Pros:**
- Minimal boilerplate
- Easy to implement

**Cons:**
- Performance overhead on every call
- No compile-time safety
- Breaks with code obfuscation (ProGuard/R8)
- Poor readability and maintainability
- Different pattern on iOS vs Android

**Reason for not choosing:** Bad practice for production. Reflection is slow, breaks with obfuscation, and provides no compile-time guarantees. Not acceptable for a production-grade architecture.

### Option C: Three-Layer Architecture (Core + Wrapper + Interop) - **SELECTED**

Separate concerns into Core classes (state/logic), thin wrappers (RN adapters), and ModuleInterop (stateless facade).

**Pros:**
- Clear separation of concerns
- Core classes are testable without RN runtime
- Works on both old and new architecture
- Compile-time safety with direct imports
- Flexible: use TurboModules where needed, Expo Modules elsewhere
- Same pattern on iOS and Android
- Maintainable and scalable

**Cons:**
- Requires discipline to follow pattern consistently
- More files per module (Core + Wrapper + Interop references)
- Learning curve for team

### Option D: Expo Modules Only

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

### Negative

1. **Learning Curve**
   - Team needs to learn when to create Core classes vs direct implementation
   - Requires understanding of both TurboModules and Expo Modules
   - *Mitigation*: This ADR provides clear decision trees. POC project serves as reference implementation. Training sessions for team.

2. **More Files Per Module**
   - Stateful modules have 3-4 files (Core, Wrapper iOS, Wrapper Android, Interop references)
   - More navigation between files during development
   - *Mitigation*: Clear file naming conventions. Generator scripts could automate boilerplate creation in the future.

3. **Configuration Overhead**
   - iOS Podspecs must declare dependencies explicitly
   - Android Gradle build files must list all project dependencies
   - TurboModules require manual registration in `MainApplication.kt`
   - *Mitigation*: This is standard for native development. Autolinking handles most cases. POC documents all "gotchas."

4. **Requires Discipline**
   - Developers must follow the pattern consistently
   - Easy to accidentally add RN dependencies to Core classes
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
- Must declare dependencies in Podspecs
- Benefit from clearer architecture and testable Core classes

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
- `-force_load` linker flags may be needed for static libraries

**Android:**
- Works with Android API 24+ (RN 0.77 requirement)
- TurboModules must be registered manually in `MainApplication.kt`
- Gradle dependencies are more explicit than CocoaPods
- ProGuard/R8 obfuscation works correctly (no reflection)

### Migration Path

1. **Phase 1: Create Core Classes** - Extract business logic and state into `[ModuleName]Core`, remove RN dependencies, test independently
2. **Phase 2: Convert Wrappers** - Migrate analytics/logging/storage to Expo Modules, convert performance-critical to TurboModules
3. **Phase 3: Implement ModuleInterop** - Create `ModuleInterop` inside `cg-webview`, add facade methods, update callers
4. **Phase 4: Enable New Architecture** - Set `newArchEnabled=true`, test bridgeless mode, verify native-to-native communication

### Risk Assessment

**Low Risk:**
- Pattern proven in POC on RN 0.77.2 + Expo SDK 52
- Works identically on iOS and Android
- Backward compatible with old architecture

**Medium Risk:**
- Team adoption requires training and discipline
- Third-party npm modules may not follow this pattern (handle case-by-case)

## Links

**Proof of Concept Repository:** [NewArchSpike POC](file:///Users/versteniuk/Documents/projects/NewArchSpike)

**Key Documentation:**
- [Architecture Documentation (README.md)](file:///Users/versteniuk/Documents/projects/NewArchSpike/README.md)
- [React Native New Architecture Docs](https://reactnative.dev/docs/the-new-architecture/landing-page)
- [React Native TurboModule Tutorial (Kotlin)](https://reactnative.dev/docs/turbo-native-modules-introduction?platforms=android&android-language=kotlin)
- [Expo Modules API](https://docs.expo.dev/modules/overview/)

**POC Results - Verified Logs (Bridgeless Communication):**

iOS:
```
🔵 [TurboCalculator] add called: 10 + 5 = 15
🚀 [ModuleInterop] Initialized centralized interop layer (STATELESS FACADE)
✅ [ExpoLoggerCore] Info logged, count now: 1
✅ [BRIDGELESS] ModuleInterop → ExpoLoggerCore: Logged 'TurboCalculator: 10 + 5 = 15'
✅ [BRIDGELESS] TurboCalculator → ModuleInterop → ExpoLogger
📊 [ExpoLoggerModule] getLogCount() = 1 (from Core)
```

Android:
```
🔵 [TurboCalculator] add called: 10.0 + 5.0 = 15.0
🚀 [ModuleInterop] Initialized centralized interop layer (STATELESS FACADE)
✅ [ExpoLoggerCore] Info logged, count now: 1
✅ [BRIDGELESS] ModuleInterop → ExpoLoggerCore: Logged 'TurboCalculator: 10.0 + 5.0 = 15.0'
✅ [BRIDGELESS] TurboCalculator → ModuleInterop → ExpoLogger
📊 [ExpoLoggerModule] getLogCount() = 1 (from Core)
```

**Status:** ✅ Fully working on iOS and Android (RN 0.77.2 + Expo SDK 52)
