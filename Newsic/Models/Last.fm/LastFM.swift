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
    
    init(name: String, bio: String, imageUrl: String) {
        self.name = name
        self.bio = bio
        self.imageUrl = imageUrl
    }
    
    required init(decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: LastFMKeys.self)
            print("abc")
            let artistInfo = try container.nestedContainer(keyedBy: ArtistKeys.self, forKey: .artist)
            if let name = try artistInfo.decodeIfPresent(String.self, forKey: .name) { self.name = name }
            let bioInfo = try artistInfo.nestedContainer(keyedBy: BioKeys.self, forKey: .bio)
            if let bio = try bioInfo.decodeIfPresent(String.self, forKey: .bioContent) { self.bio = bio }
//            var images = try artistInfo.nestedUnkeyedContainer(forKey: .image)
//            while !images.isAtEnd {
//                let image = try images.nestedContainer(keyedBy: ImageKeys.self)
//                if let size = try image.decodeIfPresent(String.self, forKey: .size), size == "large" {
//                    if let imageUrl = try image.decodeIfPresent(String.self, forKey: .text) { self.imageUrl = imageUrl }
//                    break
//                }
//            }
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
    
}
