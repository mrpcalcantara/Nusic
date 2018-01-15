//
//  MoodHackerResult.swift
//  Nusic
//
//  Created by Miguel Alcantara on 01/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct NusicMood: FirebaseModel, Iterable {
    
    var emotions: [Emotion];
    var sentiment: Double;
    var isAmbiguous: Bool;
    var userName: String;
    var date: Date!
    var associatedGenres: [String];
    var associatedTracks: [NusicTrack];
    var reference: DatabaseReference!
    
    init() {
        self.emotions = []
        self.isAmbiguous = false;
        self.sentiment = 0.5
        self.date = Date();
        self.userName = ""
        self.associatedGenres = []
        self.associatedTracks = []
        self.reference = Database.database().reference();
    }
    
    init(emotions: [Emotion], isAmbiguous: Bool, sentiment: Double, date: Date, userName: String? = "", associatedGenres: [String], associatedTracks: [NusicTrack]) {
        self.emotions = emotions;
        self.isAmbiguous = isAmbiguous;
        self.sentiment = sentiment;
        self.date = date;
        self.userName = userName!
        self.associatedGenres = associatedGenres
        self.associatedTracks = associatedTracks
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
                if let error = error {
                    saveCompleteHandler(reference, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.saveMoodInfo.rawValue, systemError: error))
                } else {
                    saveCompleteHandler(reference, nil)
                }
                
            }
        }

    }
    
    internal func deleteData(deleteCompleteHandler: @escaping (DatabaseReference?, NusicError?) -> ()) {
        reference.child("emotions").child(userName).removeValue { (error, databaseReference) in
            if let error = error {
                deleteCompleteHandler(self.reference, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.deleteMoodInfo.rawValue, systemError: error))
            } else {
                deleteCompleteHandler(self.reference, nil)
            }
            
        }
    }
    
    func getTrackListForEmotionGenre(getAssociatedTrackHandler: @escaping ([String: SpotifyTrackFeature]?, NusicError?) -> ()) {
        let count = emotions.count;
        var index = 0;
        for emotion in emotions {
            reference.child("likedTracks").child(userName).child("moods").child(emotion.basicGroup.rawValue.lowercased()).observeSingleEvent(of: .value, with: { (dataSnapshot) in
                let value = dataSnapshot.value as? [String: AnyObject];
                var iterator = value?.makeIterator();
                
                let element = iterator?.next()
                var extractedGenres:[String:SpotifyTrackFeature] = [:]
                
                while element != nil {
                    if let element = element {
                        let key = element.key
                        var value = SpotifyTrackFeature();
                        value.mapDictionary(featureDictionary: (element.value as? [String: AnyObject])!)
                        extractedGenres[key] = value;
                        //extractedGenres.append([element.key: element.value])
                    }
                }
                
                index += 1;
                if index == count {
                    getAssociatedTrackHandler(extractedGenres, nil);
                }
                
            }, withCancel: { (error) in
                getAssociatedTrackHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.getTrackListForEmotion.rawValue, systemError: error));
            })
        }
        
    }
    
    func getTrackIdListForEmotionGenre(getAssociatedTrackHandler: @escaping ([String]?, NusicError?) -> ()) {
        let count = emotions.count;
        var index = 0;
        for emotion in emotions {
            reference.child("likedTracks").child(userName).child("moods").child(emotion.basicGroup.rawValue.lowercased()).observeSingleEvent(of: .value, with: { (dataSnapshot) in
                let value = dataSnapshot.value as? [String: AnyObject];
                var iterator = value?.makeIterator();
                
                var element = iterator?.next()
                var extractedGenres:[String] = []
                
                while element != nil {
                    if let element = element {
                        extractedGenres.append(element.key)
                    }
                    element = iterator?.next();
                }
                
                index += 1;
                if index == count {
                    getAssociatedTrackHandler(extractedGenres, nil);
                }
                
            }, withCancel: { (error) in
                getAssociatedTrackHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.getTrackListForEmotion.rawValue, systemError: error));
            })
        }
        //getAssociatedTrackHandler(nil)
    }
    
    func getDefaultTrackFeatures(getDefaultTrackFeaturesHandler: @escaping ([SpotifyTrackFeature]?, NusicError?) -> ()) {
        for emotion in emotions {
            reference.child("emotions").child(emotion.basicGroup.rawValue.lowercased()).observeSingleEvent(of: .value, with: { (dataSnapshot) in
                let value = dataSnapshot.value as? [String: AnyObject];
                var extractedTrackFeatures:[SpotifyTrackFeature] = []
                var feature = SpotifyTrackFeature();
                if value != nil {
                    feature.mapDictionary(featureDictionary: value!);
                }
                extractedTrackFeatures.append(feature);
                getDefaultTrackFeaturesHandler(extractedTrackFeatures, nil);
            }, withCancel: { (error) in
                getDefaultTrackFeaturesHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.getTrackFeatures.rawValue, systemError: error));
            })
        }
    }
    
    func getTrackFeaturesForEmotionGenre(getTrackFeaturesHandler: @escaping ([SpotifyTrackFeature]?, NusicError?) -> ()) {
        let count = emotions.count;
        var index = 0;
        for emotion in emotions {
            reference.child("likedTracks").child(userName).child("moods").child(emotion.basicGroup.rawValue.lowercased()).observeSingleEvent(of: .value, with: { (dataSnapshot) in
                let value = dataSnapshot.value as? [String: AnyObject];
                var iterator = value?.makeIterator();
                
                var element = iterator?.next()
                var extractedTrackFeatures:[SpotifyTrackFeature] = []
                
                while element != nil {
                    if let element = element {
                        var value = SpotifyTrackFeature();
                        value.mapDictionary(featureDictionary: (element.value as? [String: AnyObject])!)
                        extractedTrackFeatures.append(value);
                        //extractedGenres.append([element.key: element.value])
                    }
                    element = iterator?.next();
                }
                
                index += 1;
                if index == count {
                    getTrackFeaturesHandler(extractedTrackFeatures, nil);
                }
                
            }, withCancel: { (error) in
                getTrackFeaturesHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.getTrackFeatures.rawValue, systemError: error));
            })
        }
        
    }
    
    func getTrackIdAndFeaturesForEmotion(trackIdAndFeaturesHandler: @escaping ([String]?, [SpotifyTrackFeature]?, NusicError?) -> ()) {
        getTrackIdListForEmotionGenre { (genres, error) in
            if genres != nil && genres!.count > 0 {
                self.getTrackFeaturesForEmotionGenre(getTrackFeaturesHandler: { (trackFeatures, error) in
                    if let trackFeatures = trackFeatures {
                        trackIdAndFeaturesHandler(genres!, trackFeatures, error);
                    } else {
                        trackIdAndFeaturesHandler(genres!, nil, error);
                    }
                })
            } else {
                trackIdAndFeaturesHandler(nil, nil, error);
            }
        }
    }
    
}

