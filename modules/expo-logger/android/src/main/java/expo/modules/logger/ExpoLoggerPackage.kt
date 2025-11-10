package expo.modules.logger

import expo.modules.core.BasePackage

class ExpoLoggerPackage : BasePackage() {
    override fun createModules() = listOf(ExpoLoggerModule())
}

