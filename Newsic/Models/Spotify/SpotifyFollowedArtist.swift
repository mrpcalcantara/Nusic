//
//  SpotifyFollowedArtist.swift
//  Newsic
//
//  Created by Miguel Alcantara on 31/08/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation

struct SpotifyArtist: Hashable {
    var hashValue: Int {
        return (uri?.hashValue)!
    }
    
    var artistName: String! = ""
    var subGenres: [String]? = []
    var popularity: Int? = -1
    var uri: String? = ""
    var id: String? = ""
    
    init(artistName: String? = nil, subGenres: [String]? = nil, popularity: Int? = nil, uri: String? = nil, id: String? = nil) {
        self.artistName = artistName;
        self.subGenres = subGenres;
        self.popularity = popularity;
        self.uri = uri;
        self.id = id;
    }
    
    static func ==(lhs: SpotifyArtist, rhs: SpotifyArtist) -> Bool {
        return lhs.artistName == rhs.artistName &&
            lhs.subGenres! == rhs.subGenres! &&
            lhs.popularity == rhs.popularity &&
            lhs.uri == rhs.uri &&
            lhs.id == rhs.id
    }
    
    func listGenres(showPrefix: Bool? = true) -> String {
        if let subGenres = subGenres {
            var genreList = ""
            for var genre in subGenres {
                genreList.append("\(genre.capitalizingFirstLetter()), ")
            }
            
            if showPrefix! {
                return "Genres: \(String(genreList.dropLast(2)))";
            }
            return String(genreList.dropLast(2));
        }
        return ""
    }
    
    func listDictionary() -> [String: Int] {
        var dict: [String: Int] = [:]
        let genres = listGenres(showPrefix: false).split(separator: ",")
        for genre in genres {
            dict[genre.lowercased()] = 1
        }
        
        return dict
    }
    
}
