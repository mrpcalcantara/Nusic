//
//  SpotifyBrowse.swift
//  Nusic
//
//  Created by Miguel Alcantara on 09/10/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

extension Spotify {
    
    final func getFollowedArtistsForUser(user: SPTUser, artistList:[SpotifyArtist]? = nil, searchFollowedUrl: String? = nil, followedArtistsHandler: @escaping([SpotifyArtist], NusicError?) -> ()) {
        do {
            var currentArtistList: [SpotifyArtist] = artistList == nil ? [] : artistList!
            
            var followedArtistsRequest = try SPTFollow.createRequestForCheckingIf(followingArtists: [], withAccessToken: auth.session.accessToken!)
            
            if let searchFollowedUrl = searchFollowedUrl {
                followedArtistsRequest.url = URL(string: searchFollowedUrl);
            } else {
                followedArtistsRequest.url = URL(string: "https://api.spotify.com/v1/me/following?type=artist&limit=50");
            }
            

            executeSpotifyCall(with: followedArtistsRequest, spotifyCallCompletionHandler: { (data, httpResponse, error, isSuccess) in
                let statusCode:Int! = httpResponse != nil ? httpResponse?.statusCode : -1
                guard isSuccess else {
                    followedArtistsHandler([], NusicError.manageError(statusCode: statusCode, errorCode: NusicErrorCodes.spotifyError, description: SpotifyErrorCodeDescription.extractGenresFromUser.rawValue))
                    return;
                }
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
                    let rootElement = jsonObject["artists"] as! [String: AnyObject];
                    let items = rootElement["items"] as! [[String: AnyObject]];
                    for artist in items {
                        
                        if let artistData = try? JSONSerialization.data(withJSONObject: artist, options: JSONSerialization.WritingOptions.prettyPrinted), let decodedArtist = try? JSONDecoder().decode(SpotifyArtist.self, from: artistData) {
                            currentArtistList.append(decodedArtist);
                        }
                    }
                    
                    if let next = rootElement["next"] as? String {
                        self.getFollowedArtistsForUser(user: user, artistList: currentArtistList, searchFollowedUrl: next, followedArtistsHandler: { (fullArtistsList, nil) in
                            followedArtistsHandler(fullArtistsList, nil);
                        })
                    } else {
                        followedArtistsHandler(currentArtistList, nil);
                    }
                } catch {
                    print("error parsing data in followed artists");
                }
            })
        } catch {
            print("error creating request for followed artists");
        }
        
    }
    
    final func getAllArtistsForPlaylist(userId: String, playlistId: String, nextTrackPageRequest: URLRequest? = nil, currentArtistList: [String]? = nil, fetchedPlaylistArtists: @escaping([String], NusicError?) -> ()) {
        
        var currentList: [String] = currentArtistList != nil ? currentArtistList! : [];
        var pageRequest = nextTrackPageRequest;
        if pageRequest == nil {
            let url = "https://api.spotify.com/v1/users/\(userId)/playlists/\(playlistId)/tracks?fields=next,items(track(artists(uri)))"
            pageRequest = URLRequest(url: URL(string: url)!);
        }
        
        pageRequest?.addValue("Bearer \(self.auth.session.accessToken!)", forHTTPHeaderField: "Authorization")
        
        guard let currentPageRequest = pageRequest else { return; }
        executeSpotifyCall(with: currentPageRequest, spotifyCallCompletionHandler: { (data, httpResponse, error, isSuccess) in
            let statusCode:Int! = httpResponse != nil ? httpResponse?.statusCode : -1
            guard isSuccess else {
                fetchedPlaylistArtists([], NusicError.manageError(statusCode: statusCode, errorCode: NusicErrorCodes.spotifyError, description: SpotifyErrorCodeDescription.getPlaylistTracks.rawValue))
                return;
            }
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject];
                let artistList = jsonObject["items"] as! [[String:AnyObject]];
                for artist in artistList {
                    let trackInfo = artist["track"] as! [String: AnyObject]
                    let artistInfo = trackInfo["artists"] as! [[String: AnyObject]]
                    for artist in artistInfo {
                        if let artistId = artist["uri"] as? String, !currentList.contains(artistId) && !artistId.contains(":local:::") {
                            currentList.append(artistId)
                        }
                    }
                }
                guard let nextPage = jsonObject["next"] as? String,
                    let nextPageUrl = URL(string: nextPage) else { fetchedPlaylistArtists(currentList, nil); return; }
                let nextPageUrlRequest = URLRequest(url: nextPageUrl)
                self.getAllArtistsForPlaylist(userId: userId, playlistId: playlistId, nextTrackPageRequest: nextPageUrlRequest, currentArtistList: currentList, fetchedPlaylistArtists: { (currentArtistList, nil) in
                    fetchedPlaylistArtists(currentArtistList, nil)
                })
            } catch { }
        })
    }
    
    final func getAllGenresForArtists(_ artistList: [String], offset: Int, currentFollowedArtistList: [SpotifyArtist]? = nil, artistGenresHandler: @escaping([SpotifyArtist]?, NusicError?) -> ()) {
        guard artistList.count > 0 else { artistGenresHandler(nil, nil); return; }
        var spotifyFollowedArtistList: [SpotifyArtist] = currentFollowedArtistList != nil ? currentFollowedArtistList! : []
        var currentArtistList:[String] = []
        let checkLimit = artistList.count-offset
        var hasNext:Bool = checkLimit > 50 ? true : false
        let nextOffset = offset+50
        
        currentArtistList = checkLimit > 50 ? Array(artistList[offset...offset+49]) : Array(artistList[offset...artistList.count-1])
        
        var artistUriList: [URL] = []
        for artistURI in currentArtistList {
            artistUriList.append(URL(string: artistURI)!)
        }
        
        do {
            let request = try SPTArtist.createRequest(forArtists: artistUriList, withAccessToken: self.auth.session.accessToken!)
            executeSpotifyCall(with: request, spotifyCallCompletionHandler: { (data, httpResponse, error, isSuccess) in
                let statusCode:Int! = httpResponse != nil ? httpResponse?.statusCode : -1
                guard isSuccess else { artistGenresHandler([], NusicError.manageError(statusCode: statusCode, errorCode: NusicErrorCodes.spotifyError, description: SpotifyErrorCodeDescription.getTrackInfo.rawValue)); return; }
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
                    guard error == nil else { artistGenresHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.spotifyError, nusicErrorSubCode: NusicErrorSubCode.functionalError)); return; }
                    let items =  jsonObject["artists"] as! [[String: AnyObject]];
                    
                    for artist in items {
                        if let artistData = try? JSONSerialization.data(withJSONObject: artist, options: JSONSerialization.WritingOptions.prettyPrinted),
                            let decodedArtist = try? JSONDecoder().decode(SpotifyArtist.self, from: artistData) {
                            spotifyFollowedArtistList.append(decodedArtist);
                        }
                    }
                    guard hasNext else { artistGenresHandler(spotifyFollowedArtistList, nil); return; }
                    self.getAllGenresForArtists(artistList, offset: nextOffset, currentFollowedArtistList: spotifyFollowedArtistList, artistGenresHandler: { (spotifyArtistList, nil) in
                        artistGenresHandler(spotifyArtistList, nil)
                    })
                } catch {
                    print("error parsing data in followed artists");
                }
            })
            
        } catch {
            
        }
        
    }
    
    final func getGenresForArtist(artistId: String, fetchedArtistGenresHandler: @escaping ([String]?, NusicError?) -> () ) {
        do {
            let trackUrl = URL(string: "spotify:artist:\(artistId)")!
            let artistGenresRequest = try SPTArtist.createRequest(forArtist: trackUrl, withAccessToken: auth.session.accessToken!);
            executeSpotifyCall(with: artistGenresRequest, spotifyCallCompletionHandler: { (data, httpResponse, error, isSuccess) in
                let statusCode:Int! = httpResponse != nil ? httpResponse?.statusCode : -1
                guard isSuccess else {
                    fetchedArtistGenresHandler([], NusicError.manageError(statusCode: statusCode, errorCode: NusicErrorCodes.spotifyError, description: SpotifyErrorCodeDescription.getTrackInfo.rawValue))
                    return;
                }
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
                    let genres = jsonObject["genres"] as! [String]
                    fetchedArtistGenresHandler(genres, nil);
                } catch {
                    print("error parsing artist genres for artist \(artistId)");
                }
            })
        } catch { fetchedArtistGenresHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.spotifyError, nusicErrorSubCode: NusicErrorSubCode.technicalError));
                        print("error creating request for artist genres for artist \(artistId)");
            
        }
    }
 
    final func getArtistInfo(for artistId: String, fetchedArtistInfoHandler: @escaping (SpotifyArtist?, NusicError?) -> () ) {
        do {
            let trackUrl = URL(string: "spotify:artist:\(artistId)")!
            let artistGenresRequest = try SPTArtist.createRequest(forArtist: trackUrl, withAccessToken: auth.session.accessToken!);
            executeSpotifyCall(with: artistGenresRequest, spotifyCallCompletionHandler: { (data, httpResponse, error, isSuccess) in
                let statusCode:Int! = httpResponse != nil ? httpResponse?.statusCode : -1
                guard isSuccess else {
                    fetchedArtistInfoHandler(nil, NusicError.manageError(statusCode: statusCode, errorCode: NusicErrorCodes.spotifyError, description: SpotifyErrorCodeDescription.getArtistInfo.rawValue))
                    return;
                }
                do {
                    let artist = try JSONDecoder().decode(SpotifyArtist.self, from: data!)
                    fetchedArtistInfoHandler(artist, nil);
                } catch {
                    print("error parsing artist genres for artist \(artistId)");
                }
            })
        } catch { fetchedArtistInfoHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.spotifyError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: SpotifyErrorCodeDescription.getArtistInfo.rawValue));
            print("error creating request for artist genres for artist \(artistId)");
            
        }
    }

    final func getArtistTopTracks(for artistId: String, fetchedArtistTopTracks: @escaping([SpotifyTrack]?, NusicError?) -> () ) {
        do {
            guard let artistIdUrl = URL(string: Spotify.transformToURI(type: .artist, id: artistId)) else { return; }
            let request = try SPTArtist.createRequestForTopTracks(forArtist: artistIdUrl, withAccessToken: auth.session.accessToken, market: user.territory)
            
            executeSpotifyCall(with: request, spotifyCallCompletionHandler: { (data, httpResponse, error, isSuccess) in
                let statusCode:Int! = httpResponse != nil ? httpResponse?.statusCode : -1
                guard isSuccess else {
                    fetchedArtistTopTracks(nil, NusicError.manageError(statusCode: statusCode, errorCode: .spotifyError, description: SpotifyErrorCodeDescription.getArtistTopTracks.rawValue))
                    return;
                }
                var spotifyTrackList = [SpotifyTrack]()
                if let jsonObject = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: AnyObject],
                    let extractedTrackList = jsonObject["tracks"] as? [[String:AnyObject]] {
                    for track in extractedTrackList {
                        if let trackData = try? JSONSerialization.data(withJSONObject: track, options: JSONSerialization.WritingOptions.prettyPrinted), let decodedTrack = try? JSONDecoder().decode(SpotifyTrack.self, from: trackData) {
                            spotifyTrackList.append(decodedTrack);
                        }
                    }
                }
                fetchedArtistTopTracks(spotifyTrackList, nil)
                
            })
        } catch {
            
        }
        
    }
}
