//
//  SPTAuth.swift
//  Nusic
//
//  Created by Miguel Alcantara on 06/12/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation

extension SPTAuth {
    func resetCurrentLogin() {
//        self.session = nil
//        let userDefaults = UserDefaults.standard;
//        userDefaults.set(nil, forKey: "SpotifySession")
//        userDefaults.synchronize()
//        NotificationCenter.default.post(name: Notification.Name(rawValue: "resetLogin"), object: nil)
        UserDefaults.standard.removeObject(forKey: "SpotifySession");
        UserDefaults.standard.synchronize();
    }
}
