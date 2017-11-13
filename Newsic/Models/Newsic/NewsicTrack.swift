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
        })
        
    }
    
    internal func saveData(saveCompleteHandler: @escaping (DatabaseReference?, Error?) -> ()) {
        if let moodInfo = moodInfo {
            for emotion in moodInfo.emotions {
                reference.child(userName).child("moods").child(emotion.basicGroup.rawValue.lowercased()).child(trackInfo.trackId!).setValue(trackInfo.audioFeatures?.toDictionary())
            }
        } else {
            reference.child(userName).child("moods").child(EmotionDyad.unknown.rawValue).child(trackInfo.trackId!).updateChildValues((trackInfo.audioFeatures?.toDictionary())!)
        }
        
        saveCompleteHandler(reference, nil);
    }
    
    internal func deleteData(deleteCompleteHandler: @escaping (DatabaseReference?, Error?) -> ()) {
        
        if let moodInfo = moodInfo {
            for emotion in moodInfo.emotions {
                reference.child(userName).child("moods").child(emotion.basicGroup.rawValue.lowercased()).child(trackInfo.trackId!).removeValue(completionBlock: { (error, ref) in
                    if error != nil {
                        print("error = \(error?.localizedDescription)")
                        deleteCompleteHandler(self.reference, nil)
                    }
                })
            }
            deleteCompleteHandler(self.reference, nil)
        } else {
            reference.child(userName).child("moods").child(EmotionDyad.unknown.rawValue).child(trackInfo.trackId!).removeValue(completionBlock: { (error, ref) in
                if error != nil {
                    print("error = \(error?.localizedDescription)")
                    deleteCompleteHandler(self.reference, nil)
                } else {
                    deleteCompleteHandler(self.reference, nil)
                }
            })
            
        }
    }
    
}
