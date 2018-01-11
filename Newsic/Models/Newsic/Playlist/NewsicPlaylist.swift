//
//  NusicPlaylist.swift
//  Nusic
//
//  Created by Miguel Alcantara on 13/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation
import FirebaseDatabase

class NusicPlaylist {
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

extension NusicPlaylist : FirebaseModel {
    internal func getData(getCompleteHandler: @escaping (NSDictionary?, NusicError?) -> ()) {
        reference.child(userName).observeSingleEvent(of: .value, with: { (dataSnapshot) in
            let value = dataSnapshot.value as? NSDictionary
            getCompleteHandler(value, nil);
        }) { (error) in
            getCompleteHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.getPlaylist.rawValue, systemError: error));
        }
        
        
    }
    
    internal func saveData(saveCompleteHandler: @escaping (DatabaseReference?, NusicError?) -> ()) {
        let dict = ["name" : self.name!]
        
//        reference.child(userName).child(self.id!).setValue(dict) { (error, reference) in
//            saveCompleteHandler(reference, error)
//        }
        reference.child(userName).child(self.id!).setValue(dict);
        saveCompleteHandler(reference, nil)
//        reference.child(userName).child(self.id!).updateChildValues(dict);
    }
    
    internal func deleteData(deleteCompleteHandler: @escaping (DatabaseReference?, NusicError?) -> ()) {
        reference.child(userName).removeValue { (error, databaseReference) in
            if let error = error {
                deleteCompleteHandler(self.reference, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.deletePlaylist.rawValue, systemError: error))
            } else {
                deleteCompleteHandler(self.reference, nil)
            }
            
        }
    }
    
    func getPlaylist(getPlaylistHandler: @escaping(NusicPlaylist?, NusicError?) -> ()) {
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
                let playlist = NusicPlaylist(name: <#T##String#>, id: id, userName: userName)
                */
            }
        }
    }
    
    func addNewPlaylist(addNewPlaylistHandler: @escaping (Bool?, NusicError?) -> ()) {
        deleteData { (reference, error) in
            self.saveData(saveCompleteHandler: { (reference, error) in
                if let error = error {
                    addNewPlaylistHandler(false, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.addNewPlaylist.rawValue, systemError: error))
                } else {
                    addNewPlaylistHandler(true, nil)
                }
            })
        }
    }
}
