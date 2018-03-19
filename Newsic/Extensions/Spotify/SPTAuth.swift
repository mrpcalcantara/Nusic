//
//  SPTAuth.swift
//  Nusic
//
//  Created by Miguel Alcantara on 06/12/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation

extension SPTAuth {
    final func resetCurrentLogin() {
        UserDefaults.standard.removeObject(forKey: "SpotifySession");
        UserDefaults.standard.synchronize();
    }
}
