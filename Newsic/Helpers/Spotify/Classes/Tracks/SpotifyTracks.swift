
//  SpotifyBrowse.swift
//  Nusic
//
//  Created by Miguel Alcantara on 09/10/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

extension Spotify {
    
    final func getTrackInfo(for trackList: [String], offset: Int, currentExtractedTrackList: [SpotifyTrack], trackInfoListHandler: @escaping([SpotifyTrack]?, NusicError?) -> ()) {
        guard trackList.count > 0 else { return; }
        var spotifyTrackList: [SpotifyTrack] = currentExtractedTrackList
        var currentTrackList:[String] = []
        let checkLimit = currentExtractedTrackList.count-offset
        let nextOffset = offset+50
        //Spotify Limitation: 50 songs is the maximum we can get details from
        currentTrackList = checkLimit > 50 ? Array(trackList[offset...offset+49]) : Array(trackList[offset...trackList.count-1]);
        
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
                        
                        if let trackData = try? JSONSerialization.data(withJSONObject: track, options: JSONSerialization.WritingOptions.prettyPrinted), let decodedTrack = try? JSONDecoder().decode(SpotifyTrack.self, from: trackData) {
                            spotifyTrackList.append(decodedTrack);
                        }
                        
                    }
                    if jsonObject["next"] as? String != nil {
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
                    trackInfoListHandler(nil, NusicError.manageError(statusCode: statusCode, errorCode: NusicErrorCodes.spotifyError, description: SpotifyErrorCodeDescription.getTrackInfo.rawValue))
                }
            })
            
        } catch { }
    }
    
    final func getTrackDetails(trackId: String, fetchedTrackDetailsHandler: @escaping (SpotifyTrackFeature?, NusicError?) -> () ) {
        do {
            let trackUrl = URL(string: "spotify:track:\(trackId)")!
            var trackFeaturesRequest = try SPTTrack.createRequest(forTrack: trackUrl, withAccessToken: auth.session.accessToken!, market: self.user.territory)
            trackFeaturesRequest.url =  URL(string: "https://api.spotify.com/v1/audio-features/\(trackId)")
            
            executeSpotifyCall(with: trackFeaturesRequest, spotifyCallCompletionHandler: { (data, httpResponse, error, isSuccess) in
                let statusCode:Int! = httpResponse != nil ? httpResponse?.statusCode : -1
                if isSuccess {
                    if let decodedTrackFeatures = try? JSONDecoder().decode(SpotifyTrackFeature.self, from: data!) {
                        fetchedTrackDetailsHandler(decodedTrackFeatures, nil)
                    }
                } else {
                    fetchedTrackDetailsHandler(nil, NusicError.manageError(statusCode: statusCode, errorCode: NusicErrorCodes.spotifyError, description: SpotifyErrorCodeDescription.getTrackIdFeaturesForMood.rawValue))
                }
            })
        } catch {
            fetchedTrackDetailsHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.spotifyError, nusicErrorSubCode: NusicErrorSubCode.technicalError));
            print("error creating request for track features for track \(trackId)");
        }
    }
    
    final func getTrackArtist(trackId: String, fetchedTrackArtistHandler: @escaping (String?, NusicError?) -> () ) {
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
                    fetchedTrackArtistHandler(nil, NusicError.manageError(statusCode: statusCode, errorCode: NusicErrorCodes.spotifyError, description: SpotifyErrorCodeDescription.getTrackInfo.rawValue))
                }
            })
        } catch {
            fetchedTrackArtistHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.spotifyError, nusicErrorSubCode: NusicErrorSubCode.technicalError));
            print("error creating request for track features for track \(trackId)");
        }
    }
    
    final func getAllTracksForPlaylist(playlistId: String, fetchGenres: Bool? = true, nextTrackPageRequest: URLRequest? = nil, currentTrackList: [SpotifyTrack]? = nil, fetchedPlaylistTracks: @escaping([SpotifyTrack]?, NusicError?) -> ()) {
        
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
                    let trackList = jsonObject["items"] as! [[String:AnyObject]]
                    for track in trackList {
                        if
                            let trackChild = track["track"] as? [String : AnyObject],
                            let trackData = try? JSONSerialization.data(withJSONObject: trackChild, options: JSONSerialization.WritingOptions.prettyPrinted) {
                            if let decodedTrack = try? JSONDecoder().decode(SpotifyTrack.self, from: trackData) {
                                currentList.append(decodedTrack);
                            }
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
                            track1.songName > track2.songName
                        })
                        let dispatchGroup = DispatchGroup()
                        dispatchGroup.enter()
                        if fetchGenres! {
                            let spotifyArtistList = sortedList.flatMap({ $0.artist.map({ $0.uri }) }) as! [String]
                            self.getAllGenresForArtists(spotifyArtistList, offset: 0, artistGenresHandler: { (fetchedArtistList, error) in
                                guard let fetchedArtistList = fetchedArtistList else { fetchedPlaylistTracks(nil, error); return; }
                                for artist in fetchedArtistList {
                                    if let index = sortedList.index(where: { (track) -> Bool in
                                        return track.artist.map({$0.uri}).contains(where: { $0 == artist.uri })
                                    }) {
                                        sortedList[index].artist.updateArtist(artist: artist)
                                    }
                                }
                                dispatchGroup.leave()
                            })
                        } else {
                            dispatchGroup.leave()
                        }
                        
                        dispatchGroup.notify(queue: .main, execute: {
                            fetchedPlaylistTracks(sortedList, nil);
                        })
                    }
                } catch { }
                
            } else {
                fetchedPlaylistTracks(nil, NusicError.manageError(statusCode: statusCode, errorCode: NusicErrorCodes.spotifyError, description: SpotifyErrorCodeDescription.getPlaylistTracks.rawValue))
            }
        })
        
    }
    
    final func addTracksToPlaylist(playlistId: String, trackId: String, addTrackHandler: @escaping(Bool, NusicError?) -> ()) {
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
                addTrackHandler(false, NusicError.manageError(statusCode: statusCode, errorCode: NusicErrorCodes.spotifyError, description: SpotifyErrorCodeDescription.addTrack.rawValue))
            }
        })
    }
    
    final func removeTrackFromPlaylist(playlistId: String, tracks: [String: String], removeTrackHandler: @escaping(Bool, NusicError?) -> ()) {
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
                removeTrackHandler(true, NusicError.manageError(statusCode: statusCode, errorCode: NusicErrorCodes.spotifyError, description: SpotifyErrorCodeDescription.removeTrack.rawValue))
            }
        })
    }
    
    final func isTrackInPlaylist(trackId: String, playlistId: String, checkTrackHandler: @escaping (Bool) -> ()) {
        getAllTracksForPlaylist(playlistId: playlistId, fetchGenres: false) { (trackList, error) in
            if let trackList = trackList {
                let containsTrack = trackList.contains(where: { (playlistTrack) -> Bool in
                    return playlistTrack.trackId == trackId
                })
                checkTrackHandler(containsTrack)
            }
        }
    }
    
}
