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
    internal func getData(getCompleteHandler: @escaping (NSDictionary?, NewsicError?) -> ()) {
        reference.child(userName).observeSingleEvent(of: .value, with: { (dataSnapshot) in
            let value = dataSnapshot.value as? NSDictionary
            getCompleteHandler(value, nil);
        }) { (error) in
            getCompleteHandler(nil, NewsicError(newsicErrorCode: NewsicErrorCodes.firebaseError, newsicErrorSubCode: NewsicErrorSubCode.technicalError, newsicErrorDescription: FirebaseErrorCodeDescription.getPlaylist.rawValue, systemError: error));
        }
        
        
    }
    
    internal func saveData(saveCompleteHandler: @escaping (DatabaseReference?, NewsicError?) -> ()) {
        let dict = ["name" : self.name!]
        
//        reference.child(userName).child(self.id!).setValue(dict) { (error, reference) in
//            saveCompleteHandler(reference, error)
//        }
        reference.child(userName).child(self.id!).setValue(dict);
        saveCompleteHandler(reference, nil)
//        reference.child(userName).child(self.id!).updateChildValues(dict);
    }
    
    internal func deleteData(deleteCompleteHandler: @escaping (DatabaseReference?, NewsicError?) -> ()) {
        reference.child(userName).removeValue { (error, databaseReference) in
            if let error = error {
                deleteCompleteHandler(self.reference, NewsicError(newsicErrorCode: NewsicErrorCodes.firebaseError, newsicErrorSubCode: NewsicErrorSubCode.technicalError, newsicErrorDescription: FirebaseErrorCodeDescription.deletePlaylist.rawValue, systemError: error))
            } else {
                deleteCompleteHandler(self.reference, nil)
            }
            
        }
    }
    
    func getPlaylist(getPlaylistHandler: @escaping(NewsicPlaylist?, NewsicError?) -> ()) {
        getData { (dict, error) in
            if error != nil || dict == nil {
                getPlaylistHandler(nil, error)
            } else {
                let convertedDict = dict as! [String: AnyObject]
                for (key, value) in convertedDict {
                    self.id = key;
                    let nameDict = value as! [String: String]
                    self.name = nameDict["name"]
                }
                getPlaylistHandler(self, nil);
                /*
                let id = convertedDict["id"] as! String;
                let name = converted
                let playlist = NewsicPlaylist(name: <#T##String#>, id: id, userName: userName)
                */
            }
        }
    }
    
    func addNewPlaylist(addNewPlaylistHandler: @escaping (Bool?, NewsicError?) -> ()) {
        deleteData { (reference, error) in
            self.saveData(saveCompleteHandler: { (reference, error) in
                if let error = error {
                    addNewPlaylistHandler(false, NewsicError(newsicErrorCode: NewsicErrorCodes.firebaseError, newsicErrorSubCode: NewsicErrorSubCode.technicalError, newsicErrorDescription: FirebaseErrorCodeDescription.addNewPlaylist.rawValue, systemError: error))
                } else {
                    addNewPlaylistHandler(true, nil)
                }
            })
        }
    }
}
