package com.newarchspike.turbomodules

import com.facebook.react.BaseReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.model.ReactModuleInfo
import com.facebook.react.module.model.ReactModuleInfoProvider

/**
 * TurboReactPackage for TurboCalculator (following official docs)
 */
class TurboCalculatorPackage : BaseReactPackage() {
    
    override fun getModule(name: String, reactContext: ReactApplicationContext): NativeModule? {
        return if (name == TurboCalculatorModule.NAME) {
            TurboCalculatorModule(reactContext)
        } else {
            null
        }
    }

    override fun getReactModuleInfoProvider() = ReactModuleInfoProvider {
        mapOf(
            TurboCalculatorModule.NAME to ReactModuleInfo(
                TurboCalculatorModule.NAME,
                TurboCalculatorModule.NAME,
                false, // canOverrideExistingModule
                false, // needsEagerInit
                true,  // isCxxModule
                true   // isTurboModule
            )
        )
    }
}

