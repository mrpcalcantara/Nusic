//
//  MoodHackerResult.swift
//  Nusic
//
//  Created by Miguel Alcantara on 01/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation
import FirebaseDatabase

class NusicMood: FirebaseModel, Iterable {
    
    var emotions: [Emotion];
    var userName: String {
        didSet {
            userName.replace(symbol: ".", with: "-")
        }
    }
    var date: Date!
    var associatedGenres: [String];
    var reference: DatabaseReference!
    
    init() {
        self.emotions = []
        self.date = Date();
        self.userName = ""
        self.associatedGenres = [String]()
        self.reference = Database.database().reference();
    }
    
    init(emotions: [Emotion], date: Date, userName: String? = "", associatedGenres: [String]? = [String]()) {
        self.emotions = emotions;
        self.date = date;
        let firebaseUsername = userName!.replaceSymbols(symbol: ".", with: "-")
        self.userName = firebaseUsername
        self.associatedGenres = associatedGenres!
        self.reference = Database.database().reference();
    }
    
    internal func getData(getCompleteHandler: @escaping (NSDictionary?, NusicError?) -> ()) {
        reference.child("emotions").child(userName).observeSingleEvent(of: .value, with: { (dataSnapshot) in
            let value = dataSnapshot.value as? NSDictionary
            getCompleteHandler(value, nil);
        }) { (error) in
            getCompleteHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.getMoodInfo.rawValue, systemError: error));
        }
        
        
    }
    
    internal func saveData(saveCompleteHandler: @escaping (DatabaseReference?, NusicError?) -> ()) {
        var emotionArray: [[String: AnyObject]] = [];
        for emotion in emotions {
            let firstEmotion = emotion.toDictionary()
            emotionArray.append(firstEmotion)
            reference.child("emotions").child(userName).child(emotion.basicGroup.rawValue.lowercased()).child(date.toString()).updateChildValues(emotion.toDictionary()) { (error, reference) in
                let error = error == nil ? nil : NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.saveMoodInfo.rawValue, systemError: error);
                saveCompleteHandler(reference, error)
            }
        }

    }
    
    internal func deleteData(deleteCompleteHandler: @escaping (DatabaseReference?, NusicError?) -> ()) {
        reference.child("emotions").child(userName).removeValue { (error, databaseReference) in
            let error = error == nil ? nil : NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.deleteMoodInfo.rawValue, systemError: error)
            deleteCompleteHandler(self.reference, error)
        }
    }
    
    final func getTrackListForEmotionGenre(getAssociatedTrackHandler: @escaping ([String: SpotifyTrackFeature]?, NusicError?) -> ()) {
        let dispatchGroup = DispatchGroup()
        var error: NusicError?
        var extractedGenres:[String:SpotifyTrackFeature]?
        for emotion in emotions {
            dispatchGroup.enter()
            reference.child("likedTracks").child(userName).child("moods").child(emotion.basicGroup.rawValue.lowercased()).observeSingleEvent(of: .value, with: { (dataSnapshot) in
                extractedGenres = [:]
                let value = dataSnapshot.value as? [String: AnyObject];
                var iterator = value?.makeIterator()
                let element = iterator?.next()
                while element != nil {
                    
                    if let element = element, let dict = element.value as? [String: AnyObject] {
                        extractedGenres?[element.key] = SpotifyTrackFeature(featureDictionary: dict)
                    }
                }
                dispatchGroup.leave()
            }, withCancel: { (cancelError) in
                error = NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.getTrackListForEmotion.rawValue, systemError: cancelError)
                dispatchGroup.leave()
            })
        }
        
        dispatchGroup.notify(queue: .main) {
            getAssociatedTrackHandler(extractedGenres, error)
        }
        
    }
    
    final func getTrackIdListForEmotionGenre(getAssociatedTrackHandler: @escaping ([String]?, NusicError?) -> ()) {
        let dispatchGroup = DispatchGroup()
        var error: NusicError?
        var extractedGenres:[String]?
        for emotion in emotions {
            dispatchGroup.enter()
            reference.child("moodTracks").child(userName).child(emotion.basicGroup.rawValue.lowercased()).observeSingleEvent(of: .value, with: { (dataSnapshot) in
                let value = dataSnapshot.value as? [String: AnyObject];
                var iterator = value?.makeIterator();
                var element = iterator?.next()
                extractedGenres = [String]()
                
                while element != nil {
                    if let element = element {
                        extractedGenres?.append(element.key)
                    }
                    element = iterator?.next();
                }
                dispatchGroup.leave()
                
            }, withCancel: { (cancelError) in
                error = NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.getTrackListForEmotion.rawValue, systemError: cancelError)
                dispatchGroup.leave()
            })
        }
        
        dispatchGroup.notify(queue: .main, execute: {
            getAssociatedTrackHandler(extractedGenres, error)
        })
        
    }
    
    final func getDefaultTrackFeatures(getDefaultTrackFeaturesHandler: @escaping ([SpotifyTrackFeature]?, NusicError?) -> ()) {
        for emotion in emotions {
            reference.child("emotions").child(emotion.basicGroup.rawValue.lowercased()).observeSingleEvent(of: .value, with: { (dataSnapshot) in
                guard let value = dataSnapshot.value as? [String: AnyObject] else { return; }
                var extractedTrackFeatures:[SpotifyTrackFeature] = Array()
                extractedTrackFeatures.append(SpotifyTrackFeature(featureDictionary: value));
                getDefaultTrackFeaturesHandler(extractedTrackFeatures, nil);
            }, withCancel: { (error) in
                getDefaultTrackFeaturesHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.getTrackFeatures.rawValue, systemError: error));
            })
        }
    }
    
    final func getTrackFeaturesForEmotionGenre(getTrackFeaturesHandler: @escaping ([SpotifyTrackFeature]?, NusicError?) -> ()) {
        let dispatchGroup = DispatchGroup()
        var extractedTrackFeatures: [SpotifyTrackFeature]?
        var error: NusicError?
        for emotion in emotions {
            dispatchGroup.enter()
            reference.child("likedTracks").child("moods").child(userName).child(emotion.basicGroup.rawValue.lowercased()).observeSingleEvent(of: .value, with: { (dataSnapshot) in
                extractedTrackFeatures = [SpotifyTrackFeature]()
                guard let value = dataSnapshot.value as? [String: AnyObject] else { dispatchGroup.leave(); return; }
                
                var iterator = value.makeIterator();
                var element = iterator.next()
                while element != nil {
                    if let element = element, let dict = element.value as? [String: AnyObject] {
                        extractedTrackFeatures?.append(SpotifyTrackFeature(featureDictionary: dict));
                    }
                    element = iterator.next();
                }
                dispatchGroup.leave()
            }, withCancel: { (cancelError) in
                error = NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.getTrackFeatures.rawValue, systemError: cancelError)
                dispatchGroup.leave()
            })
        }
        
        dispatchGroup.notify(queue: .main) {
            getTrackFeaturesHandler(extractedTrackFeatures, error)
        }
        
    }
    
    final func getTrackIdAndFeaturesForEmotion(trackIdAndFeaturesHandler: @escaping ([String]?, [SpotifyTrackFeature]?, NusicError?) -> ()) {
        getTrackIdListForEmotionGenre { (genres, error) in
            guard let genres = genres, genres.count > 0 else { trackIdAndFeaturesHandler(nil, nil, error); return; }
            self.getTrackFeaturesForEmotionGenre(getTrackFeaturesHandler: { (trackFeatures, error) in
                guard let trackFeatures = trackFeatures else { trackIdAndFeaturesHandler(genres, nil, error); return; }
                trackIdAndFeaturesHandler(genres, trackFeatures, error);
            })
        }
    }
    
}

