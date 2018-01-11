//
//  SpotifyTrackFeature.swift
//  Nusic
//
//  Created by Miguel Alcantara on 06/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation

struct SpotifyTrackFeature: Hashable {
    var hashValue: Int {
        return (youtubeId?.hashValue)!
    }
    
    
    
    var danceability: Double? = 0;
    var energy: Double? = 0;
    var key: Int? = 0;
    var loudness: Double? = 0;
    var mode: Int? = 0;
    var speechiness: Double? = 0;
    var acousticness: Double? = 0;
    var instrumentalness: Double? = 0;
    var liveness: Double? = 0;
    var valence: Double? = 0;
    var tempo: Double? = 0;
    var type: String? = "";
    var id: String? = "";
    var uri: String? = "";
    var trackHref: String? = "";
    var analysisUrl: String? = "";
    var durationMs: Int? = 0;
    var timeSignature: Int? = 0;
    var genre: String? = ""
    var youtubeId: String? = ""
    
    init(acousticness: Double? = nil, analysisUrl: String? = nil, danceability: Double? = nil, durationMs: Int? = nil, energy: Double? = nil, id: String? = nil, instrumentalness: Double? = nil, key: Int? = nil, liveness: Double? = nil, loudness: Double? = nil, mode: Int? = nil, speechiness: Double? = nil, tempo: Double? = nil, timeSignature: Int? = nil, trackHref: String? = nil, type: String? = nil, uri: String? = nil, valence: Double? = nil, genre: String? = nil, youtubeId: String? = nil) {
        
        self.acousticness      = acousticness
        self.analysisUrl       = analysisUrl
        self.danceability      = danceability
        self.durationMs        = durationMs
        self.energy            = energy
        self.id                = id
        self.instrumentalness  = instrumentalness
        self.key               = key
        self.liveness          = liveness
        self.loudness          = loudness
        self.mode              = mode
        self.speechiness       = speechiness
        self.tempo             = tempo
        self.timeSignature     = timeSignature
        self.trackHref         = trackHref
        self.type              = type
        self.uri               = uri
        self.valence           = valence
        self.genre             = genre
        self.youtubeId         = youtubeId
    }
    
    static func ==(lhs: SpotifyTrackFeature, rhs: SpotifyTrackFeature) -> Bool {
        return
            lhs.danceability == rhs.danceability &&
                lhs.energy == rhs.energy &&
                lhs.key == rhs.key &&
                lhs.loudness == rhs.loudness &&
                lhs.mode == rhs.mode &&
                lhs.speechiness == rhs.speechiness &&
                lhs.acousticness == rhs.acousticness &&
                lhs.instrumentalness == rhs.instrumentalness &&
                lhs.liveness == rhs.liveness &&
                lhs.valence == rhs.valence &&
                lhs.tempo == rhs.tempo &&
                lhs.type == rhs.type &&
                lhs.id == rhs.id &&
                lhs.uri == rhs.uri &&
                lhs.trackHref == rhs.trackHref &&
                lhs.analysisUrl == rhs.analysisUrl &&
                lhs.durationMs == rhs.durationMs &&
                lhs.timeSignature == rhs.timeSignature &&
                lhs.genre == rhs.genre &&
                lhs.youtubeId == rhs.youtubeId
    }
    
    func toDictionary() -> [String: AnyObject] {
        var featureDictionary: [String: AnyObject] = [:]
        
        featureDictionary["acousticness"] = self.acousticness as AnyObject
        featureDictionary["analysis_url"] = self.analysisUrl as AnyObject
        featureDictionary["danceability"] = self.danceability as AnyObject
        featureDictionary["duration_ms"] = self.durationMs as AnyObject
        featureDictionary["energy"] = self.energy as AnyObject
        featureDictionary["id"] = self.id as AnyObject
        featureDictionary["instrumentalness"] = self.instrumentalness as AnyObject
        featureDictionary["key"] = self.key as AnyObject
        featureDictionary["liveness"] = self.liveness as AnyObject
        featureDictionary["loudness"] = self.loudness as AnyObject
        featureDictionary["mode"] = self.mode as AnyObject
        featureDictionary["speechiness"] = self.speechiness as AnyObject
        featureDictionary["tempo"] = self.tempo as AnyObject
        featureDictionary["time_signature"] = self.timeSignature as AnyObject
        featureDictionary["track_href"] = self.trackHref as AnyObject
        featureDictionary["type"] = self.type as AnyObject
        featureDictionary["uri"] = self.uri as AnyObject
        featureDictionary["valence"] = self.valence as AnyObject
        featureDictionary["genre"] = self.genre as AnyObject
        featureDictionary["youtubeId"] = self.youtubeId as AnyObject
        
        return featureDictionary;
    }
    
    mutating func mapDictionary(featureDictionary: [String: AnyObject]) {
        
        self.acousticness      = featureDictionary["acousticness"] as? Double
        self.analysisUrl       = featureDictionary["analysis_url"] as? String
        self.danceability      = featureDictionary["danceability"] as? Double
        self.durationMs        = featureDictionary["duration_ms"] as? Int
        self.energy            = featureDictionary["energy"] as? Double
        self.id                = featureDictionary["id"] as? String
        self.instrumentalness  = featureDictionary["instrumentalness"] as? Double
        self.key               = featureDictionary["key"] as? Int
        self.liveness          = featureDictionary["liveness"] as? Double
        self.loudness          = featureDictionary["loudness"] as? Double
        self.mode              = featureDictionary["mode"] as? Int
        self.speechiness       = featureDictionary["speechiness"] as? Double
        self.tempo             = featureDictionary["tempo"] as? Double
        self.timeSignature     = featureDictionary["time_signature"] as? Int
        self.trackHref         = featureDictionary["track_href"] as? String
        self.type              = featureDictionary["type"] as? String
        self.uri               = featureDictionary["uri"] as? String
        self.valence           = featureDictionary["valence"] as? Double
        self.genre             = featureDictionary["genre"] as? String
        self.youtubeId         = featureDictionary["youtubeId"] as? String
    }
    
    
}
