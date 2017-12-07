//
//  SPTAuth.swift
//  Newsic
//
//  Created by Miguel Alcantara on 06/12/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation

extension SPTAuth {
    func resetCurrentLogin() {
        self.session = nil
        let userDefaults = UserDefaults.standard;
        userDefaults.set(nil, forKey: "SpotifySession")
        userDefaults.synchronize()
    }
}
