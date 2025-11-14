//
//  TurboDeviceInfoCore.swift
//  NewArchSpike
//
//  Core business logic for TurboDeviceInfo (Swift implementation)
//  This is called by the Objective-C++ TurboModule wrapper
//

import Foundation
import UIKit

@objc(TurboDeviceInfoCore)
class TurboDeviceInfoCore: NSObject {
    
    @objc static let shared = TurboDeviceInfoCore()
    
    private override init() {
        super.init()
    }
    
    // MARK: - Device Information
    
    @objc
    func getDeviceModel() -> String {
        return UIDevice.current.model
    }
    
    @objc
    func getDeviceName() -> String {
        return UIDevice.current.name
    }
    
    @objc
    func getSystemVersion() -> String {
        return UIDevice.current.systemVersion
    }
    
    @objc
    func getBundleId() -> String {
        return Bundle.main.bundleIdentifier ?? ""
    }
}

