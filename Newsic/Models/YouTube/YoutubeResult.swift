//
//  YouTubeResult.swift
//  Newsic
//
//  Created by Miguel Alcantara on 31/08/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//
import Foundation
import UIKit

struct YouTubeResult {
    
    let title: String!;
    let thumbNail: UIImage?;
    let thumbNailUrl: String!;
    let trackId: String!;
    let songName: String!;
    let artist: String!;
    
    init(title: String, thumbNail: UIImage? = nil, thumbNailUrl: String, trackId: String, songName: String, artist: String) {
        self.title = title;
        self.thumbNail = thumbNail;
        self.thumbNailUrl = thumbNailUrl;
        self.trackId = trackId;
        self.songName = songName;
        self.artist = artist
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
}
