//
//  String.swift
//  Newsic
//
//  Created by Miguel Alcantara on 21/11/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation

extension String {
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
}
