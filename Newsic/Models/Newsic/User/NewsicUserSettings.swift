//
//  NewsicUserSettings.swift
//  Newsic
//
//  Created by Miguel Alcantara on 16/12/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct NewsicUserSettings {
    
    var useMobileData: Bool?
    var preferredPlayer: NewsicPreferredPlayer?
    
    init(useMobileData: Bool? = false, preferredPlayer: NewsicPreferredPlayer? = .youtube) {
        self.useMobileData = useMobileData
        self.preferredPlayer = preferredPlayer
    }
    
}
