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
        setupListeners()
    }
    
    func setupListeners() {
        
        //Save
        Database.database().reference().child("likedTracks").child(userName).observe(.childAdded) { (dataSnapshot) in
            if dataSnapshot.key == self.trackInfo.trackId {
                if let moodInfo = self.moodInfo {
                    for emotion in moodInfo.emotions {
                        Database.database().reference()
                            .child("moodTracks")
                            .child(self.userName)
                            .child(emotion.basicGroup.rawValue.lowercased())
                            .child(self.trackInfo.trackId)
                                .setValue(true)
                    }
                }
            }
        }
        
        //Delete
        Database.database().reference().child("likedTracks").child(userName).observe(.childRemoved) { (dataSnapshot) in
            if dataSnapshot.key == self.trackInfo.trackId {
                if let moodInfo = self.moodInfo {
                    for emotion in moodInfo.emotions {
                        Database.database().reference()
                            .child("moodTracks")
                            .child(self.userName)
                            .child(emotion.basicGroup.rawValue.lowercased())
                            .child(self.trackInfo.trackId)
                            .removeValue()
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
            var dict = audioFeatures.toDictionary();
            
            Database.database().reference().child("trackFeatures").child(trackInfo.trackId!).updateChildValues(dict) { (error, reference) in
                if let error = error {
                    saveCompleteHandler(reference, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.deleteLikedTracks.rawValue, systemError: error))
                } else {
                    print(reference)
                    
                    
                }
            }
            
            Database.database().reference().child("likedTracks").child(self.userName).child(self.trackInfo.trackId).child("likedOn").setValue(dateString as AnyObject)
            saveCompleteHandler(reference, nil)
        }
        
    }
    
    internal func deleteData(deleteCompleteHandler: @escaping (DatabaseReference?, NusicError?) -> ()) {
    Database.database().reference().child("likedTracks").child(self.userName).child(self.trackInfo.trackId).child("likedOn").removeValue()
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
