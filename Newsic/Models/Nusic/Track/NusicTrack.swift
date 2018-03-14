//
//  NusicTrack.swift
//  Nusic
//
//  Created by Miguel Alcantara on 07/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation
import FirebaseDatabase

class NusicTrack {
    
    var youtubeInfo: YouTubeResult?
    var trackInfo: SpotifyTrack
    var userName: String {
        didSet {
            userName.replace(symbol: ".", with: "-")
        }
    }
    var moodInfo: NusicMood?;
    var suggestionInfo: NusicSuggestion?
    var isLiked: Bool?
    var reference: DatabaseReference! = Database.database().reference()
    
    init(trackInfo: SpotifyTrack, moodInfo: NusicMood?, userName: String, youtubeInfo: YouTubeResult? = nil, suggestionInfo: NusicSuggestion? = NusicSuggestion(), isLiked: Bool? = false) {
        self.trackInfo = trackInfo;
        self.moodInfo = moodInfo;
        let firebaseUsername = userName.replaceSymbols(symbol: ".", with: "-")
        self.userName = firebaseUsername
        self.youtubeInfo = youtubeInfo;
        self.suggestionInfo = suggestionInfo
        self.isLiked = isLiked
        self.reference = Database.database().reference().child("likedTracks");
        setupListeners()
    }
    
    private func setupListeners() {
        
        //Save
        Database.database().reference().child("likedTracks").child(userName).observe(.childAdded) { (dataSnapshot) in
            if dataSnapshot.key == self.trackInfo.linkedFromTrackId {
                if let moodInfo = self.moodInfo, self.isLiked! {
                    for emotion in moodInfo.emotions {
                        Database.database().reference()
                            .child("moodTracks")
                            .child(self.userName)
                            .child(emotion.basicGroup.rawValue.lowercased())
                            .child(self.trackInfo.linkedFromTrackId)
                                .setValue(true)
                    }
                }
            }
        }
        
        //Update
        Database.database().reference().child("likedTracks").child(userName).observe(.childChanged) { (dataSnapshot) in
            if dataSnapshot.key == self.trackInfo.linkedFromTrackId {
                if let moodInfo = self.moodInfo {
                    for emotion in moodInfo.emotions {
                        Database.database().reference()
                            .child("moodTracks")
                            .child(self.userName)
                            .child(emotion.basicGroup.rawValue.lowercased())
                            .child(self.trackInfo.linkedFromTrackId)
                            .setValue(true)
                    }
                }
            }
        }
        
        //Delete
        Database.database().reference().child("likedTracks").child(userName).observe(.childRemoved) { (dataSnapshot) in
            if dataSnapshot.key == self.trackInfo.linkedFromTrackId {
                if let moodInfo = self.moodInfo {
                    for emotion in moodInfo.emotions {
                        Database.database().reference()
                            .child("moodTracks")
                            .child(self.userName)
                            .child(emotion.basicGroup.rawValue.lowercased())
                            .child(self.trackInfo.linkedFromTrackId)
                            .setValue(nil)
                    }
                }
            }
        }
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
            let dict = audioFeatures.toDictionary();
            
            Database.database().reference().child("trackFeatures").child(trackInfo.trackId!).updateChildValues(dict) { (error, reference) in
                if let error = error {
                    saveCompleteHandler(reference, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.deleteLikedTracks.rawValue, systemError: error))
                } else {
                    print(reference)
                    
                    
                }
            }
            
            Database.database().reference().child("likedTracks").child(self.userName).child(self.trackInfo.linkedFromTrackId).child("likedOn").setValue(dateString as AnyObject)
            saveCompleteHandler(reference, nil)
        }
        
    }
    
    internal func deleteData(deleteCompleteHandler: @escaping (DatabaseReference?, NusicError?) -> ()) {
        Database.database().reference().child("likedTracks").child(self.userName).child(self.trackInfo.linkedFromTrackId).child("likedOn").removeValue()
        deleteCompleteHandler(reference, nil)
    }
    
    final func setSuggestedValue(value: Bool, suggestedHandler: ((DatabaseReference?, NusicError?) -> ())?) {
        suggestionInfo?.isNewSuggestion = false
        Database.database().reference().child("suggestedTracks").child(self.userName).child(self.trackInfo.linkedFromTrackId).child("isNewSuggestion").setValue(0) { (error, reference) in
            if let error = error {
                suggestedHandler?(nil, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.setSuggestedSong.rawValue, systemError: error))
            }
            suggestedHandler?(reference,nil);
        }
    }
    
    final func setSongLiked(value: Bool) {
        self.isLiked = value
    }
    
}
