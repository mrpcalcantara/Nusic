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
//    static let migrateDataUrl = "http://localhost:5000/newsic-54b6e/us-central1/migrateData"
    
    class func detectFirebaseConnectivity(connectivityHandler: @escaping (Bool) -> ()) {
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            connectivityHandler(snapshot.value as! Bool)
        })
    }
    
    class func fetchAllMoods(user: String, fetchMoodsHandler: @escaping([EmotionCategory:[EmotionDyad]], NusicError?) -> ()) {
        Database.database().reference().child("emotions").observeSingleEvent(of: .value, with: { (dataSnapshot) in
            if let values = dataSnapshot.value as? [String : AnyObject] {
                
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
                
            }
        }) { (error) in
            fetchMoodsHandler(EmotionDyad.allValuesDict, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: "", systemError: error))
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
                
            }
        }
    }
    
    private class func fetchAllDataForDelete(user: String, fetchAllDataHandler: @escaping ([[String: AnyObject]]) -> ()) {
        let user = NusicUser(userName: user)
    
    }
    
    class func fetchTrackFeatures(for user: String, moodObject: NusicMood, fetchTrackFeaturesHandler: @escaping ([SpotifyTrackFeature]?) -> ()) {
        var trackFeatures = [SpotifyTrackFeature]()
        var index = 0
        let mood = moodObject.emotions.first?.basicGroup.rawValue.lowercased()
        let reference = Database.database().reference()
            reference.child("moodTracks/\(user)/\(mood!)").observeSingleEvent(of: .value) { (dataSnapshot) in
                if dataSnapshot.exists() {
                    for child in dataSnapshot.children {
                        
                        let trackId = (child as! DataSnapshot).key
                        reference.child("trackFeatures").child(trackId).observeSingleEvent(of: .value, with: { (childSnapshot) in
                            if childSnapshot.exists() {
                                var features = SpotifyTrackFeature()
                                features.mapDictionary(featureDictionary: childSnapshot.value as! [String: AnyObject])
                                trackFeatures.append(features)
                                index += 1
                                if index >= dataSnapshot.childrenCount - 1 {
                                    fetchTrackFeaturesHandler(trackFeatures)
                                }
                            }
                        })
                    }
                } else {
                    moodObject.getDefaultTrackFeatures(getDefaultTrackFeaturesHandler: { (trackFeatures, error) in
                        if let trackFeatures = trackFeatures {
                            fetchTrackFeaturesHandler(trackFeatures)
                        }
                    })
                }
                
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
            if let error = error {
                migrationCompletionHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.serverError, nusicErrorDescription: FirebaseErrorCodeDescription.migrateDataToken.rawValue, systemError: error));
            } else {
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: AnyObject]
                    if let success = parsedData["success"] as? Bool {
                        migrationCompletionHandler(success, nil)
                    } else {
                        migrationCompletionHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.functionalError, nusicErrorDescription: FirebaseErrorCodeDescription.migrateDataToken.rawValue, systemError: error))
                    }
                    
                    
                } catch {
                    migrationCompletionHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.functionalError, nusicErrorDescription: FirebaseErrorCodeDescription.migrateDataToken.rawValue, systemError: error))
                }
                
            }
        }).resume()
    }
    
}
