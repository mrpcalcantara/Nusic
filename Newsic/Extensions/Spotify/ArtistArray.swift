//
//  ArtistArray.swift
//  Newsic
//
//  Created by Miguel Alcantara on 14/03/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import Foundation

extension Array where Element == SpotifyArtist {
 
    func getGenresForArtists() -> [String : Int] {
        var mainDict = [String:Int]()
        if self.count > 1 {
            print()
        }
        for artist in self {
            let dict = artist.listDictionary()
            let count: Int? = dict.count
            if let count = count, count > 0 {
                dict.forEach({ (key, value) in
                    var finalValue = value
                    if let mainKeyValue = mainDict[key] {
                        finalValue += mainKeyValue
                    }
                    mainDict.updateValue(finalValue, forKey: key)
                })
            }
        }
        
        return mainDict
    }
    
    func namesToString() -> String {
        var artistString = ""
        for artist in self {
            artistString += artist.artistName.capitalizingFirstLetter() + ", "
        }
        artistString.removeLast(2)
        return artistString
    }
    
    func listArtistsGenres(uppercase: Bool? = false) -> [String] {
        var allGenres = [String]()
        for artist in self {
            for artistGenre in artist.subGenres! {
                if !allGenres.contains(artistGenre) {
                    allGenres.append(artistGenre)
                }
            }
        }
        if uppercase! {
           return allGenres.map({ $0.capitalized })
        }
        return allGenres
    }
    
    func allArtistsGenresToString() -> String {
        return listArtistsGenres(uppercase: true).joined(separator: ", ");
    }
    
    mutating func updateArtist(artist: SpotifyArtist) {
        if let index = self.index(where: {$0.artistName == artist.artistName}) {
            self[index] = artist;
            return;
        }
    }
    
}

