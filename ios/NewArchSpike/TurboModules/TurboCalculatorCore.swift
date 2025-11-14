//
//  TurboCalculatorCore.swift
//  NewArchSpike
//
//  Core business logic for TurboCalculator (Swift implementation)
//  This is called by the Objective-C++ TurboModule wrapper
//

import Foundation

@objc(TurboCalculatorCore)
class TurboCalculatorCore: NSObject {
    
    @objc static let shared = TurboCalculatorCore()
    
    private override init() {
        super.init()
    }
    
    // MARK: - Business Logic
    
    @objc(addA:b:)
    func add(_ a: Double, b: Double) -> Double {
        return a + b
    }
    
    @objc(subtractA:b:)
    func subtract(_ a: Double, b: Double) -> Double {
        return a - b
    }
    
    @objc(multiplyA:b:)
    func multiply(_ a: Double, b: Double) -> Double {
        return a * b
    }
    
    @objc(divideA:b:)
    func divide(_ a: Double, b: Double) -> Double {
        guard b != 0 else { return 0 }
        return a / b
    }
}

