//
//  SpotifyBrowse.swift
//  Nusic
//
//  Created by Miguel Alcantara on 09/10/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

extension Spotify {
   
    final func fetchRecommendations(for recommendation: SpotifyRecommendation,
                              numberOfSongs: Int,
                              market: String? = nil,
                              artists: [SpotifyArtist],
                              completionHandler: @escaping ([SpotifyTrack], NusicError?) -> ()) {
        fetchSpotifyRecommendations(for: recommendation, numberOfSongs: numberOfSongs, artists: artists, completionHandler: completionHandler)
    }
    
    final func fetchRecommendations(for recommendation: SpotifyRecommendation,
                              numberOfSongs: Int,
                              market: String? = nil,
                              tracks: [SpotifyTrack],
                              completionHandler: @escaping ([SpotifyTrack], NusicError?) -> ()) {
        fetchSpotifyRecommendations(for: recommendation, numberOfSongs: numberOfSongs, tracks: tracks, completionHandler: completionHandler)
    }
    
    final func fetchRecommendations(for recommendation: SpotifyRecommendation,
                              numberOfSongs: Int,
                              market: String? = nil,
                              moodObject: NusicMood?,
                              preferredTrackFeatures: [SpotifyTrackFeature]? = nil,
                              selectedGenreList: [String: Int]? = nil,
                              completionHandler: @escaping ([SpotifyTrack], NusicError?) -> ()) {
        fetchSpotifyRecommendations(for: recommendation, numberOfSongs: numberOfSongs, moodObject: moodObject, preferredTrackFeatures: preferredTrackFeatures, selectedGenreList: selectedGenreList, market: market, completionHandler: completionHandler)
    }
 
    final func fetchSpotifyRecommendations(for recommendation: SpotifyRecommendation,
                                     numberOfSongs: Int,
                                     moodObject: NusicMood? = nil,
                                     preferredTrackFeatures: [SpotifyTrackFeature]? = nil,
                                     selectedGenreList: [String: Int]? = nil,
                                     market: String? = nil,
                                     artists: [SpotifyArtist]? = nil,
                                     tracks: [SpotifyTrack]? = nil,
                                     completionHandler: @escaping ([SpotifyTrack], NusicError?) -> ()) {
        
        
        var urlString = "https://api.spotify.com/v1/recommendations?"
        if let market = market {
            urlString.append("market=\(market)&")
        }
        
        urlString += buildUrlString(recommendation: recommendation, numberOfSongs: numberOfSongs, moodObject: moodObject, preferredTrackFeatures: preferredTrackFeatures, selectedGenreList: selectedGenreList, artists: artists, tracks: tracks)
        urlString.append("&limit=\(numberOfSongs)")
        //Create URL Request to get songs
        let url = URL(string: urlString);
        var request = URLRequest(url: url!)
        let accessToken = auth.session.accessToken!
        var spotifyResults:[SpotifyTrack] = Array();
        
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization");
        
        executeSpotifyCall(with: request, spotifyCallCompletionHandler: { (data, httpResponse, error, isSuccess) in
            let statusCode:Int! = httpResponse != nil ? httpResponse?.statusCode : -1
            guard isSuccess else { completionHandler([], NusicError.manageError(statusCode: statusCode, errorCode: NusicErrorCodes.spotifyError, description: SpotifyErrorCodeDescription.getMusicInGenres.rawValue)); return; }
            let jsonObject = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
            let trackList = jsonObject["tracks"] as! [[String: AnyObject]]
            for track in trackList {
                if let trackData = try? JSONSerialization.data(withJSONObject: track, options: JSONSerialization.WritingOptions.prettyPrinted),
                    let decodedTrack = try? JSONDecoder().decode(SpotifyTrack.self, from: trackData) {
                    spotifyResults.append(decodedTrack);
                }
                
            }
            let artistUriList = spotifyResults.flatMap({ $0.artist.map({ $0.uri! }) })
            self.getAllGenresForArtists(artistUriList, offset: 0, artistGenresHandler: { (artistList, error) in
                if let artistList = artistList {
                    for artist in artistList {
                        guard let artistIndex = spotifyResults.index(where: { (track) -> Bool in
                            return track.artist.map({$0.uri}).contains(where: { $0 == artist.uri })
                        }) else { return }
                        spotifyResults[artistIndex].artist.updateArtist(artist: artist)
                    }
                }
                
                completionHandler(spotifyResults, nil)
            })
            
        })
        
    }

    private func buildUrlString(recommendation: SpotifyRecommendation,
                        numberOfSongs: Int,
                        moodObject: NusicMood? = nil,
                        preferredTrackFeatures: [SpotifyTrackFeature]? = nil,
                        selectedGenreList: [String: Int]? = nil,
                        artists: [SpotifyArtist]? = nil,
                        tracks: [SpotifyTrack]? = nil) -> String {
        switch recommendation {
            case .genres:
                return buildUrlStringGenres(numberOfSongs: numberOfSongs, hasList: moodObject?.associatedGenres != nil, selectedGenreList: selectedGenreList, preferredTrackFeatures: preferredTrackFeatures)
            case .track:
                return buildUrlStringTracks(tracks: tracks)
            case .artist:
                return buildUrlStringArtists(artists: artists)
        }
    }
    
    private func buildUrlStringGenres(numberOfSongs: Int, hasList: Bool, selectedGenreList: [String: Int]?, preferredTrackFeatures: [SpotifyTrackFeature]? = nil) -> String {
        var urlString = ""
        let genres = getGenreListString(numberOfSongs: numberOfSongs, hasList: hasList, selectedGenreList: selectedGenreList);
        urlString.append("seed_genres=\(genres)")
        if let preferredTrackFeatures = preferredTrackFeatures {
            if preferredTrackFeatures.count > 0 {
                let averageFeatures = getAverageTrackFeaturesRandomized(preferredTrackFeatures: preferredTrackFeatures)
                let averageFeaturesString = trackFeaturesToString(features: averageFeatures)
                urlString.append(averageFeaturesString)
            }
        }
        return urlString
    }
    
    private func buildUrlStringArtists(artists: [SpotifyArtist]?) -> String {
        var urlString = ""
        if let artists = artists {
            var artistString = "&seed_artists="
            for artist in artists {
                if let artistId = artist.id {
                    artistString.append("\(artistId),")
                }
                
            }
            
            artistString.removeLast();
            
            urlString.append(artistString)
        }
        return urlString
    }
    
    private func buildUrlStringTracks(tracks: [SpotifyTrack]?) -> String {
        var urlString = ""
        if let tracks = tracks {
            var trackString = "&seed_tracks="
            for track in tracks {
                trackString.append("\(track.trackId!),")
            }
            
            trackString.removeLast();
            
            urlString.append(trackString)
        }
        return urlString
    }
    
    private func getGenreListString(numberOfSongs:Int, hasList: Bool, selectedGenreList:[String: Int]? = nil) -> String {
        var hasList = hasList
        var index = 0
        var genres = ""
        var genreListCount = 0
        var totalCount = genreListCount
        var selectedGenreList = selectedGenreList
        
        if let selectedGenreList = selectedGenreList, selectedGenreList.count > 0 {
            genreListCount = selectedGenreList.count
        } else {
            hasList = false
            selectedGenreList = nil
            if genreCount.count < numberOfSongs && genreCount.count > 0 {
                var list: String = ""
                for keyValue in genreCount {
                    if index > 4 {
                        break;
                    }
                    index += 1
                    list.append("\(keyValue.key),")
                }
                list.removeLast()
                return list
                
            } else {
                genreListCount = numberOfSongs
            }
        }
        
        totalCount = genreListCount
        
        //NOTE: Spotify recommendations max seed genres is 5. This is a workaround by fixing the max count to 5.
        if numberOfSongs > 5 && genreListCount > 5 {
            totalCount = 5
        }
        
        while index < totalCount {
            var separator = ","
            if index == totalCount-1 {
                separator = ""
            }
            var genre = getRandomGenreBasedOnPercentage(hasGenreListForEmotion: hasList, selectedGenreList: selectedGenreList);
            genre = genre.replacingOccurrences(of: " ", with: "-")
            if !genres.contains(genre) {
                genres += "\(genre)\(separator)"
            } else {
                index -= 1;
            }
            
            index += 1;
        }
        return genres;
    }
    
    private func getAverageTrackFeatures(preferredTrackFeatures: [SpotifyTrackFeature]) -> SpotifyTrackFeature {
        
        let trackCount = Double(preferredTrackFeatures.count)
        
        var acousticness:Double = 0
        var danceability:Double = 0
        var energy:Double = 0
        var instrumentalness:Double = 0
        var liveness:Double = 0
        var loudness:Double = 0
        var speechiness:Double = 0
        var tempo:Double = 0
        var valence:Double = 0
        
        for trackFeatures in preferredTrackFeatures {
            
            acousticness = trackFeatures.acousticness != nil ? acousticness + trackFeatures.acousticness! : 0
            danceability = trackFeatures.danceability != nil ? danceability + trackFeatures.danceability! : 0
            energy = trackFeatures.energy != nil ? energy + trackFeatures.energy! : 0
            instrumentalness = trackFeatures.instrumentalness != nil ? instrumentalness + trackFeatures.instrumentalness! : 0
            liveness = trackFeatures.liveness != nil ? liveness + trackFeatures.liveness! : 0
            loudness = trackFeatures.loudness != nil ? loudness - trackFeatures.loudness! : 0
            speechiness = trackFeatures.speechiness != nil ? speechiness + trackFeatures.speechiness! : 0
            tempo = trackFeatures.tempo != nil ?  tempo + trackFeatures.tempo! : 0
            valence = trackFeatures.valence != nil ? valence + trackFeatures.valence! : 0
        }
        
        acousticness /= Double(trackCount)
        danceability /= Double(trackCount)
        energy /= Double(trackCount)
        instrumentalness /= Double(trackCount)
        liveness /= Double(trackCount)
        loudness /= Double(trackCount)
        speechiness /= Double(trackCount)
        tempo /= Double(trackCount)
        valence /= Double(trackCount)
        
        return SpotifyTrackFeature(acousticness: acousticness, danceability: danceability, energy: energy, instrumentalness: instrumentalness, liveness: liveness, loudness: loudness, speechiness: speechiness, tempo: tempo, valence: valence)
        
    }
    
    private func getAverageTrackFeaturesRandomized(preferredTrackFeatures: [SpotifyTrackFeature]) -> [String: AnyObject] {
        var emotionValues:[String: AnyObject] = [:]
        var trackFeatures = getAverageTrackFeatures(preferredTrackFeatures: preferredTrackFeatures)
        
        trackFeatures.danceability!.randomInRange(value: trackFeatures.danceability!, range: 0.2, acceptNegativeValues: false)
        trackFeatures.energy!.randomInRange(value: trackFeatures.energy!, range: 0.2, acceptNegativeValues: false)
        trackFeatures.instrumentalness!.randomInRange(value: trackFeatures.instrumentalness!, range: 0.2, acceptNegativeValues: false)
        trackFeatures.liveness!.randomInRange(value: trackFeatures.liveness!, range: 0.2, acceptNegativeValues: false)
        trackFeatures.loudness!.randomInRange(value: trackFeatures.loudness!, range: 3, acceptNegativeValues: true)
        trackFeatures.speechiness!.randomInRange(value: trackFeatures.speechiness!, range: 0.2, acceptNegativeValues: false)
        trackFeatures.tempo!.randomInRange(value: trackFeatures.tempo!, range: 100, acceptNegativeValues: false, maxValue: 250)
        trackFeatures.valence!.randomInRange(value: trackFeatures.valence!, range: 0.2, acceptNegativeValues: false)
        
        emotionValues["acousticness"] = trackFeatures.acousticness as AnyObject
        emotionValues["danceability"] = trackFeatures.danceability as AnyObject
        emotionValues["energy"] = trackFeatures.energy as AnyObject
        emotionValues["instrumentalness"] = trackFeatures.instrumentalness as AnyObject
        emotionValues["liveness"] = trackFeatures.liveness as AnyObject
        emotionValues["loudness"] = trackFeatures.loudness as AnyObject
        emotionValues["speechiness"] = trackFeatures.speechiness as AnyObject
        emotionValues["tempo"] = trackFeatures.tempo as AnyObject
        emotionValues["valence"] = trackFeatures.valence as AnyObject
        
        return emotionValues;
    }
    
    private func trackFeaturesToString(features: [String: AnyObject]) -> String {
        var result = "&"
        var iterator = features.makeIterator();
        
        var nextElement = iterator.next();
        
        while nextElement != nil {
            if let element = nextElement {
                let key = element.key
                if let value = element.value as? Double {
                    result += "target_\(key)=\(value.roundToDecimalPlaces(places: 3))&"
                }
            }
            nextElement = iterator.next();
        }
        result.removeLast()
        return result;
    }
 
    private func getRandomGenreBasedOnPercentage(hasGenreListForEmotion: Bool, selectedGenreList: [String: Int]? = nil) -> String{
        let sortedKeys: [(key: String, value:Int)];
        if selectedGenreList == nil {
            sortedKeys = genreCount.sorted(by: { $0.value > $1.value })
        } else {
            sortedKeys = (selectedGenreList?.sorted(by: { $0.value > $1.value }))!;
        }
        
        var percentagesString: [String] = []
        let percentageRate:Double = hasGenreListForEmotion ? 50 : 100
        
        
        for keyValue in sortedKeys {
            let percentage = (Double(keyValue.value)/Double(sortedKeys.count))*percentageRate
            let percentageInt = Int(percentage)
            for _ in 0..<percentageInt {
                percentagesString.append(keyValue.key)
            }
        }
        
        let randomIndex = Int.random(range: 1..<percentagesString.count);
        return percentagesString[randomIndex];
        
    }
    
}
