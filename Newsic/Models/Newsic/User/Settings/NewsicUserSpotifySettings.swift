//
//  NusicUserSpotifySettings.swift
//  Nusic
//
//  Created by Miguel Alcantara on 04/01/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import Foundation

struct NusicUserSpotifySettings {
    
    var bitrate: SPTBitrate
    
    init(bitrate: SPTBitrate) {
        self.bitrate = bitrate
    }
    
    func toDictionary() -> [String: AnyObject] {
        var dict: [String: AnyObject] = [:]
        dict["bitrate"] = self.bitrate.rawValue as AnyObject
        return dict
    }
    
}
