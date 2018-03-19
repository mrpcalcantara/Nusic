//
//  FirebaseHelper.swift
//  Nusic
//
//  Created by Miguel Alcantara on 08/12/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Firebase

class FirebaseDatabaseHelper {
    
    static let migrateDataUrl = "https://us-central1-newsic-54b6e.cloudfunctions.net/migrateData"
    
    class func detectFirebaseConnectivity(connectivityHandler: @escaping (Bool) -> ()) {
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            connectivityHandler(snapshot.value as! Bool)
        })
    }
    
    class func fetchAllMoods(user: String, fetchMoodsHandler: @escaping([EmotionCategory:[EmotionDyad]], NusicError?) -> ()) {
        Database.database().reference().child("emotions").observeSingleEvent(of: .value, with: { (dataSnapshot) in
            guard let values = dataSnapshot.value as? [String : AnyObject] else { return; }
            var emotionDict: [EmotionCategory: [EmotionDyad]] = [:]
            emotionDict[EmotionCategory.positive] =
                values.filter({ $0.value["valence"] as! Double >= 0.7 })
                    .map({ EmotionDyad(rawValue: $0.key.capitalizingFirstLetter())!  })
                    .sorted(by: { (dyad1, dyad2) -> Bool in return dyad1.rawValue < dyad2.rawValue })
            
            emotionDict[EmotionCategory.neutral] =
                values.filter({ ($0.value["valence"] as! Double) < 0.7 })
                    .filter({ ($0.value["valence"] as! Double) > 0.25 })
                    .map({ EmotionDyad(rawValue: $0.key.capitalizingFirstLetter())! })
                    .sorted(by: { (dyad1, dyad2) -> Bool in return dyad1.rawValue < dyad2.rawValue })
            
            emotionDict[EmotionCategory.negative] =
                values.filter({ ($0.value["valence"] as! Double) <= 0.25 })
                    .map({ EmotionDyad(rawValue: $0.key.capitalizingFirstLetter())! })
                    .sorted(by: { (dyad1, dyad2) -> Bool in return dyad1.rawValue < dyad2.rawValue })
            fetchMoodsHandler(emotionDict, nil)
        }) { (error) in
            fetchMoodsHandler(EmotionDyad.allValuesDict, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: "", systemError: error))
        }
    }
    
    class func deleteAllTracks(user: String, deleteTracksCompleteHandler: ( (DatabaseReference?, Error?) -> () )? ){
        Database.database().reference().child("likedTracks").child(user).removeValue { (error, databaseReference) in
            deleteTracksCompleteHandler?(databaseReference, error)
        }
    }
    
    class func deleteUserData(user: String, deleteDataHandler: @escaping (DatabaseReference, Error?) -> ()) {
        let reference = Database.database().reference().child("emotions").child(user)

        
        reference.observe(.value) { (snapshot) in
            reference.runTransactionBlock({ (data) -> TransactionResult in
                guard let currentData = data.value as? [String: AnyObject] else { return TransactionResult.abort() }
                data.value = currentData
                return TransactionResult.success(withValue: data)
            }) { (error, isCommited, snapshot) in
                
            }
        }
    }
    
    class func fetchTrackFeatures(for user: String, moodObject: NusicMood, fetchTrackFeaturesHandler: @escaping ([SpotifyTrackFeature]?) -> ()) {
        var trackFeatures = [SpotifyTrackFeature]()
        let dispatchGroup = DispatchGroup()
        let mood = moodObject.emotions.first?.basicGroup.rawValue.lowercased()
        let reference = Database.database().reference()
        dispatchGroup.enter()
        reference.child("moodTracks/\(user)/\(mood!)").observeSingleEvent(of: .value) { (dataSnapshot) in
            guard dataSnapshot.exists() else {
                moodObject.getDefaultTrackFeatures(getDefaultTrackFeaturesHandler: { (defaultTrackFeatures, error) in
                    guard let defaultTrackFeatures = defaultTrackFeatures else { return; }
                    trackFeatures = defaultTrackFeatures
                    dispatchGroup.leave()
                })
                return;
            }
            
            let childDispatchGroup = DispatchGroup()
            
            for child in dataSnapshot.children {
                childDispatchGroup.enter()
                let trackId = (child as! DataSnapshot).key
                reference.child("trackFeatures").child(trackId).observeSingleEvent(of: .value, with: { (childSnapshot) in
                    guard childSnapshot.exists() else { childDispatchGroup.leave(); return; }
                    trackFeatures.append(SpotifyTrackFeature(featureDictionary: childSnapshot.value as! [String: AnyObject]))
                    childDispatchGroup.leave()
                })
            }
            
            childDispatchGroup.notify(queue: .main, execute: {
                dispatchGroup.leave()
            })
        }
        
        dispatchGroup.notify(queue: .main) {
            fetchTrackFeaturesHandler(trackFeatures)
        }
    }
    
    class func migrateData(userId: String, migrationCompletionHandler: @escaping (Bool?, NusicError?) -> ()) {
        
        let firebaseMigrateDataURL = migrateDataUrl
        
        var urlComponents = URLComponents(string: firebaseMigrateDataURL)
        //
        urlComponents?.queryItems = []
        let username = userId.replaceSymbols(symbol: ".", with: "-")
        urlComponents?.queryItems?.insert(URLQueryItem(name: "uid", value: username), at: 0)
        
        let urlRequest = URLRequest(url: (urlComponents?.url)!)
        
        URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            guard error == nil else {
                migrationCompletionHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.serverError, nusicErrorDescription: FirebaseErrorCodeDescription.migrateDataToken.rawValue, systemError: error));
                return;
            }
            do {
                let parsedData = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: AnyObject]
                var success: Bool?
                var error: NusicError?
                if let parsedSuccess = parsedData["success"] as? Bool {
                    success = parsedSuccess
                } else {
                    error = NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.functionalError, nusicErrorDescription: FirebaseErrorCodeDescription.migrateDataToken.rawValue, systemError: error)
                }
                migrationCompletionHandler(success, error)
            } catch {
                migrationCompletionHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.functionalError, nusicErrorDescription: FirebaseErrorCodeDescription.migrateDataToken.rawValue, systemError: error))
            }
        }).resume()
    }
    
}
