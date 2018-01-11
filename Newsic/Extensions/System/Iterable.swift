//
//  Loopable.swift
//  Nusic
//
//  Created by Miguel Alcantara on 11/12/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation

protocol Iterable {
    func allProperties() throws -> [String: Any]
}

extension Iterable {
    func allProperties() throws -> [String: Any] {
        
        var result: [String: Any] = [:]
        
        let mirror = Mirror(reflecting: self)
        
        // Optional check to make sure we're iterating over a struct or class
        guard let style = mirror.displayStyle, style == .struct || style == .class else {
            throw NSError()
        }
        
        for (property, value) in mirror.children {
            guard let property = property else {
                continue
            }
            
            result[property] = value
        }
        
        return result
    }
}
