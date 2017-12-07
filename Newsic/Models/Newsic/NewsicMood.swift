//
//  MoodHackerResult.swift
//  Newsic
//
//  Created by Miguel Alcantara on 01/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct NewsicMood: FirebaseModel {
    
    var emotions: [Emotion];
    var sentiment: Double;
    var isAmbiguous: Bool;
    var userName: String;
    var date: Date!
    var associatedGenres: [String];
    var associatedTracks: [NewsicTrack];
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
    
    init(emotions: [Emotion], isAmbiguous: Bool, sentiment: Double, date: Date, userName: String? = "", associatedGenres: [String], associatedTracks: [NewsicTrack]) {
        self.emotions = emotions;
        self.isAmbiguous = isAmbiguous;
        self.sentiment = sentiment;
        self.date = date;
        self.userName = userName!
        self.associatedGenres = associatedGenres
        self.associatedTracks = associatedTracks
        self.reference = Database.database().reference();
    }
    
    internal func getData(getCompleteHandler: @escaping (NSDictionary?, Error?) -> ()) {
        reference.child("emotions").child(userName).observeSingleEvent(of: .value, with: { (dataSnapshot) in
            let value = dataSnapshot.value as? NSDictionary
            getCompleteHandler(value, nil);
        }) { (error) in
            getCompleteHandler(nil, error);
        }
        
        
    }
    
    internal func saveData(saveCompleteHandler: @escaping (DatabaseReference?, Error?) -> ()) {
        var emotionArray: [[String: AnyObject]] = [];
        for emotion in emotions {
            let firstEmotion = emotion.toDictionary()
            emotionArray.append(firstEmotion)
            reference.child("emotions").child(userName).child(emotion.basicGroup.rawValue.lowercased()).child(date.toString()).updateChildValues(emotion.toDictionary()) { (error, reference) in
                saveCompleteHandler(reference, error)
            }
        }

    }
    
    internal func deleteData(deleteCompleteHandler: @escaping (DatabaseReference?, Error?) -> ()) {
        reference.child("emotions").child(userName).removeValue { (error, databaseReference) in
            deleteCompleteHandler(self.reference, error)
        }
    }
    
    func getTrackListForEmotionGenre(getAssociatedTrackHandler: @escaping ([String: SpotifyTrackFeature]?) -> ()) {
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
                    getAssociatedTrackHandler(extractedGenres);
                }
                
            })
        }
        
    }
    
    
    func getTrackIdListForEmotionGenre(getAssociatedTrackHandler: @escaping ([String]?) -> ()) {
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
                    getAssociatedTrackHandler(extractedGenres);
                }
                
            })
        }
        //getAssociatedTrackHandler(nil)
    }
    
    func getDefaultTrackFeatures(getDefaultTrackFeaturesHandler: @escaping ([SpotifyTrackFeature]?) -> ()) {
        for emotion in emotions {
            reference.child("emotions").child(emotion.basicGroup.rawValue.lowercased()).observeSingleEvent(of: .value, with: { (dataSnapshot) in
                let value = dataSnapshot.value as? [String: AnyObject];
                var iterator = value?.makeIterator();
                
                var element = iterator?.next()
                var extractedTrackFeatures:[SpotifyTrackFeature] = []
                var feature = SpotifyTrackFeature();
                if value != nil {
                    feature.mapDictionary(featureDictionary: value!);
                }
                extractedTrackFeatures.append(feature);
                /*
                while element != nil {
                    if let element = element {
                        
                        extractedTrackFeatures.append(feature);
                        //extractedGenres.append([element.key: element.value])
                    }
                    element = iterator?.next();
                }
                 */
                getDefaultTrackFeaturesHandler(extractedTrackFeatures);
            })
        }
    }
    
    func getTrackFeaturesForEmotionGenre(getTrackFeaturesHandler: @escaping ([SpotifyTrackFeature]?) -> ()) {
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
                    getTrackFeaturesHandler(extractedTrackFeatures);
                }
                
            })
        }
        
    }
    
    func getTrackIdAndFeaturesForEmotion(trackIdAndFeaturesHandler: @escaping ([String]?, [SpotifyTrackFeature]?) -> ()) {
        getTrackIdListForEmotionGenre { (genres) in
            if genres != nil && genres!.count > 0 {
                self.getTrackFeaturesForEmotionGenre(getTrackFeaturesHandler: { (trackFeatures) in
                    if let trackFeatures = trackFeatures {
                        trackIdAndFeaturesHandler(genres!, trackFeatures);
                    } else {
                        trackIdAndFeaturesHandler(genres!, nil);
                    }
                })
            } else {
                trackIdAndFeaturesHandler(nil, nil);
            }
        }
    }
    /*
    func getEmotionDyad() -> EmotionDyad {
        let emotions = self.emotions.sorted { (em1, em2) -> Bool in
            em1.basicGroup.rawValue < em2.basicGroup.rawValue
        }
        
        if emotions.count == 2 {
            return getEmotionCombination(emotion1: emotions[0].basicGroup, emotion2: emotions[1].basicGroup);
        }
        return .none
        
    }
    
    func getEmotionCombination(emotion1: EmotionDyad, emotion2: EmotionDyad) -> EmotionDyad {
        switch emotion1 {
        case EmotionValue.anger.description():
            switch emotion2 {
            case EmotionValue.anticipation.description():
                return .aggressiveness
            case EmotionValue.disgust.description():
                return .contempt
            case EmotionValue.joy.description():
                return .pride
            case EmotionValue.sadness.description():
                return .envy
            case EmotionValue.surprise.description():
                return .outrage
            case EmotionValue.trust.description():
                return .dominance
            default:
                return .none
            }
        case EmotionValue.anticipation.description():
            switch emotion2 {
            case EmotionValue.disgust.description():
                return .cynicism
            case EmotionValue.joy.description():
                return .optimism
            case EmotionValue.sadness.description():
                return .pessimism
            case EmotionValue.trust.description():
                return .hope
            case EmotionValue.fear.description():
                return .anxiety
            default:
                return .none
            }
        case EmotionValue.disgust.description():
            switch emotion2 {
            case EmotionValue.joy.description():
                return .morbidness
            case EmotionValue.sadness.description():
                return .remorse
            case EmotionValue.surprise.description():
                return .unbelief
            case EmotionValue.fear.description():
                return .shame
            default:
                return .none
            }
        case EmotionValue.fear.description():
            switch emotion2 {
            case EmotionValue.joy.description():
                return .guilt
            case EmotionValue.sadness.description():
                return .despair
            case EmotionValue.surprise.description():
                return .awe
            case EmotionValue.trust.description():
                return .submission
            default:
                return .none
            }
        case EmotionValue.joy.description():
            switch emotion2 {
            case EmotionValue.surprise.description():
                return .love
            case EmotionValue.trust.description():
                return .delight
            default:
                return .none
            }
        case EmotionValue.sadness.description():
            switch emotion2 {
            case EmotionValue.surprise.description():
                return .disapproval
            case EmotionValue.trust.description():
                return .sentimentality
            default:
                return .none
            }
        case EmotionValue.surprise.description():
            switch emotion2 {
            case EmotionValue.sadness.description():
                return .curiosity
            default:
                return .none
            }
        case EmotionValue.trust.description():
            return .none
        default:
            return .none
        }
    }
    */
}

