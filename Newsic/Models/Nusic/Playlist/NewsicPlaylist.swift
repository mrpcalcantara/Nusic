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
    var userName: String {
        didSet {
            userName.replace(symbol: ".", with: "-")
        }
    }
    
    init(name: String? = nil, id: String? = nil, userName: String) {
        self.name = name;
        self.id = id;
        let firebaseUsername = userName.replaceSymbols(symbol: ".", with: "-")
        self.userName = firebaseUsername
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
        reference.child(userName).child(self.id!).setValue(dict);
        saveCompleteHandler(reference, nil)
    }
    
    internal func deleteData(deleteCompleteHandler: @escaping (DatabaseReference?, NusicError?) -> ()) {
        reference.child(userName).removeValue { (error, databaseReference) in
            guard error == nil else { deleteCompleteHandler(self.reference, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.deletePlaylist.rawValue, systemError: error)); return; }
            deleteCompleteHandler(self.reference, nil)
        }
    }
    
    final func getPlaylist(getPlaylistHandler: @escaping(NusicPlaylist?, NusicError?) -> ()) {
        getData { (dict, error) in
            guard let convertedDict = dict as? [String: AnyObject] else { getPlaylistHandler(nil, error); return; }
            for (key, value) in convertedDict {
                self.id = key;
                let nameDict = value as! [String: String]
                self.name = nameDict["name"]
            }
            getPlaylistHandler(self, nil);
        }
    }
    
    final func addNewPlaylist(addNewPlaylistHandler: @escaping (Bool?, NusicError?) -> ()) {
        deleteData { (reference, error) in
            self.saveData(saveCompleteHandler: { (reference, error) in
                guard error == nil else { addNewPlaylistHandler(false, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.addNewPlaylist.rawValue, systemError: error)); return; }
                addNewPlaylistHandler(true, nil)
            })
        }
    }
}
