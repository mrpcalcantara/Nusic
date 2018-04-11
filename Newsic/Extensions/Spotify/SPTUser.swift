//
//  SPTUser.swift
//  Newsic
//
//  Created by Miguel Alcantara on 11/04/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import Foundation

extension SPTUser {
    final func isPremium() -> Bool {
        return self.product == SPTProduct.premium;
    }
}
