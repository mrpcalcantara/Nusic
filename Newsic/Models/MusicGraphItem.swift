//
//  MusicGraphItem.swift
//  Newsic
//
//  Created by Miguel Alcantara on 31/08/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation

struct MusicGraphItem {
    
    var song: String;
    var artist: String;
    var genre: String;
    
    init(song: String, artist: String, genre: String) {
        self.song = song;
        self.artist = artist;
        self.genre = genre;
    }
}
