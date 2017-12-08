//
//  FirebaseHelper.swift
//  Newsic
//
//  Created by Miguel Alcantara on 08/12/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation
import FirebaseDatabase

class FirebaseHelper {
    
    class func deleteAllTracks(user: String, deleteTracksCompleteHandler: @escaping (DatabaseReference?, Error?) -> ()){
        Database.database().reference().child("likedTracks").child(user).removeValue { (error, databaseReference) in
            deleteTracksCompleteHandler(databaseReference, error)
        }
    }
    
}
