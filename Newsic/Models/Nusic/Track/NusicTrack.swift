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
    var reference: DatabaseReference! = Database.database().reference()
    weak var moodInfo: NusicMood?;
    var suggestionInfo: NusicSuggestion?
    var userName: String {
        didSet {
            userName.replace(symbol: ".", with: "-")
        }
    }
    
    var isLiked: Bool?
    
    
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
            self.updateMoodTrack(track: dataSnapshot.key, value: true)
        }
        
        //Update
        Database.database().reference().child("likedTracks").child(userName).observe(.childChanged) { (dataSnapshot) in
            self.updateMoodTrack(track: dataSnapshot.key, value: true)
        }
        
        //Delete
        Database.database().reference().child("likedTracks").child(userName).observe(.childRemoved) { (dataSnapshot) in
            self.updateMoodTrack(track: dataSnapshot.key, value: nil)
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
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
        let dateString = dateFormatter.string(from: Date())
        guard let dict = trackInfo.audioFeatures?.toDictionary() else { return; }
        Database.database().reference().child("trackFeatures").child(trackInfo.linkedFromTrackId!).updateChildValues(dict) { (error, reference) in
            if let error = error {
                saveCompleteHandler(reference, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.deleteLikedTracks.rawValue, systemError: error))
            }
        }
        
        Database.database().reference().child("likedTracks").child(self.userName).child(self.trackInfo.linkedFromTrackId).child("likedOn").setValue(dateString as AnyObject)
        saveCompleteHandler(reference, nil)
        
    }
    
    internal func deleteData(deleteCompleteHandler: @escaping (DatabaseReference?, NusicError?) -> ()) {
        Database.database().reference().child("likedTracks").child(self.userName).child(self.trackInfo.linkedFromTrackId).child("likedOn").removeValue()
        deleteCompleteHandler(reference, nil)
    }
    
    final func setSuggestedValue(value: Bool, suggestedHandler: ((DatabaseReference?, NusicError?) -> ())?) {
        suggestionInfo?.isNewSuggestion = false
        Database.database().reference().child("suggestedTracks").child(self.userName).child(self.trackInfo.linkedFromTrackId).child("isNewSuggestion").setValue(0) { (error, reference) in
            let error = error == nil ? nil : NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.setSuggestedSong.rawValue, systemError: error)
            suggestedHandler?(reference,error)
        }
    }
    
    final func setSongLiked(value: Bool) {
        self.isLiked = value
    }
    
    private func updateMoodTrack(track: String, value: Bool?) {
        if let moodInfo = self.moodInfo, self.isLiked! {
            var trackToDelete = ""
            if track == self.trackInfo.linkedFromTrackId {
                trackToDelete = self.trackInfo.linkedFromTrackId
            } else if track == self.trackInfo.trackId {
                trackToDelete = self.trackInfo.trackId
            }
            
            guard trackToDelete != "" else { return }
            for emotion in moodInfo.emotions {
                Database.database().reference()
                    .child("moodTracks")
                    .child(self.userName)
                    .child(emotion.basicGroup.rawValue.lowercased())
                    .child(trackToDelete)
                    .setValue(value)
            }
        }
    }
    
}

extension Array where Element == NusicTrack {
    func containsTrack(trackId: String) -> Bool {
        for track in self {
            if track.trackInfo.trackId == trackId {
                return true;
            }
        }
        return false;
    }
    
    func setLikedList() -> [NusicTrack] {
        var likedList = [NusicTrack]()
        for track in self {
            track.isLiked = true
            likedList.append(track)
        }
        return likedList
    }
}
