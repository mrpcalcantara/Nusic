//
//  SpotifyTrackFeature.swift
//  Nusic
//
//  Created by Miguel Alcantara on 06/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation

class SpotifyTrackFeature: Hashable {
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
    var durationMs: Double? = 0;
    var timeSignature: Int? = 0;
//    var genre: String? = ""
    var youtubeId: String? = ""
    
    init(acousticness: Double? = nil, analysisUrl: String? = nil, danceability: Double? = nil, durationMs: Double? = nil, energy: Double? = nil, id: String? = nil, instrumentalness: Double? = nil, key: Int? = nil, liveness: Double? = nil, loudness: Double? = nil, mode: Int? = nil, speechiness: Double? = nil, tempo: Double? = nil, timeSignature: Int? = nil, trackHref: String? = nil, type: String? = nil, uri: String? = nil, valence: Double? = nil, youtubeId: String? = nil) {
        
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
        self.youtubeId         = youtubeId
    }
    
    convenience init(featureDictionary: [String: AnyObject]) {
        self.init()
        self.mapDictionary(featureDictionary: featureDictionary)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TrackFeatureKeys.self)
        
        acousticness      = try container.decodeIfPresent(Double.self, forKey: .acousticness)
        analysisUrl       = try container.decodeIfPresent(String.self, forKey: .analysisUrl)
        danceability      = try container.decodeIfPresent(Double.self, forKey: .danceability)
        durationMs        = try container.decodeIfPresent(Double.self, forKey: .durationMs)
        energy            = try container.decodeIfPresent(Double.self, forKey: .energy)
        id                = try container.decodeIfPresent(String.self, forKey: .id)
        instrumentalness  = try container.decodeIfPresent(Double.self, forKey: .instrumentalness)
        key               = try container.decodeIfPresent(Int.self, forKey: .key)
        liveness          = try container.decodeIfPresent(Double.self, forKey: .liveness)
        loudness          = try container.decodeIfPresent(Double.self, forKey: .loudness)
        mode              = try container.decodeIfPresent(Int.self, forKey: .mode)
        speechiness       = try container.decodeIfPresent(Double.self, forKey: .speechiness)
        tempo             = try container.decodeIfPresent(Double.self, forKey: .tempo)
        timeSignature     = try container.decodeIfPresent(Int.self, forKey: .timeSignature)
        trackHref         = try container.decodeIfPresent(String.self, forKey: .trackHref)
        type              = try container.decodeIfPresent(String.self, forKey: .type)
        uri               = try container.decodeIfPresent(String.self, forKey: .uri)
        valence           = try container.decodeIfPresent(Double.self, forKey: .valence)
        youtubeId         = ""
        
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
                lhs.youtubeId == rhs.youtubeId
    }
    
    final func toDictionary() -> [String: AnyObject] {
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
        featureDictionary["youtubeId"] = self.youtubeId as AnyObject
        
        return featureDictionary;
    }
    
    final func mapDictionary(featureDictionary: [String: AnyObject]) {
        
        self.acousticness      = featureDictionary["acousticness"] as? Double
        self.analysisUrl       = featureDictionary["analysis_url"] as? String
        self.danceability      = featureDictionary["danceability"] as? Double
        self.durationMs        = featureDictionary["duration_ms"] as? Double
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
        self.youtubeId         = featureDictionary["youtubeId"] as? String
    }
    
    
}

extension SpotifyTrackFeature: Decodable {
    enum TrackFeatureKeys: String, CodingKey {
        case acousticness
        case analysisUrl       = "analysis_url"
        case danceability
        case durationMs        = "duration_ms"
        case energy
        case id
        case instrumentalness
        case key
        case liveness
        case loudness
        case mode
        case speechiness
        case tempo
        case timeSignature     = "time_signature"
        case trackHref         = "track_href"
        case type
        case uri
        case valence
    }
}
