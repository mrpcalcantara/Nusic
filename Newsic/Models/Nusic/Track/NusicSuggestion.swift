//
//  NusicSuggestion.swift
//  Newsic
//
//  Created by Miguel Alcantara on 27/02/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import Foundation

class NusicSuggestion {

    var isNewSuggestion: Bool? = false
    var suggestionDate: Date? = nil
    
    init(isNewSuggestion: Bool? = false, suggestionDate: Date? = nil) {
        self.isNewSuggestion = isNewSuggestion
        self.suggestionDate = suggestionDate
    }
    
    convenience init(dictionary: [String: AnyObject]) {
        self.init()
        mapDictionary(dictionary: dictionary)
    }
    
    private func mapDictionary(dictionary: [String: AnyObject]) {
        guard let newSuggestionValue = dictionary["isNewSuggestion"] as? NSNumber, let suggestionDateValue = dictionary["suggestedOn"] as? String else { return; }
        self.isNewSuggestion = Bool(truncating: newSuggestionValue)
        self.suggestionDate = Date().fromString(dateString: suggestionDateValue, dateFormat: "yyyy-MM-dd'T'HH:mm:ss+hhmm")
    }
    
}


