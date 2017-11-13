//
//  NewsicPlaylist.swift
//  Newsic
//
//  Created by Miguel Alcantara on 13/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation
import FirebaseDatabase

class NewsicPlaylist {
    var reference: DatabaseReference!
    var name: String?;
    var id: String?;
    var userName: String;
    
    init(name: String? = nil, id: String? = nil, userName: String) {
        self.name = name;
        self.id = id;
        self.userName = userName;
        self.reference = Database.database().reference().child("playlists")
    }

}

extension NewsicPlaylist : FirebaseModel {
    internal func getData(getCompleteHandler: @escaping (NSDictionary?, Error?) -> ()) {
        reference.child(userName).observeSingleEvent(of: .value, with: { (dataSnapshot) in
            let value = dataSnapshot.value as? NSDictionary
            
            getCompleteHandler(value, nil);
        })
        
    }
    
    internal func saveData(saveCompleteHandler: @escaping (DatabaseReference?, Error?) -> ()) {
        let dict = ["name" : self.name]
        reference.child(userName).child(self.id!).updateChildValues(dict);
    }
    
    internal func deleteData(deleteCompleteHandler: @escaping (DatabaseReference?, Error?) -> ()) {
        reference.child(userName).removeValue { (error, databaseReference) in
            
        }
    }
    
    func getPlaylist(getPlaylistHandler: @escaping(NewsicPlaylist?) -> ()) {
        getData { (dict, error) in
            if error != nil || dict == nil {
                getPlaylistHandler(nil)
            } else {
                let convertedDict = dict as! [String: AnyObject]
                for (key, value) in convertedDict {
                    self.id = key;
                    let nameDict = value as! [String: String]
                    self.name = nameDict["name"]
                }
                getPlaylistHandler(self);
                /*
                let id = convertedDict["id"] as! String;
                let name = converted
                let playlist = NewsicPlaylist(name: <#T##String#>, id: id, userName: userName)
                */
            }
        }
    }
}
