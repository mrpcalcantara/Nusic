//
//  String.swift
//  Nusic
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
    
    mutating func replace(symbol: String, with replaceSymbol: String) {
        let strToReplace = self.replaceSymbols(symbol: symbol, with: replaceSymbol)
        self = strToReplace
    }
    
    func replaceSymbols(symbol: String, with replaceSymbol: String) -> String {
        let replace = self.replacingOccurrences(of: symbol, with: replaceSymbol)
        return replace
    }

}
