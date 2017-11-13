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
            //let extractedUsername = value?["canonicalUserName"] as? String ?? ""
            
            getCompleteHandler(value, nil);
        })
    }
    
    internal func saveData(saveCompleteHandler: @escaping (DatabaseReference?, Error?) -> ()) {
        
    }
    
    internal func deleteData(deleteCompleteHandler: @escaping (DatabaseReference?, Error?) -> ()) {
        reference.child(userName).removeValue { (error, databaseReference) in
            
        }
    }
    
}
