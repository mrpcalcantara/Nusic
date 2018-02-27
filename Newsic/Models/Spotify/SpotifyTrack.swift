//
//  SpotifyTrack.swift
//  Nusic
//
//  Created by Miguel Alcantara on 29/08/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation
import UIKit

class SpotifyTrack: Hashable {
    var hashValue: Int {
        return trackId.hashValue
    }
    
    var title: String!;
    var thumbNail: UIImage?;
    var thumbNailUrl: String!;
    var smallThumbNailUrl: String!;
    var trackId: String!;
    var linkedFromTrackId: String!;
    var trackUri: String!;
    var songName: String!;
    var songHref: String!;
    var artist: SpotifyArtist;
    var addedAt: Date?!
    var audioFeatures: SpotifyTrackFeature? = nil
    var suggestedSong: Bool? = false
    
    init(title: String? = "", thumbNail: UIImage? = nil, thumbNailUrl: String? = "", smallThumbNailUrl: String? = "", trackUri: String? = "", trackId: String, linkedFromTrackId: String? = "", songName: String? = "", songHref: String? = "", artist: SpotifyArtist?, addedAt: Date? = Date(), audioFeatures: SpotifyTrackFeature?, suggestedSong: Bool? = false) {
        self.title = title;
        self.thumbNailUrl = thumbNailUrl;
        self.smallThumbNailUrl = smallThumbNailUrl
        self.trackUri = trackUri;
        self.trackId = trackId;
        self.linkedFromTrackId = linkedFromTrackId
        self.songName = songName;
        self.songHref = songHref
        self.artist = artist!
        self.addedAt = addedAt;
        self.audioFeatures = audioFeatures
        self.suggestedSong = suggestedSong
        
        let image = UIImage()
        if let thumbNail = thumbNail {
            self.thumbNail = thumbNail
        } else {
            if let thumbNailUrl = thumbNailUrl {
                if let url = URL(string: thumbNailUrl) {
                    image.downloadImage(from: url) { (image) in
                        self.thumbNail = image;
                    }
                }
            }
        }
    }
    
    convenience init() {
        self.init(trackId: "", artist: SpotifyArtist(), audioFeatures: nil)
    }
    
    static func ==(lhs: SpotifyTrack, rhs: SpotifyTrack) -> Bool {
        return lhs.title == rhs.title &&
            lhs.thumbNail == rhs.thumbNail &&
            lhs.thumbNailUrl == rhs.thumbNailUrl &&
            lhs.trackId == rhs.trackId &&
            lhs.trackUri == rhs.trackUri &&
            lhs.songName == rhs.songName &&
            lhs.songHref == rhs.songHref &&
            lhs.artist == rhs.artist &&
            lhs.addedAt == rhs.addedAt &&
            lhs.audioFeatures == rhs.audioFeatures &&
            lhs.suggestedSong == rhs.suggestedSong
    }
    
    func setImage() {
        let image = UIImage()
        image.downloadImage(from: URL(string: thumbNailUrl)!) { (image) in
            self.thumbNail = image;
        }
    }

}
