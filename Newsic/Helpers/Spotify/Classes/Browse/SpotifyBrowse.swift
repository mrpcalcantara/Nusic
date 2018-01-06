//
//  SpotifyBrowse.swift
//  Newsic
//
//  Created by Miguel Alcantara on 09/10/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

extension Spotify {
    
    func searchMusicInGenres(numberOfSongs: Int, moodObject: NewsicMood?, preferredTrackFeatures: [SpotifyTrackFeature]? = nil, selectedGenreList: [String: Int]? = nil, completionHandler: @escaping ([SpotifyTrack], NewsicError?) -> ()) {
        
        //Get Genres
        let hasList = moodObject?.associatedGenres != nil ? true : false;
        let genres = getGenreListString(numberOfSongs: numberOfSongs, hasList: hasList, selectedGenreList: selectedGenreList);
        
        //Get Emotions
        var urlString = "https://api.spotify.com/v1/recommendations?seed_genres=\(genres)&limit=\(numberOfSongs)"
        
        if let preferredTrackFeatures = preferredTrackFeatures {
            if preferredTrackFeatures.count > 0 {
                let averageFeatures = getAverageTrackFeatures(preferredTrackFeatures: preferredTrackFeatures)
                let averageFeaturesString = trackFeaturesToString(features: averageFeatures)
                urlString = "\(urlString)\(averageFeaturesString)"
            }
        }
        
        //Create URL Request to get songs
        let url = URL(string: urlString);
        var request = URLRequest(url: url!)
        let accessToken = auth.session.accessToken!
        var spotifyResults:[SpotifyTrack] = [];
        
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization");
        
        executeSpotifyCall(with: request, spotifyCallCompletionHandler: { (data, httpResponse, error, isSuccess) in
            let statusCode:Int! = httpResponse != nil ? httpResponse?.statusCode : -1
            if isSuccess {
                let jsonObject = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
                let trackList = jsonObject["tracks"] as! [[String: AnyObject]]
                for track in trackList {
                    let trackName = track["name"] as! String;
                    let uri = track["uri"] as! String;
                    let id = track["id"] as! String;
                    let album = track["album"] as! [String: AnyObject];
                    let images = album["images"] as! [[String: AnyObject]];
                    let hqImage = images.count > 0 ? images[0]["url"] as! String : ""
                    let artists = track["artists"] as! [[String: AnyObject]];
                    let artistName = artists.count > 0 ? artists[0]["name"] as! String : "Unknown Artist";
                    let artistUri = artists.count > 0 ? artists[0]["uri"] as! String : "Unknown URI";
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
                //                case (300...399):
                case (400...499):
                    completionHandler([], NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.clientError))
                case (500...599):
                    completionHandler([], NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.serverError))
                default:
                    completionHandler([], NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.technicalError));
                }
            }
            
        })
        
    }
    
    func fetchRecommendations(for recommendation: SpotifyRecommendation,
                              numberOfSongs: Int,
                              artists: [SpotifyArtist],
                              completionHandler: @escaping ([SpotifyTrack], NewsicError?) -> ()) {
        fetchSpotifyRecommendations(for: recommendation, numberOfSongs: numberOfSongs, artists: artists, completionHandler: completionHandler)
    }
    
    func fetchRecommendations(for recommendation: SpotifyRecommendation,
                              numberOfSongs: Int,
                              tracks: [SpotifyTrack],
                              completionHandler: @escaping ([SpotifyTrack], NewsicError?) -> ()) {
        fetchSpotifyRecommendations(for: recommendation, numberOfSongs: numberOfSongs, tracks: tracks, completionHandler: completionHandler)
    }
    
    func fetchRecommendations(for recommendation: SpotifyRecommendation,
                              numberOfSongs: Int,
                              moodObject: NewsicMood?,
                              preferredTrackFeatures: [SpotifyTrackFeature]? = nil,
                              selectedGenreList: [String: Int]? = nil,
                              completionHandler: @escaping ([SpotifyTrack], NewsicError?) -> ()) {
        fetchSpotifyRecommendations(for: recommendation, numberOfSongs: numberOfSongs, moodObject: moodObject, preferredTrackFeatures: preferredTrackFeatures, selectedGenreList: selectedGenreList, completionHandler: completionHandler)
    }
    
    func fetchSpotifyRecommendations(for recommendation: SpotifyRecommendation,
                              numberOfSongs: Int,
                              moodObject: NewsicMood? = nil,
                              preferredTrackFeatures: [SpotifyTrackFeature]? = nil,
                              selectedGenreList: [String: Int]? = nil,
                              artists: [SpotifyArtist]? = nil,
                              tracks: [SpotifyTrack]? = nil,
                              completionHandler: @escaping ([SpotifyTrack], NewsicError?) -> ()) {
        
        
        var urlString = "https://api.spotify.com/v1/recommendations?"
        
        switch recommendation {
        case .genres:
            
            //Get Genres
            let hasList = moodObject?.associatedGenres != nil ? true : false;
            let genres = getGenreListString(numberOfSongs: numberOfSongs, hasList: hasList, selectedGenreList: selectedGenreList);
            urlString.append("seed_genres=\(genres)")
            if let preferredTrackFeatures = preferredTrackFeatures {
                if preferredTrackFeatures.count > 0 {
                    let averageFeatures = getAverageTrackFeatures(preferredTrackFeatures: preferredTrackFeatures)
                    let averageFeaturesString = trackFeaturesToString(features: averageFeatures)
                    urlString.append(averageFeaturesString)
                }
            }
        case .artist:
            if let artists = artists {
                var artistString = "&seed_artists="
                for artist in artists {
                    artistString.append("\(artist.id!),")
                }
                
                artistString.removeLast();
                
                urlString.append(artistString)
            }
        case .track:
            if let tracks = tracks {
                var trackString = "&seed_tracks="
                for track in tracks {
                    trackString.append("\(track.trackId!),")
                }
                
                trackString.removeLast();
                
                urlString.append(trackString)
            }
        }
        
        urlString.append("&limit=\(numberOfSongs)")
        //Create URL Request to get songs
        let url = URL(string: urlString);
        var request = URLRequest(url: url!)
        let accessToken = auth.session.accessToken!
        var spotifyResults:[SpotifyTrack] = [];
        
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization");
        
        executeSpotifyCall(with: request, spotifyCallCompletionHandler: { (data, httpResponse, error, isSuccess) in
            let statusCode:Int! = httpResponse != nil ? httpResponse?.statusCode : -1
            if isSuccess {
                let jsonObject = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
                let trackList = jsonObject["tracks"] as! [[String: AnyObject]]
                for track in trackList {
                    let trackName = track["name"] as! String;
                    let uri = track["uri"] as! String;
                    let id = track["id"] as! String;
                    let album = track["album"] as! [String: AnyObject];
                    let images = album["images"] as! [[String: AnyObject]];
                    let hqImage = images.count > 0 ? images[0]["url"] as! String : ""
                    let artists = track["artists"] as! [[String: AnyObject]];
                    let artistName = artists.count > 0 ? artists[0]["name"] as! String : "Unknown Artist";
                    let artistUri = artists.count > 0 ? artists[0]["uri"] as! String : "Unknown URI";
                    let title = "\(artistName) - \(trackName)"
                    
                    let spotifyObject = SpotifyTrack(title: title, thumbNailUrl: hqImage, trackUri: uri, trackId: id, songName: trackName, artist: SpotifyArtist(artistName: artistName, uri: artistUri, id: Spotify.transformToID(type: .artist, uri: artistUri)), audioFeatures: nil);
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
                //                case (300...399):
                case (400...499):
                    completionHandler([], NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.clientError))
                case (500...599):
                    completionHandler([], NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.serverError))
                default:
                    completionHandler([], NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.technicalError));
                }
            }
            
        })
        
    }
}
