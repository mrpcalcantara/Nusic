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
    
    class func detectFirebaseConnectivity(connectivityHandler: @escaping (Bool) -> ()) {
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            connectivityHandler(snapshot.value as! Bool)
        })
    }
    
    class func deleteUserData(user: String, deleteDataHandler: @escaping (DatabaseReference, Error?) -> ()) {
        let reference = Database.database().reference().child("emotions").child(user)

        
        reference.observe(.value) { (snapshot) in
            reference.runTransactionBlock({ (data) -> TransactionResult in
                
                if var currentData = data.value as? [String: AnyObject] {
                    
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
        let user = NewsicUser(userName: user)
    
    }
    
}
