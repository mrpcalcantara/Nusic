//
//  SpotifyTrack.swift
//  Newsic
//
//  Created by Miguel Alcantara on 29/08/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation
import UIKit

class SpotifyTrack {
    
    var title: String!;
    var thumbNail: UIImage?;
    var thumbNailUrl: String!;
    var trackId: String!;
    var trackUri: String!;
    var songName: String!;
    var artist: SpotifyArtist!;
    var addedAt: Date?!
    var audioFeatures: SpotifyTrackFeature? = nil
    
    init(title: String? = "", thumbNail: UIImage? = nil, thumbNailUrl: String? = "", trackUri: String? = "", trackId: String, songName: String? = "", artist: SpotifyArtist?, addedAt: Date? = Date(), audioFeatures: SpotifyTrackFeature?) {
        self.title = title;
        let image = UIImage()
        image.downloadImage(from: URL(string: thumbNailUrl!)!) { (image) in
            self.thumbNail = image;
        }
        self.thumbNailUrl = thumbNailUrl;
        self.trackUri = trackUri;
        self.trackId = trackId;
        self.songName = songName;
        self.artist = artist
        self.addedAt = addedAt;
        self.audioFeatures = audioFeatures
    }
    
    func setImage() {
        let image = UIImage()
        image.downloadImage(from: URL(string: thumbNailUrl)!) { (image) in
            self.thumbNail = image;
        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
}
