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
    
    var trackInfo: SpotifyTrack
    var userName: String
    var moodInfo: NewsicMood?;
    var reference: DatabaseReference! = Database.database().reference()
    
    init(trackInfo: SpotifyTrack, moodInfo: NewsicMood?, userName: String) {
        self.trackInfo = trackInfo;
        self.moodInfo = moodInfo;
        self.userName = userName;
        self.reference = Database.database().reference().child("likedTracks");
    }
    
}

extension NewsicTrack : FirebaseModel {
    
    internal func getData(getCompleteHandler: @escaping (NSDictionary?, Error?) -> ()) {
        reference.child(userName).observeSingleEvent(of: .value, with: { (dataSnapshot) in
            let value = dataSnapshot.value as? NSDictionary
            getCompleteHandler(value, nil);
        }) { (error) in
            getCompleteHandler(nil, error);
        }
        
        
    }
    
    internal func saveData(saveCompleteHandler: @escaping (DatabaseReference?, Error?) -> ()) {
        
        if let audioFeatures = trackInfo.audioFeatures {
            if let moodInfo = moodInfo {
                for emotion in moodInfo.emotions {
                    reference.child(userName).child("moods").child(emotion.basicGroup.rawValue.lowercased()).child(trackInfo.trackId!).updateChildValues(audioFeatures.toDictionary()) { (error, reference) in
                        if let error = error {
                            saveCompleteHandler(reference, error)
                        }
                    }
                }
            } else {
                reference.child(userName).child("moods").child(EmotionDyad.unknown.rawValue).child(trackInfo.trackId!).updateChildValues(audioFeatures.toDictionary()) { (error, reference) in
                        if let error = error {
                            saveCompleteHandler(reference, error)
                        }
                    }
                }
            saveCompleteHandler(reference, nil)
        }
        
    }
    
    internal func deleteData(deleteCompleteHandler: @escaping (DatabaseReference?, Error?) -> ()) {
        reference.child(userName).removeValue { (error, databaseReference) in
            deleteCompleteHandler(self.reference, error)
        }
    }
    
}
