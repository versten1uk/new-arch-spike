package expo.modules.storage

import expo.modules.core.BasePackage

class ExpoStoragePackage : BasePackage() {
    override fun createModules() = listOf(ExpoStorageModule())
}

