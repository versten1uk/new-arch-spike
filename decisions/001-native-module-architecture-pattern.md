# ADR-001: Updating Native Modules to prepare for React Native's New Architecture

*   **Status:** Accepted
*   **Date:** 2025-06-16

## Context

React Native is transitioning to a New Architecture that fundamentally changes how native modules interact with JavaScript. We need to update our Native Modules in order to support the new architecture. This change is driven by several key factors:

1. **Performance Limitations**: Our current native modules use the old Bridge architecture, which requires serialization/deserialization of data between JavaScript and native code. This creates a performance bottleneck, especially for modules that handle frequent data exchange such as our analytics (`CGFirebaseAnalyticsModule`, `CGSnowplowModule`) and ad-related modules (`SRPAdNativeModule`, `VDPAdViewManager`).

2. **Future Compatibility**: The old Bridge system is being deprecated, and new React Native features will be built exclusively for the New Architecture. Our app currently uses several custom native modules for critical features, which includes analytics integration, ad management, WebViews, and Spotlight search. These modules need to be updated to ensure continued compatibility and access to future React Native improvements.

3. **Technical Debt**: The current implementation of our native modules uses older patterns that don't take advantage of modern JavaScript features and type safety. The New Architecture's codegen system will provide better type safety and more predictable behavior, reducing potential runtime errors.

4. **Business Impact**: Our app's performance and stability are critical for user experience, especially in features like ad loading and analytics tracking. The New Architecture's performance improvements could lead to better user experience and more reliable data collection.

Updating our native modules is essential not only for adopting RN's new architecture, but also for keeping the app performant, maintainable, and ready to leverage future framework improvements.

Additionally, it is important that any updates we make now are **backwards-compatible with Legacy Native Modules**, because we aren't opting-in to the native architecture yet.

## Decision

We chose **Option 4**: replacing our iOS and Android Legacy Native Modules with **Expo Modules**, but also allowing developers to choose if using **Turbo Modules** makes more sense for their use case.

If time constraints prevent us from completing the migration before React Native removes the Bridge, we can fall back to using the **Interop Layer** to maintain compatibility without requiring immediate code changes.

## Options Considered

### Option 1: Nitro Modules
Nitro is a framework for building performant native modules for JS. A JS object can be implemented in C++, Swift or Kotlin instead of JS by using Nitro.

**Pros:**
* Uses Events to notify JS about any changes on the native side
* Object-oriented
* Direct Swift <> C++ interop with close to zero overhead
* Good performance

**Cons:**
* An extra dependency (not a part of react-native core)
* Doesn't directly support Obj-C or Java: iOS modules written in Obj-C would have to be rewritten in Swift/C++, and Android modules written in Java would have to be rewritten in Kotlin

**Reason for not choosing:** A lot of the appeal with this module is the ability to create new modules using modern languages such as Swift, without a Obj-C layer slowing down performance. This would certainly be helpful for creating new iOS modules since a lot of Apple's documentation is in Swift, however, none of our current modules are written in Swift, so this would require much more development time to rewrite all of our iOS modules. Additionally, we have seven Android modules written in Java that would have to be converted to Kotlin, requiring even more development time. This would also introduce additional risk, as we'd be changing both the architecture AND the programming languages used at the same time.

### Option 2: Turbo Modules
Turbo Modules are React Native's default framework for building native modules. They use a code-generator called "codegen" to convert Flow/TypeScript specs to native interfaces. Turbo Modules can be built with Objective-C for iOS and Kotlin/Java for Android, or C++ for cross-platform. Unlike Nitro, Turbo Modules are actually part of react-native core. This means, users don't have to install a single dependency to build or use a Turbo Module.

**Pros:**
* Part of react-native core, no need to install additional dependencies
* An evolution of Native Modules, so their API is almost identical, making development work easier
* Supports Java, Kotlin, and Obj-C, allowing us to keep our existing implementations while still upgrading to the new architecture
* Can be made backwards compatible with old architecture

**Cons:**
* No syntax for properties, instead, conventional getter/setter methods have to be used
* Not object-oriented
* Doesn't support a pure Swift implementation, some Obj-C glue code is required
* Isn't automatically backwards compatible, extra work is involved

### Option 3: Expo Modules
Expo Modules is an API used to build native modules by Expo. Unlike both Nitro and Turbo, Expo Modules does not have a code-generator. All native modules are considered untyped, and TypeScript definitions can be written afterwards.

**Pros:**
* Supports getting and setting properties
* Uses Events to notify JS about any changes on the native side
* Automatically backwards compatable with old architecture
* Supports Swift, a more modern language
* Improved developer experience

**Cons:**
* An extra dependency (not a part of react-native core)
* Does not provide a code-generator, so all native modules are untyped by default. While TypeScript definitions can be written afterwards, it's possible for the handwritten TypeScript definitions to be out of sync with the actual native types due to a user-error
* Similar to Nitro modules, no support for Obj-C and Java

### Option 4: Expo Modules + Turbo Modules
This option recommends the use of Expo Modules, but allows developers to use Turbo Modules instead if needed.

**Pros:**
* Increased flexibility
* Has benefits of both Expo and Turbo Modules

**Cons:**
* Inconsistency in module architecture across the codebase

### Option 5: React Native Interop Layer (Fallback)
React Native's Interop Layer allows legacy Native Modules to continue working even when Bridgeless Mode is enabled, without requiring any code changes to the existing modules.

**Pros:**
* Zero development effort required
* No code changes needed to existing modules
* Immediate compatibility with New Architecture
* Can be used as a temporary solution while migrating modules
* Uses JSI for better performance than the old Bridge

**Cons:**
* Limited performance benefits compared to full New Architecture modules (Turbo/Expo)
* Technical debt remains unchanged
* Not a long-term solution
* Doesn't support every use case

**Reason for not choosing as primary option:** While this is the easiest path forward and provides some performance improvements, it doesn't fully address the technical debt and doesn't provide the full performance benefits of dedicated New Architecture modules. However, it serves as a valuable fallback option if time constraints prevent us from completing the migration before the Bridge is removed.

## Consequences

### Positive Impacts

1. **Performance Improvements**
   * Reduced serialization/deserialization overhead between JavaScript and native code
   * Better performance for frequently used modules like analytics and ad-related features
   * Improved app responsiveness and user experience

2. **Technical Benefits**
   * More predictable behavior and reduced runtime errors
   * Access to future React Native features and improvements
   * Maintained compatibility with existing codebase (Obj-C and Java) through Turbo Modules
   * Support for Swift through Expo Modules for new iOS development

3. **Development Experience**
   * Enhanced developer experience with Expo Modules' property support and event system
   * Ability to use Swift, a generally faster, safer langauge with modern syntax
   * Backwards compatibility with old architecture allows for gradual migration
   * Flexibility to choose the right tool for each use case

4. **Architectural Flexibility**
   * Can use Expo Modules for simpler modules that benefit from property support
   * Can use Turbo Modules for performance-critical modules or when type safety is paramount
   * Allows teams to choose the most appropriate solution based on specific requirements

### Negative Impacts

1. **Development Effort**
   * Requires significant refactoring of existing native modules
   * Need to create and maintain TypeScript/Flow specifications for Turbo Modules
   * Learning curve for the team with both Expo Modules and Turbo Modules systems
   * Need to decide which approach to use for each module

2. **Technical Limitations**
   * Inconsistency in module architecture across the codebase
   * Turbo Modules lack native support for properties (must use getter/setter methods)
   * Need to maintain backwards compatibility during transition

3. **Migration Challenges**
   * Potential for bugs during the migration process
   * Need to thoroughly test all native module functionality
   * May require coordination with other teams using these modules
   * Additional complexity in deciding which module type to use for new features

4. **Resource Requirements**
   * Additional development time for module conversion
   * Need for comprehensive testing across both architectures
   * Documentation updates required for new module implementations
   * Team needs to understand and maintain two different module systems

5. **Consistency Concerns**
   * Less consistency across the codebase due to mixed module types
   * Potential confusion for new developers about which approach to use
   * May lead to inconsistent patterns and implementations

### Risk Mitigation

* Can implement changes gradually, one module at a time
* Backwards compatibility allows for rollback if issues arise
* Existing module structure can be largely preserved with Turbo Modules if needed
* Clear guidelines can be established for when to use each module type
* Can start with Expo Modules for simpler use cases and migrate to Turbo Modules for performance-critical modules

## Links

* **Nitro modules:** https://nitro.margelo.com/
* **Expo modules:** https://docs.expo.dev/modules/overview/
* **Turbo modules:** https://reactnative.dev/docs/turbo-native-modules-introduction
* **Comparing Nitro, Expo, and Turbo**: https://nitro.margelo.com/docs/comparison
* **Making backwards-compatible Turbo Modules**: https://github.com/reactwg/react-native-new-architecture/blob/main/docs/backwards-compat-turbo-modules.md