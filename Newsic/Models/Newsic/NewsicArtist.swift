//
//  NewsicArtist.swift
//  Newsic
//
//  Created by Miguel Alcantara on 07/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct NewsicArtist {
    
    let spotifyArtist: SpotifyArtist;
    let userName: String
    var reference: DatabaseReference!
    
    init(artist: SpotifyArtist, userName: String) {
        self.spotifyArtist = artist;
        self.userName = userName;
        self.reference = Database.database().reference().child("users");
    }
    
}

extension NewsicArtist: FirebaseModel {
    
    internal func getData(getCompleteHandler: @escaping (NSDictionary?, Error?) -> ()) {
        reference.child(userName).observeSingleEvent(of: .value, with: { (dataSnapshot) in
            let value = dataSnapshot.value as? NSDictionary
            getCompleteHandler(value, nil);
        }) { (error) in
            getCompleteHandler(nil, error);
        }
        
        
    }
    
    internal func saveData(saveCompleteHandler: @escaping (DatabaseReference?, Error?) -> ()) {
//        let dict = ["name" : self.name]
//        reference.child(userName).child(self.id!).updateChildValues(dict) { (error, reference) in
//            saveCompleteHandler(reference, error)
//        }
        //        reference.child(userName).child(self.id!).updateChildValues(dict);
    }
    
    internal func deleteData(deleteCompleteHandler: @escaping (DatabaseReference?, Error?) -> ()) {
        reference.child(userName).removeValue { (error, databaseReference) in
            deleteCompleteHandler(self.reference, error)
        }
    }
    
    
}
