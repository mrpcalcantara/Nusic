//
//  NewsicUserSpotifySettings.swift
//  Newsic
//
//  Created by Miguel Alcantara on 04/01/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import Foundation

struct NewsicUserSpotifySettings {
    
    var bitrate: SPTBitrate
    
    init(bitrate: SPTBitrate) {
        self.bitrate = bitrate
    }
    
    func toDictionary() -> [String: AnyObject] {
        var dict: [String: AnyObject] = [:]
        dict["bitrate"] = self.bitrate.rawValue as AnyObject
        return dict
    }
    
//    mutating func fromDictionary(dict: [String: Any]) {
//        let json = JSONSerialization.jsonObject(with: dict, options: .allowFragments) as! [String:Any]
//        print(json)
//    }
}
