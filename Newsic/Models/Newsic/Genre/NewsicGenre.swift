//
//  NusicGenre.swift
//  Nusic
//
//  Created by Miguel Alcantara on 07/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Firebase

struct NusicGenre {
    
    var reference: DatabaseReference!
    var userName: String;
    var mainGenre: String;
    var count: Int;
    
    init(mainGenre: String, count: Int, userName: String) {
        self.mainGenre = mainGenre;
        self.count = count;
        self.userName = userName;
        self.reference = Database.database().reference().child("genres")
    }
    
}

extension NusicGenre: FirebaseModel {
    
    internal func getData(getCompleteHandler: @escaping (NSDictionary?, NusicError?) -> ()) {
        
        reference.child(userName).child(mainGenre).observeSingleEvent(of: .value, with: { (dataSnapshot) in
            let value = dataSnapshot.value as? NSDictionary
            getCompleteHandler(value, nil);
        }) { (error) in
            getCompleteHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.getGenre.rawValue, systemError: error));
        }
        
        
    }
    
    internal func saveData(saveCompleteHandler: @escaping (DatabaseReference?, NusicError?) -> ()) {
        let dictionary = [self.mainGenre: self.count]
        reference.child(userName).child(mainGenre).updateChildValues(dictionary) { (error, reference) in
            if let error = error {
                saveCompleteHandler(reference, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.saveGenre.rawValue, systemError: error))
            } else {
                saveCompleteHandler(reference, nil)
            }
            
        }
    }
    
    internal func deleteData(deleteCompleteHandler: @escaping (DatabaseReference?, NusicError?) -> ()) {
        reference.child(userName).child(mainGenre).removeValue { (error, databaseReference) in
            if let error = error {
                deleteCompleteHandler(self.reference, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.deleteGenre.rawValue, systemError: error))
            } else {
                deleteCompleteHandler(self.reference, nil)
            }
            
        }
    }
    
    static func getFavoriteGenres(for userName: String, readingUserGenresHandler: @escaping ([NusicGenre]?, NusicError?) -> ()) {
        Database.database().reference().child("genres").child(userName).observeSingleEvent(of: .value, with: { (dataSnapshot) in
            let value = dataSnapshot.value as? NSDictionary
            let convertedDict = value as! [String: Int]
            let genreList: [NusicGenre]? = convertGenreCountToGenres(userName: userName, dict: convertedDict)
            readingUserGenresHandler(genreList, nil)
        }, withCancel: { (error) in
            readingUserGenresHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.getFavoriteGenres.rawValue, systemError: error));
        })
    }
    
    static func saveGenres(for userName: String, genreList:[String: Int], saveGenresHandler: @escaping (Bool?, NusicError?) -> ()) {
        //let dictionary = user.dictionaryWithValues(forKeys: ["canonicalUserName","displayName","territory"]);
        Database.database().reference().child("genres").child(userName).updateChildValues(genreList) { (error, reference) in
            if let error = error {
                saveGenresHandler(false, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.saveFavoriteGenres.rawValue, systemError: error))
            } else {
                saveGenresHandler(true, nil)
            }
        }
    }
    
    static func convertGenreCountToGenres(userName: String, dict: [String: Int]) -> [NusicGenre] {
        var iterator = dict.makeIterator()
        
        var nextElement = iterator.next();
        var genreList: [NusicGenre] = []
        while nextElement != nil {
            if let element = nextElement {
                genreList.append(NusicGenre(mainGenre: element.key, count: element.value, userName: userName))
            }
            nextElement = iterator.next()
        }
        return genreList;
    }
}
