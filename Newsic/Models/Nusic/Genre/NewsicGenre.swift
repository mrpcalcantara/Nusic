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
    var userName: String {
        didSet {
            userName.replace(symbol: ".", with: "-")
        }
    }
    var mainGenre: String;
    var count: Int;
    
    init(mainGenre: String, count: Int, userName: String) {
        self.mainGenre = mainGenre;
        self.count = count;
        let firebaseUsername = userName.replaceSymbols(symbol: ".", with: "-")
        self.userName = firebaseUsername
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
            let error = error == nil ? nil : NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.saveGenre.rawValue, systemError: error);
            saveCompleteHandler(reference, error);
        }
    }
    
    internal func deleteData(deleteCompleteHandler: @escaping (DatabaseReference?, NusicError?) -> ()) {
        reference.child(userName).child(mainGenre).removeValue { (error, databaseReference) in
            let error = error == nil ? nil : NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.deleteGenre.rawValue, systemError: error);
            deleteCompleteHandler(self.reference, error)
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
        Database.database().reference().child("genres").child(userName).updateChildValues(genreList) { (error, reference) in
            let error = error == nil ? nil : NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.saveFavoriteGenres.rawValue, systemError: error)
            saveGenresHandler(error == nil, error)
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
