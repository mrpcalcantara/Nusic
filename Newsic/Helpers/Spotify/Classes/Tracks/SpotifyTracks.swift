//
//  SpotifyBrowse.swift
//  Newsic
//
//  Created by Miguel Alcantara on 09/10/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

extension Spotify {
    
    func getTrackInfo(for trackList: [String], offset: Int, currentExtractedTrackList: [SpotifyTrack], trackInfoListHandler: @escaping([SpotifyTrack]?, NewsicError?) -> ()) {
        if trackList.count <= 0 {
            trackInfoListHandler(nil, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.functionalError));
            return;
        }
        var spotifyTrackList: [SpotifyTrack] = currentExtractedTrackList != nil ? currentExtractedTrackList : []
        var currentTrackList:[String] = []
        var hasNext:Bool = true
        let checkLimit = currentExtractedTrackList.count-offset
        
        
        if checkLimit > 50 {
            //currentArtistList = artistList[offset...offset+50]
            currentTrackList = Array(trackList[offset...offset+49]);
        } else {
            hasNext = false;
            currentTrackList = Array(trackList[offset...trackList.count-1])
        }
        
        let nextOffset = offset+50
        
        var trackUriList: [URL] = []
        
        for trackURI in currentTrackList {
            trackUriList.append(URL(string: Spotify.transformToURI(trackId: trackURI))!)
        }
        
        do {
            let request = try SPTTrack.createRequest(forTracks: trackUriList, withAccessToken: self.auth.session.accessToken!, market: self.user.territory);
            
            let session = URLSession.shared;
            
            session.executeCall(with: request) { (data, httpResponse, error, isSuccess) in
                let statusCode:Int! = httpResponse?.statusCode
                if isSuccess {
                    let jsonObject = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject];
                    let extractedTrackList = jsonObject["tracks"] as! [[String:AnyObject]];
                    for track in extractedTrackList {
                        //let trackInfo = artist["track"] as! [String: AnyObject]
                        
                        let artistInfo = track["artists"] as! [[String: AnyObject]]
                        let albumInfo = track["album"] as! [String: AnyObject]
                        let imageInfo = albumInfo["images"] as! [[String: AnyObject]]
                        var artists = ""
                        let index = 0
                        let artistCount = artistInfo.count
                        for artist in artistInfo {
                            if let artistName = artist["name"] as? String {
                                artists += "\(artistName)"
                                if index <= artistCount - 1 {
                                    artists += ", ";
                                }
                            }
                        }
                        artists.removeLast(); artists.removeLast();
                        let albumImage = imageInfo[0]["url"] as? String;
                        if let trackName = track["name"] as? String,
                            let trackId = track["id"] as? String,
                            let trackUri = track["uri"] as? String,
                            let albumImage = albumImage {
                            let track = SpotifyTrack(title: trackName, thumbNailUrl: albumImage, trackUri: trackUri, trackId: trackId, songName: trackName, artist: SpotifyArtist(artistName: artists), audioFeatures: nil);
                            spotifyTrackList.append(track);
                        }
                    }
                    
                    let nextPage = jsonObject["next"] as? String
                    if let nextPage = nextPage {
                        let nextPageUrl = URL(string: nextPage)
                        let nextPageUrlRequest = URLRequest(url: nextPageUrl!)
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
                        trackInfoListHandler(nil, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.clientError))
                    case 500...599:
                        trackInfoListHandler(nil, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.serverError))
                    default: return;
                    }
                }
            }
        } catch { }
    }
//
//            session.dataTask(with: request, completionHandler: { (data, response, error) in
//
//                if error != nil {
//                    print("error getting genres for artists, error = \(String(describing: error?.localizedDescription))");
//
//                } else {
//                    let httpResponse = response as! HTTPURLResponse
//                    let statusCode = httpResponse.statusCode
//                    switch statusCode {
//                        case 200...299:
//                            let jsonObject = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject];
//                            let extractedTrackList = jsonObject["tracks"] as! [[String:AnyObject]];
//                            for track in extractedTrackList {
//                                //let trackInfo = artist["track"] as! [String: AnyObject]
//
//                                let artistInfo = track["artists"] as! [[String: AnyObject]]
//                                let albumInfo = track["album"] as! [String: AnyObject]
//                                let imageInfo = albumInfo["images"] as! [[String: AnyObject]]
//                                var artists = ""
//                                let index = 0
//                                let artistCount = artistInfo.count
//                                for artist in artistInfo {
//                                    if let artistName = artist["name"] as? String {
//                                        artists += "\(artistName)"
//                                        if index <= artistCount - 1 {
//                                            artists += ", ";
//                                        }
//                                    }
//                                }
//                                artists.removeLast(); artists.removeLast();
//                                let albumImage = imageInfo[0]["url"] as? String;
//                                if let trackName = track["name"] as? String,
//                                    let trackId = track["id"] as? String,
//                                    let trackUri = track["uri"] as? String,
//                                    let albumImage = albumImage {
//                                    let track = SpotifyTrack(title: trackName, thumbNailUrl: albumImage, trackUri: trackUri, trackId: trackId, songName: trackName, artist: SpotifyArtist(artistName: artists), audioFeatures: nil);
//                                    spotifyTrackList.append(track);
//                                }
//                            }
//
//                            let nextPage = jsonObject["next"] as? String
//                            if let nextPage = nextPage {
//                                let nextPageUrl = URL(string: nextPage)
//                                let nextPageUrlRequest = URLRequest(url: nextPageUrl!)
//                                self.getTrackInfo(for: trackList, offset: nextOffset, currentExtractedTrackList: currentExtractedTrackList, trackInfoListHandler: { (trackList, error) in
//                                    trackInfoListHandler(trackList, nil);
//                                })
//                            } else {
//
//                                let sortedList = spotifyTrackList.sorted(by: { (track1, track2) -> Bool in
//                                    track1.addedAt!! > track2.addedAt!!
//                                })
//                                trackInfoListHandler(sortedList, nil);
//                            }
//                        case 400...499:
//                            if statusCode == HTTPErrorCodes.tooManyRequests.rawValue {
//                                let retryTimer = Double(httpResponse.allHeaderFields["retry-after"] as! String);
//                                let dispatchTime = DispatchTime.now();
//
//                                DispatchQueue.main.asyncAfter(deadline: dispatchTime+retryTimer!, execute: {
//                                    self.getTrackInfo(for: trackList, offset: offset, currentExtractedTrackList: currentExtractedTrackList, trackInfoListHandler: { (trackList, error) in
//
//                                    })
//                                })
//                            } else {
//                                trackInfoListHandler(nil, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, spotifyErrorCode: SpotifyErrorCodes.clientError))
//                            }
//                        case 500...599:
//                            trackInfoListHandler(nil, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, spotifyErrorCode: SpotifyErrorCodes.serverError))
//                        default: return;
//                    }
//                }
//
//            }).resume()
//
//        } catch {
//
//        }
        
//    }
    
    func getTrackDetails(trackId: String, fetchedTrackDetailsHandler: @escaping (SpotifyTrackFeature?, NewsicError?) -> () ) {
        let auth = SPTAuth.defaultInstance();
        do {
            let trackUrl = URL(string: "spotify:track:\(trackId)")!
            var trackFeaturesRequest = try SPTTrack.createRequest(forTrack: trackUrl, withAccessToken: auth?.session.accessToken, market: self.user.territory)
            trackFeaturesRequest.url =  URL(string: "https://api.spotify.com/v1/audio-features/\(trackId)")
            
            let session = URLSession.shared;
            
            session.executeCall(with: trackFeaturesRequest) { (data, httpResponse, error, isSuccess) in
                let statusCode:Int! = httpResponse?.statusCode
                if isSuccess {
                    do {
                        let jsonObject = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
                        //let rootObjectTest = try SPTFollow.followingResult(from: data!, with: response)
                        var spotifyTrackFeature = SpotifyTrackFeature()
                        spotifyTrackFeature.mapDictionary(featureDictionary: jsonObject);
                        fetchedTrackDetailsHandler(spotifyTrackFeature, nil)
                    } catch {
                        print("error parsing track features for track \(trackId)");
                    }
                } else {
                    switch statusCode {
                    case 400...499:
                        fetchedTrackDetailsHandler(nil, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.clientError))
                    case 500...599:
                        fetchedTrackDetailsHandler(nil, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.serverError))
                    default: return;
                    }
                }
            }
            
//            session.dataTask(with: trackFeaturesRequest, completionHandler: { (data, response, error) in
//                if error != nil {
//                    print("error getting track features for track \(trackId)");
//                    fetchedTrackDetailsHandler(nil, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, spotifyErrorCode: SpotifyErrorCodes.technicalError));
//                } else {
//                    let httpResponse = response as! HTTPURLResponse
//                    let statusCode = httpResponse.statusCode
//                    switch statusCode {
//                    case 200...299:
//
//                    case 400...499:
//                        if statusCode == HTTPErrorCodes.tooManyRequests.rawValue {
//                            let retryTimer = Double(httpResponse.allHeaderFields["retry-after"] as! String);
//                            let dispatchTime = DispatchTime.now();
//
//                            DispatchQueue.main.asyncAfter(deadline: dispatchTime+retryTimer!, execute: {
//                                self.getTrackDetails(trackId: trackId, fetchedTrackDetailsHandler: { (spotifyTrackFeature, error) in
//
//                                })
//                            })
//
//                        } else {
//                            fetchedTrackDetailsHandler(nil, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, spotifyErrorCode: SpotifyErrorCodes.clientError))
//                        }
//                    case 500...599:
//                        fetchedTrackDetailsHandler(nil, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, spotifyErrorCode: SpotifyErrorCodes.serverError))
//                    default: return;
//                    }
//                }
//            }).resume()
        } catch {
            fetchedTrackDetailsHandler(nil, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.technicalError));
            print("error creating request for track features for track \(trackId)");
        }
    }
    
    func getTrackArtist(trackId: String, fetchedTrackArtistHandler: @escaping (String?, NewsicError?) -> () ) {
        let auth = SPTAuth.defaultInstance();
        do {
            let trackUrl = URL(string: "spotify:track:\(trackId)")!
            let trackRequest = try SPTTrack.createRequest(forTrack: trackUrl, withAccessToken: auth?.session.accessToken, market: self.user.territory)
            
            let session = URLSession.shared;
            
            session.executeCall(with: trackRequest) { (data, httpResponse, error, isSuccess) in
                let statusCode:Int! = httpResponse?.statusCode
                if isSuccess {
                    do {
                        let jsonObject = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
                        //let rootObjectTest = try SPTFollow.followingResult(from: data!, with: response)
                        let firstArtist = jsonObject["artists"] as! [[String: AnyObject]]
                        fetchedTrackArtistHandler(firstArtist.first?["id"] as! String, nil);
                    } catch {
                        
                    }
                    
                } else {
                    switch statusCode {
                    case 400...499:
                        fetchedTrackArtistHandler(nil, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.clientError));
                    case 500...599:
                        fetchedTrackArtistHandler(nil, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.serverError));
                    default: return;
                    }
                }
            }
            
//            session.dataTask(with: trackRequest, completionHandler: { (data, response, error) in
//                if error != nil {
//                    print("error getting track features for track \(trackId)");
//                    fetchedTrackArtistHandler(nil, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, spotifyErrorCode: SpotifyErrorCodes.technicalError));
//                } else {
//                    do {
//                        let httpResponse = response as! HTTPURLResponse
//                        let statusCode = httpResponse.statusCode
//                        switch statusCode {
//                        case 200...299:
//
//                        case 400...499:
//                            if statusCode == HTTPErrorCodes.tooManyRequests.rawValue {
//                                let retryTimer = Double(httpResponse.allHeaderFields["retry-after"] as! String);
//                                let dispatchTime = DispatchTime.now();
//
//                                DispatchQueue.main.asyncAfter(deadline: dispatchTime+retryTimer!, execute: {
//                                    self.getTrackArtist(trackId: trackId, fetchedTrackArtistHandler: { (artistId, error) in
//
//                                    })
//
//                                })
//
//                            } else {
//                                fetchedTrackArtistHandler(nil, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, spotifyErrorCode: SpotifyErrorCodes.clientError));
//                            }
//                        case 500...599:
//                            fetchedTrackArtistHandler(nil, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, spotifyErrorCode: SpotifyErrorCodes.serverError));
//                        default: return;
//                        }
//
//
//                    } catch {
//                        print("error parsing track features for track \(trackId)");
//                    }
//                }
//
//
//
//            }).resume()
        } catch {
            fetchedTrackArtistHandler(nil, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.technicalError));
            print("error creating request for track features for track \(trackId)");
        }
    }
    
    
    func getAllTracksForPlaylist(playlistId: String, nextTrackPageRequest: URLRequest? = nil, currentTrackList: [SpotifyTrack]? = nil, fetchedPlaylistTracks: @escaping([SpotifyTrack]?, NewsicError?) -> ()) {
        let userId = SPTAuth.defaultInstance().session.canonicalUsername;
        var currentList: [SpotifyTrack] = currentTrackList != nil ? currentTrackList! : [];
        var pageRequest = nextTrackPageRequest;
        if pageRequest == nil {
            let url = "https://api.spotify.com/v1/users/\(userId!)/playlists/\(playlistId)/tracks?fields=next,items(added_at,track(id,uri,name,artists(name),album(images(url))))"
            pageRequest = URLRequest(url: URL(string: url)!);
            //print(pageRequest)
        }
        
        pageRequest?.addValue("Bearer \(self.auth.session.accessToken!)", forHTTPHeaderField: "Authorization")
        let session = URLSession.shared;
        
        session.executeCall(with: pageRequest!) { (data, httpResponse, error, isSuccess) in
            let statusCode:Int! = httpResponse?.statusCode
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
                        let index = 0
                        let artistCount = artistInfo.count
                        for artist in artistInfo {
                            if let artistName = artist["name"] as? String {
                                artists += "\(artistName)"
                                if index <= artistCount - 1 {
                                    artists += ", ";
                                }
                            }
                        }
                        
                        artists.removeLast(); artists.removeLast();
                        //print(artists)
                        let albumImage = imageInfo[0]["url"] as? String;
                        if let trackName = trackInfo["name"] as? String,
                            let trackId = trackInfo["id"] as? String,
                            let trackUri = trackInfo["uri"] as? String,
                            let albumImage = albumImage {
                            let track = SpotifyTrack(title: trackName, thumbNailUrl: albumImage, trackUri: trackUri, trackId: trackId, songName: trackName, artist: SpotifyArtist(artistName: artists), addedAt: dateAdded, audioFeatures: nil);
                            currentList.append(track);
                        }
                    }
                    
                    let nextPage = jsonObject["next"] as? String
                    if let nextPage = nextPage {
                        let nextPageUrl = URL(string: nextPage)
                        let nextPageUrlRequest = URLRequest(url: nextPageUrl!)
                        self.getAllTracksForPlaylist(playlistId: playlistId, nextTrackPageRequest: nextPageUrlRequest, currentTrackList: currentTrackList, fetchedPlaylistTracks: { (currentTrackList, error) in
                            fetchedPlaylistTracks(currentList, error);
                        })
                    } else {
                        
                        let sortedList = currentList.sorted(by: { (track1, track2) -> Bool in
                            track1.addedAt!! > track2.addedAt!!
                        })
                        fetchedPlaylistTracks(sortedList, nil);
                    }
                } catch { }
                
            } else {
                switch statusCode {
                case 400...499:
                    fetchedPlaylistTracks(nil, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.clientError))
                case 500...599:
                    fetchedPlaylistTracks(nil, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.serverError))
                default: return;
                }
            }
        }
        
        
//        session.dataTask(with: pageRequest!) { (data, response, error) in
//            if error != nil {
//                print("error getting all artists for playlist")
//                fetchedPlaylistTracks(nil, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, spotifyErrorCode: SpotifyErrorCodes.technicalError))
//            } else {
//                do {
//                    let httpResponse = response as! HTTPURLResponse
//                    let statusCode = httpResponse.statusCode
//                    switch statusCode {
//                        case 200...299:
//                            let jsonObject = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject];
//                            let artistList = jsonObject["items"] as! [[String:AnyObject]];
//                            for artist in artistList {
//                                let trackInfo = artist["track"] as! [String: AnyObject]
//                                let artistInfo = trackInfo["artists"] as! [[String: AnyObject]]
//                                let albumInfo = trackInfo["album"] as! [String: AnyObject]
//                                let imageInfo = albumInfo["images"] as! [[String: AnyObject]]
//                                let addedAt = artist["added_at"] as! String
//
//                                let dateFormatter = DateFormatter();
//                                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
//
//                                let dateAdded = dateFormatter.date(from: addedAt)
//
//                                var artists = ""
//                                let index = 0
//                                let artistCount = artistInfo.count
//                                for artist in artistInfo {
//                                    if let artistName = artist["name"] as? String {
//                                        artists += "\(artistName)"
//                                        if index <= artistCount - 1 {
//                                            artists += ", ";
//                                        }
//                                    }
//                                }
//
//                                artists.removeLast(); artists.removeLast();
//                                //print(artists)
//                                let albumImage = imageInfo[0]["url"] as? String;
//                                if let trackName = trackInfo["name"] as? String,
//                                    let trackId = trackInfo["id"] as? String,
//                                    let trackUri = trackInfo["uri"] as? String,
//                                    let albumImage = albumImage {
//                                    let track = SpotifyTrack(title: trackName, thumbNailUrl: albumImage, trackUri: trackUri, trackId: trackId, songName: trackName, artist: SpotifyArtist(artistName: artists), addedAt: dateAdded, audioFeatures: nil);
//                                    currentList.append(track);
//                                }
//                            }
//
//                            let nextPage = jsonObject["next"] as? String
//                            if let nextPage = nextPage {
//                                let nextPageUrl = URL(string: nextPage)
//                                let nextPageUrlRequest = URLRequest(url: nextPageUrl!)
//                                self.getAllTracksForPlaylist(playlistId: playlistId, nextTrackPageRequest: nextPageUrlRequest, currentTrackList: currentTrackList, fetchedPlaylistTracks: { (currentTrackList, error) in
//                                    fetchedPlaylistTracks(currentList, error);
//                                })
//                            } else {
//
//                                let sortedList = currentList.sorted(by: { (track1, track2) -> Bool in
//                                    track1.addedAt!! > track2.addedAt!!
//                                })
//                                fetchedPlaylistTracks(sortedList, nil);
//                            }
//                        case 400...499:
//                            if httpResponse.statusCode == HTTPErrorCodes.tooManyRequests.rawValue {
//                                let retryTimer = Double(httpResponse.allHeaderFields["retry-after"] as! String);
//                                let dispatchTime = DispatchTime.now();
//
//                                DispatchQueue.main.asyncAfter(deadline: dispatchTime+retryTimer!, execute: {
//                                    self.getAllTracksForPlaylist(playlistId: playlistId, nextTrackPageRequest: nextTrackPageRequest, currentTrackList: currentTrackList, fetchedPlaylistTracks: { (currentTrackList, error) in
//                                    })
//                                })
//
//                            } else {
//                                fetchedPlaylistTracks(nil, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, spotifyErrorCode: SpotifyErrorCodes.clientError))
//                            }
//                        case 500...599:
//                            fetchedPlaylistTracks(nil, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, spotifyErrorCode: SpotifyErrorCodes.serverError))
//                        default: return;
//                    }
//                } catch {
//                    print("error parsing all artists for playlist")
//                }
//            }
//            }.resume()
        
    }
    
    
    func addTracksToPlaylist(playlistId: String, trackId: String, addTrackHandler: @escaping(Bool, NewsicError?) -> ()) {
        let auth = SPTAuth.defaultInstance();
        do {
            let username: String! = auth?.session.canonicalUsername!
            let accessToken: String! = auth?.session.accessToken!
            let url = "https://api.spotify.com/v1/users/\(username!)/playlists/\(playlistId)/tracks?uris=\(trackId)"
            var createPlaylistRequest = URLRequest(url: URL(string: url)!);
            createPlaylistRequest.addValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
            createPlaylistRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            createPlaylistRequest.httpMethod = "POST";
            let session = URLSession.shared;
            
            session.executeCall(with: createPlaylistRequest) { (data, httpResponse, error, isSuccess) in
                let statusCode:Int! = httpResponse?.statusCode
                if isSuccess {
                    addTrackHandler(true, nil);
                } else {
                    switch statusCode {
                    case 400...499:
                        addTrackHandler(false, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.clientError))
                    case 500...599:
                        addTrackHandler(false, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.serverError))
                    default: return;
                    }
                }
            }
//
//            session.dataTask(with: createPlaylistRequest, completionHandler: { (data, response, error) in
//                if error != nil {
//                    print("error adding track \(trackId) to playlist \(playlistId)");
//                    addTrackHandler(false, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, spotifyErrorCode: SpotifyErrorCodes.technicalError));
//                } else {
//                    let httpResponse = response as! HTTPURLResponse
//                    let statusCode = httpResponse.statusCode
//                    switch statusCode {
//                        case 200...299:
//                            addTrackHandler(true, nil);
//                        case 400...499:
//                            if httpResponse.statusCode == HTTPErrorCodes.tooManyRequests.rawValue {
//                                let retryTimer = Double(httpResponse.allHeaderFields["retry-after"] as! String);
//                                let dispatchTime = DispatchTime.now();
//
//                                DispatchQueue.main.asyncAfter(deadline: dispatchTime+retryTimer!, execute: {
//                                    self.addTracksToPlaylist(playlistId: playlistId, trackId: trackId, addTrackHandler: { (isAdded, error) in
//
//                                    })
//                                })
//
//                            } else {
//                                addTrackHandler(false, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, spotifyErrorCode: SpotifyErrorCodes.clientError))
//                            }
//                        case 500...599:
//                            addTrackHandler(false, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, spotifyErrorCode: SpotifyErrorCodes.serverError))
//                        default: return;
//                    }
//
//
//                }
//            }).resume()
        } catch {
            addTrackHandler(false, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.technicalError));
            print("error creating request adding track \(trackId) to playlist \(playlistId)");
        }
    }
    
    func removeTrackFromPlaylist(playlistId: String, tracks: [String: String], removeTrackHandler: @escaping(Bool, NewsicError?) -> ()) {
        let auth = SPTAuth.defaultInstance();
        do {
            
            let username: String! = auth?.session.canonicalUsername!
            let accessToken: String! = auth?.session.accessToken!
            let url = "https://api.spotify.com/v1/users/\(username!)/playlists/\(playlistId)/tracks"
            var removeTrackRequest = URLRequest(url: URL(string: url)!);
            removeTrackRequest.addValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
            removeTrackRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            removeTrackRequest.httpMethod = "DELETE";
            let session = URLSession.shared;
            
            var iterator = tracks.makeIterator();
            var element = iterator.next()
            var tracksToRemove = ""
            
            while element != nil {
                if let element = element {
                    tracksToRemove += "{\"positions\":[\(element.key)],\"uri\":\"\(element.value)\"},"
                    
                }
                element = iterator.next();
            }
            tracksToRemove.removeLast()
            
            let body = "{\"tracks\":[\(tracksToRemove)]}";
            removeTrackRequest.httpBody = body.data(using: .utf8)
            
            session.executeCall(with: removeTrackRequest) { (data, httpResponse, error, isSuccess) in
                let statusCode:Int! = httpResponse?.statusCode
                if isSuccess {
                    removeTrackHandler(true, nil);
                } else {
                    switch statusCode {
                    case 400...499:
                        removeTrackHandler(true, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.clientError));
                    case 500...599:
                        removeTrackHandler(true, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.serverError));
                    default: return;
                    }
                }
            }
//            
//            session.dataTask(with: createPlaylistRequest, completionHandler: { (data, response, error) in
//                if error != nil {
//                    print("error deleting tracks from playlist \(playlistId)");
//                    removeTrackHandler(false, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, spotifyErrorCode: SpotifyErrorCodes.technicalError));
//                } else {
//                    let httpResponse = response as! HTTPURLResponse
//                    let statusCode = httpResponse.statusCode
//                    switch statusCode {
//                    case 200...299:
//                        removeTrackHandler(true, nil);
//                    case 400...499:
//                        if statusCode == HTTPErrorCodes.tooManyRequests.rawValue {
//                            let retryTimer = Double(httpResponse.allHeaderFields["retry-after"] as! String);
//                            let dispatchTime = DispatchTime.now();
//                            
//                            DispatchQueue.main.asyncAfter(deadline: dispatchTime+retryTimer!, execute: {
//                                self.removeTrackFromPlaylist(playlistId: playlistId, tracks: tracks, removeTrackHandler: { (didRemove, error) in
//                                    
//                                })
//                            })
//                            
//                        } else {
//                            removeTrackHandler(true, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, spotifyErrorCode: SpotifyErrorCodes.clientError));
//                        }
//                    case 500...599:
//                        removeTrackHandler(true, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, spotifyErrorCode: SpotifyErrorCodes.serverError));
//                    default: return;
//                    }
//
//                }
//            }).resume()
        } catch {
            removeTrackHandler(false, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.technicalError));
            print("error creating request deleting track from playlist \(playlistId)");
        }
    }
    
}
