//
//  SpotifyFollowedArtist.swift
//  Nusic
//
//  Created by Miguel Alcantara on 31/08/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation

class SpotifyArtist: Hashable {
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
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ArtistKeys.self)
        artistName = try container.decode(String.self, forKey: .artistName)
        uri = try container.decode(String.self, forKey: .uri)
        id = try container.decode(String.self, forKey: .id)
        popularity = try container.decodeIfPresent(Int.self, forKey: .popularity)
        
        do {
            var genres = try container.nestedUnkeyedContainer(forKey: .subGenres)
            var genreList = [String]()
            while !genres.isAtEnd {
                if let genre = try genres.decodeIfPresent(String.self) {
                    genreList.append(genre)
                }
            }
            
            subGenres = Spotify.filterSpotifyGenres(genres: genreList)
        } catch {}
        
    }
    
    static func ==(lhs: SpotifyArtist, rhs: SpotifyArtist) -> Bool {
        var isEqual = lhs.artistName == rhs.artistName &&
            lhs.popularity == rhs.popularity &&
            lhs.uri == rhs.uri &&
            lhs.id == rhs.id
        
        if let lhsSubgenres = lhs.subGenres, let rhsSubgenres = rhs.subGenres {
            isEqual = isEqual && lhsSubgenres == rhsSubgenres
        }
        return isEqual
    }
    
    final func listGenres(showPrefix: Bool? = true) -> String {
        if let subGenres = subGenres {
            var genreList = ""
            for genre in subGenres {
                genreList.append("\(genre.capitalizingFirstLetter()), ")
            }
            
            if showPrefix! {
                return "Genres: \(String(genreList.dropLast(2)))";
            }
            return String(genreList.dropLast(2));
        }
        return ""
    }
    
    final func listDictionary() -> [String: Int] {
        var dict: [String: Int] = [:]
        let genres = listGenres(showPrefix: false).split(separator: ",")
        for genre in genres {
            dict[genre.lowercased()] = 1
        }
        
        return dict
    }
    
}

extension SpotifyArtist: Decodable {
    
    enum ArtistKeys: String, CodingKey {
        case id
        case uri
        case artistName = "name"
        case popularity
        case subGenres = "genres"
    }
    
}
