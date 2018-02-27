//
//  NusicSuggestion.swift
//  Newsic
//
//  Created by Miguel Alcantara on 27/02/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import Foundation

struct NusicSuggestion {

    var isNewSuggestion: Bool? = false
    var suggestionDate: Date? = nil
    
    init(isNewSuggestion: Bool? = false, suggestionDate: Date? = nil) {
        self.isNewSuggestion = isNewSuggestion
        self.suggestionDate = suggestionDate
    }
    
}
