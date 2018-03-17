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
    
    var audioFeatures: SpotifyTrackFeature? = nil
    var artist: [SpotifyArtist];
    var thumbNail: UIImage?;
    var thumbNailUrl: String!;
    var smallThumbNailUrl: String!;
    var trackId: String!;
    var linkedFromTrackId: String!;
    var trackUri: String!;
    var songName: String!;
    var songHref: String!;
    var addedAt: Date?!
    var suggestedSong: Bool? = false
    
    init(thumbNail: UIImage? = nil, thumbNailUrl: String? = "", smallThumbNailUrl: String? = "", trackUri: String? = "", trackId: String, linkedFromTrackId: String? = "", songName: String? = "", songHref: String? = "", artist: [SpotifyArtist]?, addedAt: Date? = Date(), audioFeatures: SpotifyTrackFeature?, suggestedSong: Bool? = false) {
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
                guard let url = URL(string: thumbNailUrl) else { return}
                image.downloadImage(from: url) { (image) in
                    self.thumbNail = image;
                }
            }
        }
    }
    
    convenience init() {
        self.init(trackId: "", artist: [SpotifyArtist](), audioFeatures: nil)
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: TrackCodingKeys.self)
        songName = try container.decode(String.self, forKey: .songName)
        trackId = try container.decode(String.self, forKey: .trackId)
        trackUri = try container.decode(String.self, forKey: .trackUri)
        if let date = try container.decodeIfPresent(String.self, forKey: .addedAt) {
            let dateFormatter = DateFormatter();
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            let dateAdded = dateFormatter.date(from: date)
            addedAt = dateAdded
        }
        
        //artist
        var artists = try container.nestedUnkeyedContainer(forKey: .artists)
        artist = [SpotifyArtist]()
        while !artists.isAtEnd {
            let artist = try! artists.decode(SpotifyArtist.self)
            self.artist.append(artist)
        }
        let album = try container.nestedContainer(keyedBy: AlbumKeys.self, forKey: .album)
        var images = try album.nestedUnkeyedContainer(forKey: .images)
        var imageArray = [String]()
        let href = try container.nestedContainer(keyedBy: ExternalHrefKey.self, forKey: .external_urls)
        if let songHref = try href.decodeIfPresent(String.self, forKey: .songHref) {
            self.songHref = songHref
        }

        if let linkedFrom = try? container.nestedContainer(keyedBy: LinkedFromCodingKey.self, forKey: .linked_from), let linkedFromTrackId = try linkedFrom.decodeIfPresent(String.self, forKey: .linkedFromTrackId) {
            self.linkedFromTrackId = linkedFromTrackId
        }
        else {
            self.linkedFromTrackId = trackId
        }
        
        while !images.isAtEnd {
            let image = try images.nestedContainer(keyedBy: ImageKeys.self)
            imageArray.append(try image.decode(String.self, forKey: .url))
        }
        if imageArray.count > 1 {
            thumbNailUrl = imageArray[1];
            if let url = URL(string: thumbNailUrl) {
                UIImage().downloadImage(from: url) { (image) in
                    self.thumbNail = image;
                }
            }
        }
    }
    
    static func ==(lhs: SpotifyTrack, rhs: SpotifyTrack) -> Bool {
        return
            lhs.thumbNail == rhs.thumbNail &&
            lhs.thumbNailUrl == rhs.thumbNailUrl &&
            lhs.trackId == rhs.trackId &&
            lhs.trackUri == rhs.trackUri &&
            lhs.songName == rhs.songName &&
            lhs.songHref == rhs.songHref &&
            lhs.artist == rhs.artist &&
            lhs.audioFeatures == rhs.audioFeatures &&
            lhs.suggestedSong == rhs.suggestedSong
    }
    
    private func setImage() {
        let image = UIImage()
        image.downloadImage(from: URL(string: thumbNailUrl)!) { (image) in
            self.thumbNail = image;
        }
    }
    
}

extension SpotifyTrack: Decodable {
    enum TrackCodingKeys: String, CodingKey {
        case trackUri = "uri"
        case trackId = "id"
        case songName = "name"
        case addedAt = "added_at"
        case artists
        case album
        case external_urls
        case linked_from
    }
    
    enum AlbumKeys: String, CodingKey {
        case images
    }
    
    enum ImageKeys: CodingKey {
        case height
        case width
        case url
    }
    
    enum ThumbnailCodingKeys: String, CodingKey {
        case thumbNailUrl = "url"
    }
    
    enum ExternalHrefKey: String, CodingKey {
        case songHref = "spotify"
    }
    
    enum LinkedFromCodingKey: String, CodingKey {
        case linkedFromTrackId = "id"
    }
}

