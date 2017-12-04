//
//  SpotifyBrowse.swift
//  Newsic
//
//  Created by Miguel Alcantara on 09/10/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

extension Spotify {
    
    func retry(retryNumberLeft: Int, retryAfter: Int? = 2, taskRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?, Bool) -> ()) {
        var retryNumber = retryNumberLeft
        let session = URLSession.shared;
        session.dataTask(with: taskRequest) { (data, response, error) in
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            if (200...299).contains(statusCode) {
                completionHandler(data, response, error, true)
            }
            else {
//            else if (400...499).contains(statusCode) || (500...599).contains(statusCode) {
            
                if var retryAfter = retryAfter {
                    if statusCode == HTTPErrorCodes.tooManyRequests.rawValue {
                        retryAfter = Int(httpResponse.allHeaderFields["retry-after"] as! String)!;
                        retryNumber += 1;
                    }
                    if retryNumber > 0 {
                        let timeToWait = DispatchTime.now()+Double(retryAfter)
                        DispatchQueue.main.asyncAfter(deadline: timeToWait, execute: {
                            self.retry(retryNumberLeft: retryNumber-1, retryAfter: retryAfter, taskRequest: taskRequest, completionHandler: { (data, response, error, false) in
                                
                            })
                        })
                    } else {
                        completionHandler(data, response, error, false);
                    }
                }
            }
            
        }
    }
    
    func searchMusicInGenres(numberOfSongs: Int, moodObject: NewsicMood?, preferredTrackFeatures: [SpotifyTrackFeature]? = nil, selectedGenreList: [String: Int]? = nil, completionHandler: @escaping ([SpotifyTrack], NewsicError?) -> ()) {
        
        let auth = SPTAuth.defaultInstance()
        //Get Genres
        let hasList = moodObject?.associatedGenres != nil ? true : false;
        let genres = getGenreListString(numberOfSongs: numberOfSongs, hasList: hasList, selectedGenreList: selectedGenreList);
        
        //Get Emotions
        var urlString = "https://api.spotify.com/v1/recommendations?seed_genres=\(genres)&limit=\(numberOfSongs)"
        //&min_popularity=\(popularity)
        
        if let preferredTrackFeatures = preferredTrackFeatures {
            if preferredTrackFeatures.count > 0 {
                let averageFeatures = getAverageTrackFeatures(preferredTrackFeatures: preferredTrackFeatures)
                let averageFeaturesString = trackFeaturesToString(features: averageFeatures)
                urlString = "\(urlString)\(averageFeaturesString)"
            }
        }
        
        //Create URL Request to get sogs
        let url = URL(string: urlString);
        var request = URLRequest(url: url!)
        let accessToken = (auth?.session.accessToken)!
        var spotifyResults:[SpotifyTrack] = [];
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization");
        let session = URLSession.shared;
        
        session.executeCall(with: request) { (data, httpResponse, error, isSuccess) in
            let statusCode:Int! = httpResponse?.statusCode
            if isSuccess {
                let jsonObject = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
                let trackList = jsonObject["tracks"] as! [[String: AnyObject]]
                for track in trackList {
                    let trackName = track["name"] as! String;
                    let uri = track["uri"] as! String;
                    let id = track["id"] as! String;
                    let album = track["album"] as! [String: AnyObject]; let images = album["images"] as! [[String: AnyObject]]; let hqImage = images[0]["url"] as! String
                    let artists = track["artists"] as! [[String: AnyObject]]; let artistName = artists[0]["name"] as! String; let artistUri = artists[0]["uri"] as! String
                    let title = "\(artistName) - \(trackName)"
                    
                    let spotifyObject = SpotifyTrack(title: title, thumbNailUrl: hqImage, trackUri: uri, trackId: id, songName: trackName, artist: SpotifyArtist(artistName: artistName, uri: artistUri), audioFeatures: nil);
                    spotifyResults.append(spotifyObject);
                    
                }
                var artistUriList: [String] = []
                for result in spotifyResults {
                    artistUriList.append(result.artist.uri!);
                }
                self.getAllGenresForArtists(artistUriList, offset: 0, artistGenresHandler: { (artistList, error) in
                    if let artistList = artistList {
                        for artist in artistList {
                            if let artistIndex = spotifyResults.index(where: { (track) -> Bool in
                                return track.artist.uri == artist.uri
                            }) {
                                spotifyResults[artistIndex].artist = artist;
                            }
                        }
                    }
                    
                    completionHandler(spotifyResults, nil)
                })
            } else {
                switch statusCode {
                //                case (300...199):
                case (400...499):
                    completionHandler([], NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.clientError))
                case (500...599):
                    completionHandler([], NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.serverError))
                default:
                    return;
                }
            }
            
        }
        session.dataTask(with: request) { (data, response, error) in
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            
            }.resume()
        
        
    }
}
