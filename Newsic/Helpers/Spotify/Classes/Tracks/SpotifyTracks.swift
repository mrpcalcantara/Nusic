
//  SpotifyBrowse.swift
//  Nusic
//
//  Created by Miguel Alcantara on 09/10/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

extension Spotify {
    
    func getTrackInfo(for trackList: [String], offset: Int, currentExtractedTrackList: [SpotifyTrack], trackInfoListHandler: @escaping([SpotifyTrack]?, NusicError?) -> ()) {
        
        if trackList.count <= 0 {
            return;
        }
        var spotifyTrackList: [SpotifyTrack] = currentExtractedTrackList
        var currentTrackList:[String] = []
        let checkLimit = currentExtractedTrackList.count-offset
        
        
        if checkLimit > 50 {
            currentTrackList = Array(trackList[offset...offset+49]);
        } else {
            currentTrackList = Array(trackList[offset...trackList.count-1])
        }
        
        let nextOffset = offset+50
        
        var trackUriList: [URL] = []
        
        for trackURI in currentTrackList {
            trackUriList.append(URL(string: Spotify.transformToURI(type: .track, id: trackURI))!)
        }
        
        do {
            let request = try SPTTrack.createRequest(forTracks: trackUriList, withAccessToken: self.auth.session.accessToken!, market: self.user.territory);
            
            executeSpotifyCall(with: request, spotifyCallCompletionHandler: { (data, httpResponse, error, isSuccess) in
                let statusCode:Int! = httpResponse != nil ? httpResponse?.statusCode : -1
                if isSuccess {
                    let jsonObject = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject];
                    let extractedTrackList = jsonObject["tracks"] as! [[String:AnyObject]];
                    for track in extractedTrackList {
                        let artistInfo = track["artists"] as! [[String: AnyObject]]
                        let albumInfo = track["album"] as! [String: AnyObject]
                        let imageInfo = albumInfo["images"] as! [[String: AnyObject]]
                        var artists = ""
                        let index = 0
                        let artistCount = artistInfo.count
                        var artistId = ""
                        var artistUri = ""
                        
                        for artist in artistInfo {
                            if let artistName = artist["name"] as? String, let id = artist["id"] as? String, let uri = artist["uri"] as? String {
                                artists += "\(artistName)"
                                if index <= artistCount - 1 {
                                    artists += ", ";
                                }
                                artistId = id
                                artistUri = uri
                                
                            }
                            
                        }
                        artists.removeLast(); artists.removeLast();
                        
                        var songExternalHref = ""
                        if let trackHref = track["external_urls"] as? [String: AnyObject] {
                            songExternalHref = trackHref["spotify"] as! String
                        }
                        
                        let albumImage = imageInfo[1]["url"] as? String;
                        if let trackName = track["name"] as? String,
                            let trackId = track["id"] as? String,
                            let trackUri = track["uri"] as? String,
                            let albumImage = albumImage {
                            let track = SpotifyTrack(title: trackName, thumbNailUrl: albumImage, trackUri: trackUri, trackId: trackId, songName: trackName, songHref: songExternalHref, artist: SpotifyArtist(artistName: artists, uri: artistUri, id: artistId), audioFeatures: nil);
                            spotifyTrackList.append(track);
                        }
                    }
                    
                    let nextPage = jsonObject["next"] as? String
                    if let nextPage = nextPage {
//                        let nextPageUrl = URL(string: nextPage)
//                        let nextPageUrlRequest = URLRequest(url: nextPageUrl!)
                        self.getTrackInfo(for: trackList, offset: nextOffset, currentExtractedTrackList: currentExtractedTrackList, trackInfoListHandler: { (trackList, error) in
                            trackInfoListHandler(trackList, nil);
                        })
                    } else {
                        
                        let sortedList = spotifyTrackList.sorted(by: { (track1, track2) -> Bool in
                            track1.addedAt!! > track2.addedAt!!
                        })
                        trackInfoListHandler(sortedList, nil);
                    }
                } else {
                    switch statusCode {
                    case 400...499:
                        trackInfoListHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.spotifyError, nusicErrorSubCode: NusicErrorSubCode.clientError))
                    case 500...599:
                        trackInfoListHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.spotifyError, nusicErrorSubCode: NusicErrorSubCode.serverError))
                    default: trackInfoListHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.spotifyError, nusicErrorSubCode: NusicErrorSubCode.technicalError));
                    }
                }
            })
            
        } catch { }
    }
    
    func getTrackDetails(trackId: String, fetchedTrackDetailsHandler: @escaping (SpotifyTrackFeature?, NusicError?) -> () ) {
        do {
            let trackUrl = URL(string: "spotify:track:\(trackId)")!
            var trackFeaturesRequest = try SPTTrack.createRequest(forTrack: trackUrl, withAccessToken: auth.session.accessToken!, market: self.user.territory)
            trackFeaturesRequest.url =  URL(string: "https://api.spotify.com/v1/audio-features/\(trackId)")
            
            executeSpotifyCall(with: trackFeaturesRequest, spotifyCallCompletionHandler: { (data, httpResponse, error, isSuccess) in
                let statusCode:Int! = httpResponse != nil ? httpResponse?.statusCode : -1
                if isSuccess {
                    do {
                        let jsonObject = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
                        var spotifyTrackFeature = SpotifyTrackFeature()
                        spotifyTrackFeature.mapDictionary(featureDictionary: jsonObject);
                        fetchedTrackDetailsHandler(spotifyTrackFeature, nil)
                    } catch {
                        print("error parsing track features for track \(trackId)");
                    }
                } else {
                    switch statusCode {
                    case 400...499:
                        fetchedTrackDetailsHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.spotifyError, nusicErrorSubCode: NusicErrorSubCode.clientError))
                    case 500...599:
                        fetchedTrackDetailsHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.spotifyError, nusicErrorSubCode: NusicErrorSubCode.serverError))
                    default: fetchedTrackDetailsHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.spotifyError, nusicErrorSubCode: NusicErrorSubCode.technicalError));
                    }
                }
            })
        } catch {
            fetchedTrackDetailsHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.spotifyError, nusicErrorSubCode: NusicErrorSubCode.technicalError));
            print("error creating request for track features for track \(trackId)");
        }
    }
    
    func getTrackArtist(trackId: String, fetchedTrackArtistHandler: @escaping (String?, NusicError?) -> () ) {
        do {
            let trackUrl = URL(string: "spotify:track:\(trackId)")!
            let trackRequest = try SPTTrack.createRequest(forTrack: trackUrl, withAccessToken: auth.session.accessToken!, market: self.user.territory)
            
            executeSpotifyCall(with: trackRequest, spotifyCallCompletionHandler: { (data, httpResponse, error, isSuccess) in
                let statusCode:Int! = httpResponse != nil ? httpResponse?.statusCode : -1
                if isSuccess {
                    do {
                        let jsonObject = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
                        let firstArtist = jsonObject["artists"] as! [[String: AnyObject]]
                        fetchedTrackArtistHandler(firstArtist.first?["id"] as? String, nil);
                    } catch {
                        
                    }
                    
                } else {
                    switch statusCode {
                    case 400...499:
                        fetchedTrackArtistHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.spotifyError, nusicErrorSubCode: NusicErrorSubCode.clientError));
                    case 500...599:
                        fetchedTrackArtistHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.spotifyError, nusicErrorSubCode: NusicErrorSubCode.serverError));
                    default: fetchedTrackArtistHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.spotifyError, nusicErrorSubCode: NusicErrorSubCode.technicalError));
                    }
                }
            })
        } catch {
            fetchedTrackArtistHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.spotifyError, nusicErrorSubCode: NusicErrorSubCode.technicalError));
            print("error creating request for track features for track \(trackId)");
        }
    }
    
    
    func getAllTracksForPlaylist(playlistId: String, fetchGenres: Bool? = true, nextTrackPageRequest: URLRequest? = nil, currentTrackList: [SpotifyTrack]? = nil, fetchedPlaylistTracks: @escaping([SpotifyTrack]?, NusicError?) -> ()) {
        
        let userId = auth.session.canonicalUsername;
        var currentList: [SpotifyTrack] = currentTrackList != nil ? currentTrackList! : [];
        var pageRequest = nextTrackPageRequest;
        if pageRequest == nil {
            let url = "https://api.spotify.com/v1/users/\(userId!)/playlists/\(playlistId)/tracks?fields=next,items(added_at,track(id,uri,name,external_urls,artists(name,id,uri),album(images(url))))"
            pageRequest = URLRequest(url: URL(string: url)!);
        }
        
        pageRequest?.addValue("Bearer \(self.auth.session.accessToken!)", forHTTPHeaderField: "Authorization")

        executeSpotifyCall(with: pageRequest!, spotifyCallCompletionHandler: { (data, httpResponse, error, isSuccess) in
            let statusCode:Int! = httpResponse != nil ? httpResponse?.statusCode : -1
            if isSuccess {
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject];
                    let artistList = jsonObject["items"] as! [[String:AnyObject]];
                    for artist in artistList {
                        let trackInfo = artist["track"] as! [String: AnyObject]
                        let artistInfo = trackInfo["artists"] as! [[String: AnyObject]]
                        let albumInfo = trackInfo["album"] as! [String: AnyObject]
                        let imageInfo = albumInfo["images"] as! [[String: AnyObject]]
                        let addedAt = artist["added_at"] as! String
                        
                        let dateFormatter = DateFormatter();
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                        
                        let dateAdded = dateFormatter.date(from: addedAt)
                        
                        var artists = ""
                        var artistId = ""
                        var artistUri = ""
                        let index = 0
                        let artistCount = artistInfo.count
                        for artist in artistInfo {
                            if let artistName = artist["name"] as? String, let id = artist["id"] as? String, let uri = artist["uri"] as? String {
                                artists += "\(artistName)"
                                if index <= artistCount - 1 {
                                    artists += ", ";
                                }
                                artistId = id
                                artistUri = uri
                                
                            }
                            
                        }
                        
                        
                        artists.removeLast(); artists.removeLast();
                        
                        var songExternalHref = ""
                        if let trackHref = trackInfo["external_urls"] as? [String: AnyObject] {
                            songExternalHref = trackHref["spotify"] as! String
                        }
                        //print(artists)
                        let albumImage = imageInfo[1]["url"] as? String;
                        if let trackName = trackInfo["name"] as? String,
                            let trackId = trackInfo["id"] as? String,
                            let trackUri = trackInfo["uri"] as? String,
                            let albumImage = albumImage {
                            let track = SpotifyTrack(title: trackName, thumbNailUrl: albumImage, trackUri: trackUri, trackId: trackId, songName: trackName, songHref: songExternalHref, artist: SpotifyArtist(artistName: artists, uri: artistUri, id: artistId), addedAt: dateAdded, audioFeatures: nil);
                            currentList.append(track);
                        }
                    }
                    
                    let nextPage = jsonObject["next"] as? String
                    if let nextPage = nextPage {
                        let nextPageUrl = URL(string: nextPage)
                        let nextPageUrlRequest = URLRequest(url: nextPageUrl!)
                        self.getAllTracksForPlaylist(playlistId: playlistId, fetchGenres: fetchGenres, nextTrackPageRequest: nextPageUrlRequest, currentTrackList: currentTrackList, fetchedPlaylistTracks: { (currentTrackList, error) in
                            fetchedPlaylistTracks(currentList, error);
                        })
                    } else {
                        
                        let sortedList = currentList.sorted(by: { (track1, track2) -> Bool in
                            track1.addedAt!! > track2.addedAt!!
                        })
                        
                        
                        
                        if fetchGenres! {
                            let spotifyArtistList = sortedList.map({ $0.artist.uri }) as! [String]
                            self.getAllGenresForArtists(spotifyArtistList, offset: 0, artistGenresHandler: { (fetchedArtistList, error) in
                                if let error = error {
                                    fetchedPlaylistTracks(nil, error)
                                } else {
                                    if let fetchedArtistList = fetchedArtistList {
                                        for artist in fetchedArtistList {
                                            if let index = sortedList.index(where: { (track) -> Bool in
                                                return track.artist.uri == artist.uri
                                            }) {
                                                sortedList[index].artist = artist
                                            }
                                        }
                                    }
                                    fetchedPlaylistTracks(sortedList, nil)
                                }
                            })
                        } else {
                            fetchedPlaylistTracks(sortedList, nil);
                        }
                        
                        
                    }
                } catch { }
                
            } else {
                switch statusCode {
                case 400...499:
                    fetchedPlaylistTracks(nil, NusicError(nusicErrorCode: NusicErrorCodes.spotifyError, nusicErrorSubCode: NusicErrorSubCode.clientError))
                case 500...599:
                    fetchedPlaylistTracks(nil, NusicError(nusicErrorCode: NusicErrorCodes.spotifyError, nusicErrorSubCode: NusicErrorSubCode.serverError))
                default: fetchedPlaylistTracks(nil, NusicError(nusicErrorCode: NusicErrorCodes.spotifyError, nusicErrorSubCode: NusicErrorSubCode.technicalError));
                }
            }
        })
        
    }
    
    func addTracksToPlaylist(playlistId: String, trackId: String, addTrackHandler: @escaping(Bool, NusicError?) -> ()) {
        let username: String! = auth.session.canonicalUsername!
        let accessToken: String! = auth.session.accessToken!
        let urlString = "https://api.spotify.com/v1/users/\(username!)/playlists/\(playlistId)/tracks?uris=\(trackId)"
        guard let url = URL(string: urlString) else {
            return;
        }
        var createPlaylistRequest = URLRequest(url: url);
        createPlaylistRequest.addValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
        createPlaylistRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        createPlaylistRequest.httpMethod = "POST";
        
        executeSpotifyCall(with: createPlaylistRequest, spotifyCallCompletionHandler: { (data, httpResponse, error, isSuccess) in
            let statusCode:Int! = httpResponse != nil ? httpResponse?.statusCode : -1
            if isSuccess {
                addTrackHandler(true, nil);
            } else {
                switch statusCode {
                case 400...499:
                    addTrackHandler(false, NusicError(nusicErrorCode: NusicErrorCodes.spotifyError, nusicErrorSubCode: NusicErrorSubCode.clientError))
                case 500...599:
                    addTrackHandler(false, NusicError(nusicErrorCode: NusicErrorCodes.spotifyError, nusicErrorSubCode: NusicErrorSubCode.serverError))
                default: addTrackHandler(false, NusicError(nusicErrorCode: NusicErrorCodes.spotifyError, nusicErrorSubCode: NusicErrorSubCode.technicalError));
                }
            }
        })
//        do {
//            
//        } catch {
//            addTrackHandler(false, NusicError(nusicErrorCode: NusicErrorCodes.spotifyError, nusicErrorSubCode: NusicErrorSubCode.technicalError));
//            print("error creating request adding track \(trackId) to playlist \(playlistId)");
//        }
    }
    
    func removeTrackFromPlaylist(playlistId: String, tracks: [String: String], removeTrackHandler: @escaping(Bool, NusicError?) -> ()) {
        let username: String! = auth.session.canonicalUsername!
        let accessToken: String! = auth.session.accessToken!
        let url = "https://api.spotify.com/v1/users/\(username!)/playlists/\(playlistId)/tracks"
        var removeTrackRequest = URLRequest(url: URL(string: url)!);
        removeTrackRequest.addValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
        removeTrackRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        removeTrackRequest.httpMethod = "DELETE";
        
        
        var iterator = tracks.makeIterator();
        var element = iterator.next()
        var tracksToRemove = ""
        
        while element != nil {
            if let element = element {
//                tracksToRemove += "{\"positions\":[\(element.key)],\"uri\":\"\(element.value)\"},"
                tracksToRemove += "{\"uri\":\"\(element.value)\"},"
            }
            element = iterator.next();
        }
        tracksToRemove.removeLast()
        
        let body = "{\"tracks\":[\(tracksToRemove)]}";
        removeTrackRequest.httpBody = body.data(using: .utf8)
        
        executeSpotifyCall(with: removeTrackRequest, spotifyCallCompletionHandler: { (data, httpResponse, error, isSuccess) in
            let statusCode:Int! = httpResponse != nil ? httpResponse?.statusCode : -1
            if isSuccess {
                removeTrackHandler(true, nil);
            } else {
                switch statusCode {
                case 400...499:
                    removeTrackHandler(true, NusicError(nusicErrorCode: NusicErrorCodes.spotifyError, nusicErrorSubCode: NusicErrorSubCode.clientError));
                case 500...599:
                    removeTrackHandler(true, NusicError(nusicErrorCode: NusicErrorCodes.spotifyError, nusicErrorSubCode: NusicErrorSubCode.serverError));
                default: removeTrackHandler(true, NusicError(nusicErrorCode: NusicErrorCodes.spotifyError, nusicErrorSubCode: NusicErrorSubCode.technicalError));
                }
            }
        })
//        do {
//            
//        } catch {
//            removeTrackHandler(false, NusicError(nusicErrorCode: NusicErrorCodes.spotifyError, nusicErrorSubCode: NusicErrorSubCode.technicalError));
//            print("error creating request deleting track from playlist \(playlistId)");
//        }
    }
    
    func isTrackInPlaylist(trackId: String, playlistId: String, checkTrackHandler: @escaping (Bool) -> ()) {
        getAllTracksForPlaylist(playlistId: playlistId) { (trackList, error) in
            if let trackList = trackList {
                let containsTrack = trackList.contains(where: { (playlistTrack) -> Bool in
                    return playlistTrack.trackId == trackId
                })
                checkTrackHandler(containsTrack)
            }
        }
    }
    
}
