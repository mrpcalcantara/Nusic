//
//  YouTubeSearch.swift
//  Nusic
//
//  Created by Miguel Alcantara on 29/08/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation
import youtube_ios_player_helper

final class YouTubeSearch {
    
    static let apiKey = ""
    
    static func getSongInfo(artist: String, songName: String, completionHandler: @escaping (YouTubeResult?) -> ()) {
        let query = "\(artist) \(songName)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&q=\(query)&type=video&maxResults=1&key=\(apiKey)"
        let url = URL(string: urlString);
        
        guard let ytUrl = url else { return; }
        
        let session = URLSession.shared;
        let task = session.dataTask(with: ytUrl) { (data, _, error) in
            guard let data = data else { return; }
            
            if error != nil {
                return;
            }
            
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data);
                let rootObject = jsonResponse as! [String: AnyObject]
                
                let youtubeData = rootObject["items"] as? [[String: AnyObject]];
                var youtubeItem: YouTubeResult? = nil;
                for item in youtubeData! {
                    let idObj = item["id"] as! [String: AnyObject]
                    let snippetObj = item["snippet"] as! [String: AnyObject];
                    let thumbnailObj = snippetObj["thumbnails"] as! [String: AnyObject];
                    let hqThumbnailObj = thumbnailObj["high"] as! [String: AnyObject];
                    
                    
                    
                    if let videoId = idObj["videoId"] as? String, let title = snippetObj["title"] as? String, let thumbNail = hqThumbnailObj["url"] as? String {
                        youtubeItem = YouTubeResult(title: title, thumbNailUrl: thumbNail, trackId: videoId, songName: songName, artist: artist);
                    }
                }
                
                completionHandler(youtubeItem);
                
            } catch { print("ERROR PARSING") }
            
        }
        
        task.resume();

    }
    
    
}
