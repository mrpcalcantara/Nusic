//
//  Int.swift
//  Nusic
//
//  Created by Miguel Alcantara on 28/08/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation

extension Int
{
    static func random(range: Range<Int> ) -> Int
    {
        var offset = 0
        
        if range.lowerBound < 0   // allow negative ranges
        {
            offset = abs(range.lowerBound)
        }
        
        let minimumValue = UInt32(range.lowerBound + offset)
        let maximumValue = UInt32(range.upperBound   + offset)
        
        return Int(minimumValue + arc4random_uniform(maximumValue - minimumValue)) - offset
    }
}
