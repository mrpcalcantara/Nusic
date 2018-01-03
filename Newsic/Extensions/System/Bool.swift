//
//  Bool.swift
//  Newsic
//
//  Created by Miguel Alcantara on 03/01/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import Foundation

extension Bool {
    
    func toString() -> String {
        let value = self == true ? "On" : "Off"
        return value
    }
    
}
