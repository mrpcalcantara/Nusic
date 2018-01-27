//
//  NusicTrack.swift
//  Nusic
//
//  Created by Miguel Alcantara on 07/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct NusicTrack {
    
    var youtubeInfo: YouTubeResult?
    var trackInfo: SpotifyTrack
    var userName: String {
        didSet {
            userName.replace(symbol: ".", with: "-")
        }
    }
    var moodInfo: NusicMood?;
    var reference: DatabaseReference! = Database.database().reference()
    
    init(trackInfo: SpotifyTrack, moodInfo: NusicMood?, userName: String, youtubeInfo: YouTubeResult? = nil) {
        self.trackInfo = trackInfo;
        self.moodInfo = moodInfo;
        let firebaseUsername = userName.replaceSymbols(symbol: ".", with: "-")
        self.userName = firebaseUsername
        self.youtubeInfo = youtubeInfo;
        self.reference = Database.database().reference().child("likedTracks");
    }
    
}

extension NusicTrack : FirebaseModel {
    
    internal func getData(getCompleteHandler: @escaping (NSDictionary?, NusicError?) -> ()) {
        reference.child(userName).observeSingleEvent(of: .value, with: { (dataSnapshot) in
            let value = dataSnapshot.value as? NSDictionary
            getCompleteHandler(value, nil);
        }) { (error) in
            getCompleteHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.getLikedTracks.rawValue, systemError: error));
        }
        
        
    }
    
    internal func saveData(saveCompleteHandler: @escaping (DatabaseReference?, NusicError?) -> ()) {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
        let dateString = dateFormatter.string(from: date)
        if let audioFeatures = trackInfo.audioFeatures {
            if let moodInfo = moodInfo {
                for emotion in moodInfo.emotions {
                    var dict = audioFeatures.toDictionary();
                    
                    dict["addedOn"] = dateString as AnyObject;
                    reference.child(userName).child("moods").child(emotion.basicGroup.rawValue.lowercased()).child(trackInfo.trackId!).updateChildValues(dict) { (error, reference) in
                        if let error = error {
                            saveCompleteHandler(reference, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.saveLikedTracks.rawValue, systemError: error))
                        }
                    }
                }
            } else {
                var dict = audioFeatures.toDictionary();
                dict["addedOn"] = dateString as AnyObject
                reference.child(userName).child("moods").child(EmotionDyad.unknown.rawValue).child(trackInfo.trackId!).updateChildValues(dict) { (error, reference) in
                        if let error = error {
                            saveCompleteHandler(reference, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.deleteLikedTracks.rawValue, systemError: error))
                        }
                    }
                }
            saveCompleteHandler(reference, nil)
        }
        
    }
    
    internal func deleteData(deleteCompleteHandler: @escaping (DatabaseReference?, NusicError?) -> ()) {
        if let moodInfo = moodInfo {
            for emotion in moodInfo.emotions {
                reference.child(userName).child("moods").child(emotion.basicGroup.rawValue.lowercased()).child(trackInfo.trackId!).removeValue(completionBlock: { (error, reference) in
                    if let error = error {
                        deleteCompleteHandler(reference, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.deleteLikedTracks.rawValue, systemError: error))
                    }
                })
            }
        } else {
            //CYCLE BETWEEN ALL MOODS
            for dyad in EmotionDyad.allValues {
                
                reference.child(userName).child("moods").child(dyad.rawValue.lowercased()).child(trackInfo.trackId!).removeValue(completionBlock: { (error, reference) in
                    if let error = error {
                        deleteCompleteHandler(reference, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.deleteLikedTracks.rawValue, systemError: error))
                    }
                })
            }
        }
        deleteCompleteHandler(reference, nil)
    }
    
//    func getAddedMoods() {
//        let dispatchGroup = DispatchGroup()
//        let emotions: [String] = []
//        
//        dispatchGroup.enter()
//        FirebaseDatabaseHelper.fetchAllMoods(user: self.userName) { (dyads, error) in
//            self.getData(getCompleteHandler: { (dict, error) in
//                <#code#>
//            })
//            dispatchGroup.leave()
//        }
//        
//        dispatchGroup.wait()
//    }
    
    
}
