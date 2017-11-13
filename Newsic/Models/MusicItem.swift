//
//  MusicItem.swift
//  Newsic
//
//  Created by Miguel Alcantara on 28/08/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation

struct MusicItem {
    
    var song: String;
    var artist: String;
    var genre: String;
    var youtubeId: String;
    var spotifyId: String
    
    init(song: String, artist: String, genre: String, youtubeId: String? = nil, spotifyId: String? = nil) {
        self.song = song;
        self.artist = artist;
        self.genre = genre;
        self.youtubeId = youtubeId != nil ? youtubeId! : "";
        self.spotifyId = spotifyId != nil ? spotifyId! : "";
    }
}
