package com.newarchspike

import android.app.Application
import com.facebook.react.PackageList
import com.facebook.react.ReactApplication
import com.facebook.react.ReactHost
import com.facebook.react.ReactNativeApplicationEntryPoint.loadReactNative
import com.facebook.react.defaults.DefaultReactHost.getDefaultReactHost
import com.turbocalculator.TurboCalculatorPackage
import com.turbodeviceinfo.TurboDeviceInfoPackage
import com.simplestorage.SimpleStoragePackage
import com.simplelogger.SimpleLoggerPackage

class MainApplication : Application(), ReactApplication {

  override val reactHost: ReactHost by lazy {
    getDefaultReactHost(
      context = applicationContext,
      packageList =
        PackageList(this).packages.apply {
          // TurboModules
          add(TurboCalculatorPackage())
          add(TurboDeviceInfoPackage())
          // Simple Native Modules
          add(SimpleStoragePackage())
          add(SimpleLoggerPackage())
        },
    )
  }

  override fun onCreate() {
    super.onCreate()
    loadReactNative(this)
  }
}
