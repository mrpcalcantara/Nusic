//
//  NewsicTrack.swift
//  Newsic
//
//  Created by Miguel Alcantara on 07/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct NewsicTrack {
    
    var youtubeInfo: YouTubeResult?
    var trackInfo: SpotifyTrack
    var userName: String
    var moodInfo: NewsicMood?;
    var reference: DatabaseReference! = Database.database().reference()
    
    init(trackInfo: SpotifyTrack, moodInfo: NewsicMood?, userName: String, youtubeInfo: YouTubeResult? = nil) {
        self.trackInfo = trackInfo;
        self.moodInfo = moodInfo;
        self.userName = userName;
        self.youtubeInfo = youtubeInfo;
        self.reference = Database.database().reference().child("likedTracks");
    }
    
}

extension NewsicTrack : FirebaseModel {
    
    internal func getData(getCompleteHandler: @escaping (NSDictionary?, NewsicError?) -> ()) {
        reference.child(userName).observeSingleEvent(of: .value, with: { (dataSnapshot) in
            let value = dataSnapshot.value as? NSDictionary
            getCompleteHandler(value, nil);
        }) { (error) in
            getCompleteHandler(nil, NewsicError(newsicErrorCode: NewsicErrorCodes.firebaseError, newsicErrorSubCode: NewsicErrorSubCode.technicalError, newsicErrorDescription: FirebaseErrorCodeDescription.getLikedTracks.rawValue, systemError: error));
        }
        
        
    }
    
    internal func saveData(saveCompleteHandler: @escaping (DatabaseReference?, NewsicError?) -> ()) {
        
        if let audioFeatures = trackInfo.audioFeatures {
            if let moodInfo = moodInfo {
                for emotion in moodInfo.emotions {
                    reference.child(userName).child("moods").child(emotion.basicGroup.rawValue.lowercased()).child(trackInfo.trackId!).updateChildValues(audioFeatures.toDictionary()) { (error, reference) in
                        if let error = error {
                            saveCompleteHandler(reference, NewsicError(newsicErrorCode: NewsicErrorCodes.firebaseError, newsicErrorSubCode: NewsicErrorSubCode.technicalError, newsicErrorDescription: FirebaseErrorCodeDescription.saveLikedTracks.rawValue, systemError: error))
                        }
                    }
                }
            } else {
                reference.child(userName).child("moods").child(EmotionDyad.unknown.rawValue).child(trackInfo.trackId!).updateChildValues(audioFeatures.toDictionary()) { (error, reference) in
                        if let error = error {
                            saveCompleteHandler(reference, NewsicError(newsicErrorCode: NewsicErrorCodes.firebaseError, newsicErrorSubCode: NewsicErrorSubCode.technicalError, newsicErrorDescription: FirebaseErrorCodeDescription.deleteLikedTracks.rawValue, systemError: error))
                        }
                    }
                }
            saveCompleteHandler(reference, nil)
        }
        
    }
    
    internal func deleteData(deleteCompleteHandler: @escaping (DatabaseReference?, NewsicError?) -> ()) {
        if let moodInfo = moodInfo {
            for emotion in moodInfo.emotions {
                reference.child(userName).child("moods").child(emotion.basicGroup.rawValue.lowercased()).child(trackInfo.trackId!).removeValue(completionBlock: { (error, reference) in
                    if let error = error {
                        deleteCompleteHandler(reference, NewsicError(newsicErrorCode: NewsicErrorCodes.firebaseError, newsicErrorSubCode: NewsicErrorSubCode.technicalError, newsicErrorDescription: FirebaseErrorCodeDescription.deleteLikedTracks.rawValue, systemError: error))
                    }
                })
            }
        } else {
            //CYCLE BETWEEN ALL MOODS
            for dyad in EmotionDyad.allValues {
                
                reference.child(userName).child("moods").child(dyad.rawValue.lowercased()).child(trackInfo.trackId!).removeValue(completionBlock: { (error, reference) in
                    if let error = error {
                        deleteCompleteHandler(reference, NewsicError(newsicErrorCode: NewsicErrorCodes.firebaseError, newsicErrorSubCode: NewsicErrorSubCode.technicalError, newsicErrorDescription: FirebaseErrorCodeDescription.deleteLikedTracks.rawValue, systemError: error))
                    }
                })
            }
        }
        deleteCompleteHandler(reference, nil)
    }
    
    
    
}
