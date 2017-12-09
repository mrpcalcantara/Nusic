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
        //&min_popularity=\(popularity)
        
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
}
