//
//  SPTBitrate.swift
//  Newsic
//
//  Created by Miguel Alcantara on 04/01/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import Foundation

extension SPTBitrate {
    
    func description() -> String {
        switch self {
        case .low: return "Low"
        case .normal: return "Normal"
        case .high: return "High"
        }
    }
 
}
