//
//  NusicUserSettings.swift
//  Nusic
//
//  Created by Miguel Alcantara on 16/12/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct NusicUserSettings {
    
    var useMobileData: Bool?
    var preferredPlayer: NusicPreferredPlayer?
    var spotifySettings: NusicUserSpotifySettings?
    
    init(useMobileData: Bool? = false, preferredPlayer: NusicPreferredPlayer? = .youtube, spotifySettings: NusicUserSpotifySettings? = NusicUserSpotifySettings(bitrate: SPTBitrate.normal)) {
        self.useMobileData = useMobileData
        self.preferredPlayer = preferredPlayer
        self.spotifySettings = spotifySettings
    }
    
    
    
}
