//
//  ArrayString.swift
//  Newsic
//
//  Created by Miguel Alcantara on 15/01/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import Foundation

extension Array where Element == String {
    func getFirstLetterArray(removeDuplicates: Bool? = false) -> [String] {
        var array:[String] = []
        for value in self {
            if let firstCharacter = value.first {
                var addValue = removeDuplicates! && array.contains("\(firstCharacter)") ? false : true
                if addValue {
                    array.insert(firstCharacter.description, at: 0)
                }
            }
        }
        return array
    }
    
    func removeDuplicates() -> [String] {
        var uniqueArray:[String] = []
        
        _ = self.filter({
            if uniqueArray.contains($0) {
                return false
            } else {
                uniqueArray.insert($0, at: 0)
                return true
            }
        })
        return uniqueArray
    }
}
