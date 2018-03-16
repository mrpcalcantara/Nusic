//
//  Double.swift
//  Nusic
//
//  Created by Miguel Alcantara on 12/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation

extension Double {
    func roundToDecimalPlaces(places: Int) -> String {
        return String(format: "%.\(places)f", self)
    }
    
    func random(_ lower: Double = 0, _ upper: Double = 100) -> Double {
        return (Double(arc4random()) / 0xFFFFFFFF) * (upper - lower) + lower
    }
    
    mutating func randomInRange(value: Double, range: Double, acceptNegativeValues: Bool = true, maxValue: Double = 1) {
        let lowerBound = !acceptNegativeValues && value-range < 0 ? 0 : value-range;
        let upperBound = value + range > maxValue ? maxValue : value + range;
        self = random(lowerBound, upperBound)
    }
    
}
