//
//  SpotifyFollowedArtist.swift
//  Newsic
//
//  Created by Miguel Alcantara on 31/08/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation

struct SpotifyArtist {
    var artistName: String! = ""
    var subGenres: [String] = []
    var popularity: Int! = -1
    var uri: String! = ""
    var id: String! = ""
    
    init(artistName: String, subGenres: [String], popularity: Int, uri: String, id: String) {
        self.artistName = artistName;
        self.subGenres = subGenres;
        self.popularity = popularity;
        self.uri = uri;
        self.id = id;
    }
    
}
