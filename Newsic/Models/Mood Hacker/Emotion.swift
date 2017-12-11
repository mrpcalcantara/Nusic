//
//  Emotion.swift
//  Newsic
//
//  Created by Miguel Alcantara on 01/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation

enum EmotionValue:Int {
    
    case joy;
    case anger;
    case sadness;
    case disgust;
    case fear;
    case trust;
    case anticipation;
    case surprise;
    func description() -> String {
        switch self {
            case .anger: return "anger"
            case .anticipation: return "anticipation"
            case .disgust: return "disgust"
            case .fear: return "fear"
            case .joy: return "joy"
            case .sadness: return "sadness"
            case .surprise: return "surprise"
            case .trust: return "trust"
        }
    }
    
}

struct Emotion {
    
    var basicGroup: EmotionDyad;
    var detailedEmotions: [String]
    var rating: Double
    
    init() {
        self.basicGroup = .none;
        self.detailedEmotions = [];
        self.rating = 0
    }
    
    init(basicGroup: EmotionDyad, detailedEmotions: [String], rating: Double) {
        self.basicGroup = basicGroup
        self.detailedEmotions = detailedEmotions;
        self.rating = rating;
    }
    
    func toDictionary() -> [String: AnyObject] {
        
        var dictionary: [String: AnyObject] = [:];
        //dictionary["basicGroup"] = self.basicGroup as AnyObject;
        
        dictionary["rating"] = self.rating as AnyObject;
        dictionary["emotions"] = self.detailedEmotions as AnyObject;
        return dictionary;
    }
}
