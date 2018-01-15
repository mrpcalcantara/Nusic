//
//  FirebaseHelper.swift
//  Nusic
//
//  Created by Miguel Alcantara on 08/12/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation
import FirebaseDatabase

class FirebaseHelper {
    
    class func detectFirebaseConnectivity(connectivityHandler: @escaping (Bool) -> ()) {
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            connectivityHandler(snapshot.value as! Bool)
        })
    }
    
    class func fetchAllMoods(user: String, fetchMoodsHandler: @escaping([EmotionDyad], NusicError?) -> ()) {
        Database.database().reference().child("emotions").observeSingleEvent(of: .value, with: { (dataSnapshot) in
            if let values = dataSnapshot.value as? [String : AnyObject] {
                var dyadList: [EmotionDyad] = []
                for key in values.keys {
                    if let dyad = EmotionDyad(rawValue: key.capitalizingFirstLetter()) {
                        dyadList.append(dyad);
                    }
                    
                }
                fetchMoodsHandler(dyadList.sorted(by: { (dyad1, dyad2) -> Bool in
                    return dyad1.rawValue < dyad2.rawValue
                }), nil)
            }
        }) { (error) in
            fetchMoodsHandler(EmotionDyad.allValues, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: "", systemError: error))
        }
    }
    
    class func deleteAllTracks(user: String, deleteTracksCompleteHandler: @escaping (DatabaseReference?, Error?) -> ()){
        Database.database().reference().child("likedTracks").child(user).removeValue { (error, databaseReference) in
            deleteTracksCompleteHandler(databaseReference, error)
        }
    }
    
    class func deleteUserData(user: String, deleteDataHandler: @escaping (DatabaseReference, Error?) -> ()) {
        let reference = Database.database().reference().child("emotions").child(user)

        
        reference.observe(.value) { (snapshot) in
            reference.runTransactionBlock({ (data) -> TransactionResult in
                
                if let currentData = data.value as? [String: AnyObject] {
                    
                    data.value = currentData
                    return TransactionResult.success(withValue: data)
                } else {
                    return TransactionResult.abort()
                }
                
            }) { (error, isCommited, snapshot) in
                print("completed")
            }
        }
    }
    
    private class func fetchAllDataForDelete(user: String, fetchAllDataHandler: @escaping ([[String: AnyObject]]) -> ()) {
        let user = NusicUser(userName: user)
    
    }
    
}
