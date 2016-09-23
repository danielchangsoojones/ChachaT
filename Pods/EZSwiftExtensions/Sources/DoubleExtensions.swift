//
//  DoubleExtensions.swift
//  EZSwiftExtensionsExample
//
//  Created by Goktug Yilmaz on 12/19/15.
//  Copyright © 2015 Goktug Yilmaz. All rights reserved.
//

import UIKit

extension Double {
    /// EZSE: Converts Double to String
    public var toString: String { return String(self) }

    /// EZSE: Converts Double to Int
    public var toInt: Int { return Int(self) }

    /// EZSE: Returns a Double rounded to decimal
    public mutating func getRoundedByPlaces(_ places: Int) -> Double {
        guard places >= 0 else { return self }
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }

    /// EZSE: Rounds the current Double rounded to decimal
    public mutating func roundByPlaces(_ places: Int) {
        self = getRoundedByPlaces(places)
    }

    /// EZSE: Returns a Double Ceil to decimal
    public func getCeiledByPlaces(_ places: Int) -> Double {
        return castToDecimalByPlacesHelper(places, function: ceil)
    }

    fileprivate func castToDecimalByPlacesHelper(_ places: Int, function: (Double) -> Double) -> Double {
        let divisor = pow(10.0, Double(places))
        return function(self * divisor) / divisor
    }
}

extension String {
    init(_ value: Float, precision: Int) {
        let nFormatter = NumberFormatter()
        nFormatter.numberStyle = .decimal
        nFormatter.maximumFractionDigits = precision
        self = nFormatter.string(from: NSNumber(value: value))!
    }

    init(_ value: Double, precision: Int) {
        let nFormatter = NumberFormatter()
        nFormatter.numberStyle = .decimal
        nFormatter.maximumFractionDigits = precision
        self = nFormatter.string(from: NSNumber(value: value))!
    }
}
