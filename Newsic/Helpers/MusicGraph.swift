//
//  MusicGraph.swift
//  Newsic
//
//  Created by Miguel Alcantara on 28/08/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation

final class MusicGraph {
    
    static var apiKey = "68af79aed14df2848845258c649e8375"
    /*
    static func getRandomSong(for genre: String, _ completionHandler: @escaping (MusicGraphItem) -> ()){
        let range: Range<Int> = 1..<1000;
        let randomOffset = Int.random(range: range);
        let encodedGenre = genre.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlString = "http://api.musicgraph.com/api/v2/track/search?api_key=\(apiKey)&genre=\(encodedGenre)&limit=1&offset=\(randomOffset)"
        print("URL called: \(urlString)");
        let url = URL(string: urlString);
        
        guard let msUrl = url else { return; }
        
        let session = URLSession.shared;
        let task = session.dataTask(with: msUrl) { (data, _, error) in
            guard let data = data else { return; }
            
            if error != nil {
                return;
            }
            
            do {
                
                print(data.description);
                
                //let jsonResponse = try JSONSerialization.jsonObject(with: data, options: .allowFragments);
                let jsonResponse = try JSONSerialization.jsonObject(with: data);
                
                //print("JSON = \(jsonResponse)")
                let rootObject = jsonResponse as! [String: AnyObject]
                //print("Root Object = \(rootObject)");
                
                let musicData = rootObject["data"] as? [[String: AnyObject]];
                var musicItem: MusicGraphItem? = nil;
                if musicData != nil && (musicData?.count)! > 0 {
                    for music in musicData! {
                        if let artist = music["artist_name"],
                            let song = music["title"]
                            //let genre = music["main_genre"]
                        {
                            musicItem = MusicGraphItem(song: song as! String, artist: artist as! String, genre: genre as! String ?? "")
                            break;
                        }
                        
                    }    
                }
                
                
                completionHandler(musicItem!);
                
            } catch { print("ERROR PARSING") }
            
        }
        
        task.resume();
        
    }
    */
}
