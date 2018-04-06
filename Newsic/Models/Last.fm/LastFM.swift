//
//  LastFM.swift
//  Newsic
//
//  Created by Miguel Alcantara on 21/03/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import Foundation

class LastFM: Decodable {
    
    var name: String = ""
    var bio: String = ""
    var imageUrl: String = ""
    var similarArtists: [String]? = [String]()
    
    init(name: String, bio: String, imageUrl: String, similarArtists: [String]? = nil) {
        self.name = name
        self.bio = bio
        self.imageUrl = imageUrl
        self.similarArtists = similarArtists
    }
    
    required init(decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: LastFMKeys.self)
            print("abc")
            let artistInfo = try container.nestedContainer(keyedBy: ArtistKeys.self, forKey: .artist)
            if let name = try artistInfo.decodeIfPresent(String.self, forKey: .name) { self.name = name }
            let bioInfo = try artistInfo.nestedContainer(keyedBy: BioKeys.self, forKey: .bio)
            if let bio = try bioInfo.decodeIfPresent(String.self, forKey: .bioContent) { self.bio = bio }
            var images = try artistInfo.nestedUnkeyedContainer(forKey: .image)
            while !images.isAtEnd {
                let image = try images.nestedContainer(keyedBy: ImageKeys.self)
                if let size = try image.decodeIfPresent(String.self, forKey: .size), size == "mega" {
                    if let imageUrl = try image.decodeIfPresent(String.self, forKey: .text) { self.imageUrl = imageUrl }
                    break
                }
            }
        } catch { }
        
    }
    
    enum LastFMKeys: String, CodingKey {
        case artist
    }
    
    enum ArtistKeys: String, CodingKey {
        case name = "\name"
        case bio
        case image
    }
    
    enum ImageKeys: String, CodingKey {
        case size
        case text = "#text"
    }
    
    enum BioKeys: String, CodingKey {
        case bioContent = "content"
    }
    
    //Functions
    func listSimilarArtists() -> String {
        var artists = ""
        guard let similarArtists = similarArtists else { return "" }
        similarArtists.forEach { (artist) in
            artists.append("\(artist), ")
        }
        artists.removeLast(2)
        if let range = artists.range(of: ",", options: .backwards) {
            artists = artists.replacingCharacters(in: range, with: " and")
        }
        
        return artists
    }
    
}
