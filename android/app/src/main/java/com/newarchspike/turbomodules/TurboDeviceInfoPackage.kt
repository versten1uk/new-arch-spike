package com.newarchspike.turbomodules

import com.facebook.react.TurboReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.model.ReactModuleInfo
import com.facebook.react.module.model.ReactModuleInfoProvider

/**
 * TurboReactPackage for TurboDeviceInfo (following official docs)
 */
class TurboDeviceInfoPackage : TurboReactPackage() {
    
    override fun getModule(name: String, reactContext: ReactApplicationContext): NativeModule? {
        return if (name == TurboDeviceInfoModule.NAME) {
            TurboDeviceInfoModule(reactContext)
        } else {
            null
        }
    }

    override fun getReactModuleInfoProvider() = ReactModuleInfoProvider {
        mapOf(
            TurboDeviceInfoModule.NAME to ReactModuleInfo(
                TurboDeviceInfoModule.NAME,
                TurboDeviceInfoModule.NAME,
                false, // canOverrideExistingModule
                false, // needsEagerInit
                true,  // isCxxModule
                true   // isTurboModule
            )
        )
    }
}

