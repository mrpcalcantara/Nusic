//
//  LastFMAPI.swift
//  Newsic
//
//  Created by Miguel Alcantara on 21/03/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import Foundation

final class LastFMAPI {
    
    static var apiKey = "3c3bcd01bdc52f57a53f26e4c97150a0"
    static var getArtistInfoURL = "https://ws.audioscrobbler.com/2.0/?method=artist.getinfo&artist="
    
    static func getArtistInfo(for artistName: String, completionHandler: @escaping (LastFM?, Error?) -> ()) {
        var urlString = "\(getArtistInfoURL)\(artistName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&api_key=3c3bcd01bdc52f57a53f26e4c97150a0&format=json"
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        URLSession.shared.executeCall(with: request) { (data, response, error, isSuccess) in
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
                guard isSuccess,
                    let artist = jsonObject["artist"] as? [String: AnyObject], let artistName = artist["name"] as? String,
                    let bioInfo = artist["bio"] as? [String: AnyObject], var bioContent = bioInfo["content"] as? String,
                    let imageInfo = artist["image"] as? [[String: AnyObject]], let imageIndex = imageInfo.index(where: { (image) -> Bool in
                        return image["size"] as! String == "mega"
                    })
                    else { completionHandler(nil, error); return }
                let imageUrl = imageInfo[imageIndex]["#text"] as! String
                
                if let index = bioContent.index(of: "<") {
                    bioContent = String(bioContent.prefix(upTo: index))
                }
                let lastFMObj = LastFM(name: artistName, bio: bioContent, imageUrl: imageUrl)
                completionHandler(lastFMObj, nil)
            } catch { completionHandler(nil, nil) }
        }
    }
}
