//
//  SpotifyBrowse.swift
//  Newsic
//
//  Created by Miguel Alcantara on 09/10/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

extension Spotify {
    
    func searchMusicInGenres(numberOfSongs: Int, moodObject: NewsicMood?, preferredTrackFeatures: [SpotifyTrackFeature]? = nil, selectedGenreList: [String: Int]? = nil, completionHandler: @escaping ([SpotifyTrack]) -> ()) {
        
        let auth = SPTAuth.defaultInstance()
        //Get Genres
        let hasList = moodObject?.associatedGenres != nil ? true : false;
        let genres = getGenreListString(numberOfSongs: numberOfSongs, hasList: hasList, selectedGenreList: selectedGenreList);
        
        //Get Emotions
        var emotionValues: [String: AnyObject] = [:];
        var urlString = "https://api.spotify.com/v1/recommendations?seed_genres=\(genres)&limit=\(numberOfSongs)"
        //&min_popularity=\(popularity)
        
        if let preferredTrackFeatures = preferredTrackFeatures {
            if preferredTrackFeatures.count > 0 {
                let averageFeatures = getAverageTrackFeatures(preferredTrackFeatures: preferredTrackFeatures)
                let averageFeaturesString = trackFeaturesToString(features: averageFeatures)
                urlString = "\(urlString)\(averageFeaturesString)"
            }
        }
        
        print("urlString for searching music = \(urlString)")
        
        //Create URL Request to get sogs
        let url = URL(string: urlString);
        var request = URLRequest(url: url!)
        let accessToken = (auth?.session.accessToken)!
        var spotifyResults:[SpotifyTrack] = [];
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization");
        let session = URLSession.shared;
        session.dataTask(with: request) { (data, response, error) in
            let httpResponse = response as! HTTPURLResponse
            if httpResponse.statusCode == ErrorCodes.tooManyRequests.rawValue {
                let retryTimer = Double(httpResponse.allHeaderFields["retry-after"] as! String);
                let dispatchTime = DispatchTime.now();
                
                DispatchQueue.main.asyncAfter(deadline: dispatchTime+retryTimer!, execute: {
                    self.searchMusicInGenres(numberOfSongs: numberOfSongs, moodObject: moodObject, preferredTrackFeatures: preferredTrackFeatures, completionHandler: { (tracks) in
                        
                    })
                })
            } else if httpResponse.statusCode == ErrorCodes.okResponse.rawValue {
                let jsonObject = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
                let trackList = jsonObject["tracks"] as! [[String: AnyObject]]
                for track in trackList {
                    let trackName = track["name"] as! String;
                    let uri = track["uri"] as! String;
                    let id = track["id"] as! String;
                    let album = track["album"] as! [String: AnyObject]; let images = album["images"] as! [[String: AnyObject]]; let hqImage = images[0]["url"] as! String
                    let artists = track["artists"] as! [[String: AnyObject]]; let artistName = artists[0]["name"] as! String
                    let title = "\(artistName) - \(trackName)"
                    
                    let spotifyObject = SpotifyTrack(title: title, thumbNailUrl: hqImage, trackUri: uri, trackId: id, songName: trackName, artist: artistName, audioFeatures: nil);
                    print(spotifyObject);
                    spotifyResults.append(spotifyObject);
                }
                
                completionHandler(spotifyResults)
            }
            
            
            }.resume()
        
        
    }
}
