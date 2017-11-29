//
//  SpotifyBrowse.swift
//  Newsic
//
//  Created by Miguel Alcantara on 09/10/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

extension Spotify {
    
    func getTrackInfo(for trackList: [String], offset: Int, currentExtractedTrackList: [SpotifyTrack], trackInfoListHandler: @escaping([SpotifyTrack]?) -> ()) {
        if trackList.count <= 0 {
            trackInfoListHandler(nil);
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
            let request = try SPTTrack.createRequest(forTracks: trackUriList, withAccessToken: self.auth.session.accessToken!, market: "US");
            
            let session = URLSession.shared;
            session.dataTask(with: request, completionHandler: { (data, response, error) in
                
                if error != nil {
                    print("error getting genres for artists, error = \(String(describing: error?.localizedDescription))");
                    
                } else {
                    let httpResponse = response as! HTTPURLResponse
                    if httpResponse.statusCode == ErrorCodes.tooManyRequests.rawValue {
                        let retryTimer = Double(httpResponse.allHeaderFields["retry-after"] as! String);
                        let dispatchTime = DispatchTime.now();
                        
                        DispatchQueue.main.asyncAfter(deadline: dispatchTime+retryTimer!, execute: {
                            self.getTrackInfo(for: trackList, offset: offset, currentExtractedTrackList: currentExtractedTrackList, trackInfoListHandler: { (trackList) in
                                
                            })
                        })
                    } else if httpResponse.statusCode == ErrorCodes.okResponse.rawValue {
                        let jsonObject = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject];
                        let extractedTrackList = jsonObject["tracks"] as! [[String:AnyObject]];
                        for track in extractedTrackList {
                            //let trackInfo = artist["track"] as! [String: AnyObject]
                            
                            let artistInfo = track["artists"] as! [[String: AnyObject]]
                            let albumInfo = track["album"] as! [String: AnyObject]
                            let imageInfo = albumInfo["images"] as! [[String: AnyObject]]
                            /*
                             let addedAt = artist["added_at"] as! String
                             let dateFormatter = DateFormatter();
                             dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                             let dateAdded = dateFormatter.date(from: addedAt)
                             */
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
//                            print(artists)
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
                            self.getTrackInfo(for: trackList, offset: nextOffset, currentExtractedTrackList: currentExtractedTrackList, trackInfoListHandler: { (trackList) in
                                trackInfoListHandler(trackList);
                            })
                        } else {
                            
                            let sortedList = spotifyTrackList.sorted(by: { (track1, track2) -> Bool in
                                track1.addedAt!! > track2.addedAt!!
                            })
                            trackInfoListHandler(sortedList);
                        }
                    }
                }
                
            }).resume()
            
        } catch {
            
        }
        
    }
    
    func getTrackDetails(trackId: String, fetchedTrackDetailsHandler: @escaping (SpotifyTrackFeature?) -> () ) {
        let auth = SPTAuth.defaultInstance();
        do {
            let trackUrl = URL(string: "spotify:track:\(trackId)")!
            var trackFeaturesRequest = try SPTTrack.createRequest(forTrack: trackUrl, withAccessToken: auth?.session.accessToken, market: "US")
            trackFeaturesRequest.url =  URL(string: "https://api.spotify.com/v1/audio-features/\(trackId)")
            
            let session = URLSession.shared;
            
            session.dataTask(with: trackFeaturesRequest, completionHandler: { (data, response, error) in
                if error != nil {
                    print("error getting track features for track \(trackId)");
                    fetchedTrackDetailsHandler(nil);
                } else {
                    let httpResponse = response as! HTTPURLResponse
                    if httpResponse.statusCode == ErrorCodes.tooManyRequests.rawValue {
                        let retryTimer = Double(httpResponse.allHeaderFields["retry-after"] as! String);
                        let dispatchTime = DispatchTime.now();
                        
                        DispatchQueue.main.asyncAfter(deadline: dispatchTime+retryTimer!, execute: {
                            self.getTrackArtist(trackId: trackId, fetchedTrackArtistHandler: { (tracks) in
                                
                            });
                        })
                        
                    } else if httpResponse.statusCode == ErrorCodes.okResponse.rawValue {
                        do {
                            let jsonObject = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
                            //let rootObjectTest = try SPTFollow.followingResult(from: data!, with: response)
                            var spotifyTrackFeature = SpotifyTrackFeature()
                            spotifyTrackFeature.mapDictionary(featureDictionary: jsonObject);
                            fetchedTrackDetailsHandler(spotifyTrackFeature)
                        } catch {
                            print("error parsing track features for track \(trackId)");
                        }
                    }
                    
                }
                
                
                
            }).resume()
        } catch {
            fetchedTrackDetailsHandler(nil);
            print("error creating request for track features for track \(trackId)");
        }
    }
    
    func getTrackArtist(trackId: String, fetchedTrackArtistHandler: @escaping (String?) -> () ) {
        let auth = SPTAuth.defaultInstance();
        do {
            let trackUrl = URL(string: "spotify:track:\(trackId)")!
            let trackRequest = try SPTTrack.createRequest(forTrack: trackUrl, withAccessToken: auth?.session.accessToken, market: "US")
            
            let session = URLSession.shared;
            
            session.dataTask(with: trackRequest, completionHandler: { (data, response, error) in
                if error != nil {
                    print("error getting track features for track \(trackId)");
                    fetchedTrackArtistHandler(nil);
                } else {
                    do {
                        let jsonObject = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
                        //let rootObjectTest = try SPTFollow.followingResult(from: data!, with: response)
                        let firstArtist = jsonObject["artists"] as! [[String: AnyObject]]
                        fetchedTrackArtistHandler(firstArtist.first?["id"] as! String);
                    } catch {
                        print("error parsing track features for track \(trackId)");
                    }
                }
                
                
                
            }).resume()
        } catch {
            fetchedTrackArtistHandler(nil);
            print("error creating request for track features for track \(trackId)");
        }
    }
    
    
    func getAllTracksForPlaylist(playlistId: String, nextTrackPageRequest: URLRequest? = nil, currentTrackList: [SpotifyTrack]? = nil, fetchedPlaylistTracks: @escaping([SpotifyTrack]?) -> ()) {
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
        
        session.dataTask(with: pageRequest!) { (data, response, error) in
            if error != nil {
                print("error getting all artists for playlist")
            } else {
                do {
                    let httpResponse = response as! HTTPURLResponse
                    if httpResponse.statusCode == ErrorCodes.tooManyRequests.rawValue {
                        let retryTimer = Double(httpResponse.allHeaderFields["retry-after"] as! String);
                        let dispatchTime = DispatchTime.now();
                        
                        DispatchQueue.main.asyncAfter(deadline: dispatchTime+retryTimer!, execute: {
                            self.getAllTracksForPlaylist(playlistId: playlistId, nextTrackPageRequest: nextTrackPageRequest, currentTrackList: currentTrackList, fetchedPlaylistTracks: { (currentTrackList) in
                                //fetchedPlaylistTracks(currentArtistList);
                            })
                        })
                        
                    } else if httpResponse.statusCode == ErrorCodes.okResponse.rawValue {
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
                            print(albumImage!)
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
                            self.getAllTracksForPlaylist(playlistId: playlistId, nextTrackPageRequest: nextPageUrlRequest, currentTrackList: currentTrackList, fetchedPlaylistTracks: { (currentTrackList) in
                                fetchedPlaylistTracks(currentList);
                            })
                        } else {
                            
                            let sortedList = currentList.sorted(by: { (track1, track2) -> Bool in
                                track1.addedAt!! > track2.addedAt!!
                            })
                            fetchedPlaylistTracks(sortedList);
                        }
                    }
                    
                } catch {
                    print("error parsing all artists for playlist")
                }
            }
            }.resume()
        
    }
    
    
    func addTracksToPlaylist(playlistId: String, trackId: String, addTrackHandler: @escaping(Bool) -> ()) {
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
            
            session.dataTask(with: createPlaylistRequest, completionHandler: { (data, response, error) in
                if error != nil {
                    print("error adding track \(trackId) to playlist \(playlistId)");
                    addTrackHandler(false);
                } else {
                    let httpResponse = response as! HTTPURLResponse
                    if httpResponse.statusCode == ErrorCodes.tooManyRequests.rawValue {
                        let retryTimer = Double(httpResponse.allHeaderFields["retry-after"] as! String);
                        let dispatchTime = DispatchTime.now();
                        
                        DispatchQueue.main.asyncAfter(deadline: dispatchTime+retryTimer!, execute: {
                            self.addTracksToPlaylist(playlistId: playlistId, trackId: trackId, addTrackHandler: { (isAdded) in
                                
                            })
                        })
                        
                    } else {
                        addTrackHandler(true);
                    }
                    
                }
            }).resume()
        } catch {
            addTrackHandler(false);
            print("error creating request adding track \(trackId) to playlist \(playlistId)");
        }
    }
    
    func removeTrackFromPlaylist(playlistId: String, tracks: [String: String], removeTrackHandler: @escaping(Bool) -> ()) {
        let auth = SPTAuth.defaultInstance();
        do {
            
            let username: String! = auth?.session.canonicalUsername!
            let accessToken: String! = auth?.session.accessToken!
            let url = "https://api.spotify.com/v1/users/\(username!)/playlists/\(playlistId)/tracks"
            var createPlaylistRequest = URLRequest(url: URL(string: url)!);
            createPlaylistRequest.addValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
            createPlaylistRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            createPlaylistRequest.httpMethod = "DELETE";
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
            createPlaylistRequest.httpBody = body.data(using: .utf8)
            
            session.dataTask(with: createPlaylistRequest, completionHandler: { (data, response, error) in
                if error != nil {
                    print("error deleting tracks from playlist \(playlistId)");
                    removeTrackHandler(false);
                } else {
                    let httpResponse = response as! HTTPURLResponse
                    if httpResponse.statusCode == ErrorCodes.tooManyRequests.rawValue {
                        let retryTimer = Double(httpResponse.allHeaderFields["retry-after"] as! String);
                        let dispatchTime = DispatchTime.now();
                        
                        DispatchQueue.main.asyncAfter(deadline: dispatchTime+retryTimer!, execute: {
                            self.removeTrackFromPlaylist(playlistId: playlistId, tracks: tracks, removeTrackHandler: { (didRemove) in
                                
                            })
                        })
                        
                    } else {
                        removeTrackHandler(true);
                    }
                    
                }
            }).resume()
        } catch {
            removeTrackHandler(false);
            print("error creating request deleting track from playlist \(playlistId)");
        }
    }
    
}
