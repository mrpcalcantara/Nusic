//
//  Emotion.swift
//  Nusic
//
//  Created by Miguel Alcantara on 01/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation

struct Emotion {
    
    var basicGroup: EmotionDyad;
    var detailedEmotions: [String]?
    
    init() {
        self.basicGroup = .none;
        self.detailedEmotions = [];
    }
    
    init(basicGroup: EmotionDyad, detailedEmotions: [String]? = [String]()) {
        self.basicGroup = basicGroup
        self.detailedEmotions = detailedEmotions;
        
    }
    
    func toDictionary() -> [String: AnyObject] {
        
        var dictionary: [String: AnyObject] = [:];        
        dictionary["emotions"] = self.detailedEmotions as AnyObject;
        return dictionary;
    }
}
