//
//  SpotifyBrowse.swift
//  Newsic
//
//  Created by Miguel Alcantara on 09/10/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

extension Spotify {
    
    func getFollowedArtistsForUser(user: SPTUser, artistList:[SpotifyArtist]? = nil, searchFollowedUrl: String? = nil, followedArtistsHandler: @escaping([SpotifyArtist]) -> ()) {
        let auth = SPTAuth.defaultInstance();
        do {
            var currentArtistList: [SpotifyArtist] = artistList == nil ? [] : artistList!
            
            var followedArtistsRequest = try SPTFollow.createRequestForCheckingIf(followingArtists: [], withAccessToken: auth?.session.accessToken)
            
            if let searchFollowedUrl = searchFollowedUrl {
                followedArtistsRequest.url = URL(string: searchFollowedUrl);
            } else {
                followedArtistsRequest.url = URL(string: "https://api.spotify.com/v1/me/following?type=artist&limit=50");
            }
            
            let session = URLSession.shared;
            
            session.dataTask(with: followedArtistsRequest, completionHandler: { (data, response, error) in
                if error != nil {
                    print("error getting followed artists");
                    //followedArtistsHandler("error getting followed artists");
                } else {
                    let httpResponse = response as! HTTPURLResponse
                    if httpResponse.statusCode == ErrorCodes.tooManyRequests.rawValue {
                        let retryTimer = Double(httpResponse.allHeaderFields["retry-after"] as! String);
                        let dispatchTime = DispatchTime.now();
                        
                        DispatchQueue.main.asyncAfter(deadline: dispatchTime+retryTimer!, execute: {
                            self.getFollowedArtistsForUser(user: user, artistList: currentArtistList, searchFollowedUrl: searchFollowedUrl, followedArtistsHandler: { (fullArtistsList) in
                                
                            })
                        })
                        
                    } else if httpResponse.statusCode == ErrorCodes.okResponse.rawValue {
                        do {
                            let jsonObject = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
                            //let rootObjectTest = try SPTFollow.followingResult(from: data!, with: response)
                            
                            let rootElement = jsonObject["artists"] as! [String: AnyObject];
                            let items = rootElement["items"] as! [[String: AnyObject]];
                            //var artistsList = currentArtistList;
                            for artist in items {
                                let name = artist["name"] as! String
                                let popularity = artist["popularity"] as! Int
                                let uri = artist["uri"] as! String
                                let subGenres = self.filterSpotifyGenres(genres: artist["genres"] as! [String]);
                                let id = artist["id"] as! String
                                if subGenres.count > 0 {
                                    let artist = SpotifyArtist(artistName: name, subGenres: subGenres, popularity: popularity, uri: uri, id: id);
                                    currentArtistList.append(artist);
                                }
                            }
                            
                            if let next = rootElement["next"] as? String {
                                self.getFollowedArtistsForUser(user: user, artistList: currentArtistList, searchFollowedUrl: next, followedArtistsHandler: { (fullArtistsList) in
                                    followedArtistsHandler(fullArtistsList);
                                })
                            } else {
                                followedArtistsHandler(currentArtistList);
                            }
                            
                        } catch {
                            print("error parsing data in followed artists");
                        }
                    }
                    
                }
                
                
            }).resume()
        } catch {
            print("error creating request for followed artists");
        }
        
    }
    
    
    func getAllArtistsForPlaylist(userId: String, playlistId: String, nextTrackPageRequest: URLRequest? = nil, currentArtistList: [String]? = nil, fetchedPlaylistArtists: @escaping([String]) -> ()) {
        
        var currentList: [String] = currentArtistList != nil ? currentArtistList! : [];
        var pageRequest = nextTrackPageRequest;
        if pageRequest == nil {
            let url = "https://api.spotify.com/v1/users/\(userId)/playlists/\(playlistId)/tracks?fields=next,items(track(artists(uri)))"
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
                            self.getAllArtistsForPlaylist(userId: userId, playlistId: playlistId, nextTrackPageRequest: nextTrackPageRequest, currentArtistList: currentArtistList, fetchedPlaylistArtists: { (currentArtistList) in
                                fetchedPlaylistArtists(currentArtistList);
                            })
                        })
                        
                    } else if httpResponse.statusCode == ErrorCodes.okResponse.rawValue {
                        let jsonObject = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject];
                        let artistList = jsonObject["items"] as! [[String:AnyObject]];
                        for artist in artistList {
                            let trackInfo = artist["track"] as! [String: AnyObject]
                            let artistInfo = trackInfo["artists"] as! [[String: AnyObject]]
                            for artist in artistInfo {
                                if let artistId = artist["uri"] as? String {
                                    if !currentList.contains(artistId) && !artistId.contains(":local:::") {
                                        currentList.append(artistId)
                                    }
                                }
                            }
                        }
                        
                        let nextPage = jsonObject["next"] as? String
                        if let nextPage = nextPage {
                            let nextPageUrl = URL(string: nextPage)
                            let nextPageUrlRequest = URLRequest(url: nextPageUrl!)
                            self.getAllArtistsForPlaylist(userId: userId, playlistId: playlistId, nextTrackPageRequest: nextPageUrlRequest, currentArtistList: currentList, fetchedPlaylistArtists: { (currentArtistList) in
                                fetchedPlaylistArtists(currentArtistList)
                            })
                        } else {
                            fetchedPlaylistArtists(currentList);
                        }
                    }
                    
                } catch {
                    print("error parsing all artists for playlist")
                }
            }
            }.resume()
        
    }
    
    func getAllGenresForArtists(_ artistList: [String], offset: Int, currentFollowedArtistList: [SpotifyArtist]? = nil, artistGenresHandler: @escaping([SpotifyArtist]?) -> ()) {
        
        if artistList.count <= 0 {
            artistGenresHandler(nil);
            return;
        }
        var spotifyFollowedArtistList: [SpotifyArtist] = currentFollowedArtistList != nil ? currentFollowedArtistList! : []
        var currentArtistList:[String] = []
        var hasNext:Bool = true
        let checkLimit = artistList.count-offset
        
        
        if checkLimit > 50 {
            //currentArtistList = artistList[offset...offset+50]
            currentArtistList = Array(artistList[offset...offset+49]);
        } else {
            hasNext = false;
            currentArtistList = Array(artistList[offset...artistList.count-1])
        }
        
        let nextOffset = offset+50
        
        var artistUriList: [URL] = []
        
        for artistURI in currentArtistList {
            artistUriList.append(URL(string: artistURI)!)
        }
        
        do {
            let request = try SPTArtist.createRequest(forArtists: artistUriList, withAccessToken: self.auth.session.accessToken!)
            
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
                            self.getAllGenresForArtists(artistList, offset: offset, currentFollowedArtistList: currentFollowedArtistList, artistGenresHandler: { (spotifyArtistList) in
                                artistGenresHandler(spotifyArtistList)
                            })
                        })
                        
                    } else if httpResponse.statusCode == ErrorCodes.okResponse.rawValue {
                        do {
                            let jsonObject = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
                            //let rootObjectTest = try SPTFollow.followingResult(from: data!, with: response)
                            
                            if let error = jsonObject["error"] as? [String: AnyObject] {
                                print(error);
                                artistGenresHandler(nil)
                            } else {
                                //let rootElement = jsonObject["artists"] as! [[String: AnyObject]]
                                let items =  jsonObject["artists"] as! [[String: AnyObject]];
                                
                                //var artistsList = currentArtistList;
                                for artist in items {
                                    let name = artist["name"] as! String
                                    let popularity = artist["popularity"] as! Int
                                    let uri = artist["uri"] as! String
                                    let subGenres = self.filterSpotifyGenres(genres: artist["genres"] as! [String]);
                                    let id = artist["id"] as! String
                                    if subGenres.count > 0 {
                                        let artist = SpotifyArtist(artistName: name, subGenres: subGenres, popularity: popularity, uri: uri, id: id);
                                        spotifyFollowedArtistList.append(artist);
                                    }
                                }
                                
                                _ = !hasNext
                                if hasNext {
                                    self.getAllGenresForArtists(artistList, offset: nextOffset, currentFollowedArtistList: spotifyFollowedArtistList, artistGenresHandler: { (spotifyArtistList) in
                                        artistGenresHandler(spotifyArtistList)
                                    })
                                    
                                } else {
                                    artistGenresHandler(spotifyFollowedArtistList);
                                }
                            }
                            
                        } catch {
                            print("error parsing data in followed artists");
                        }
                    }
                    
                    
                }
                
            }).resume()
            
        } catch {
            
        }
        
    }
    
    
    func getGenresForArtist(artistId: String, fetchedArtistGenresHandler: @escaping ([String]?) -> () ) {
        let auth = SPTAuth.defaultInstance();
        do {
            
            let trackUrl = URL(string: "spotify:artist:\(artistId)")!
            let artistGenresRequest = try SPTArtist.createRequest(forArtist: trackUrl, withAccessToken: auth?.session.accessToken);
            let session = URLSession.shared;
            
            session.dataTask(with: artistGenresRequest, completionHandler: { (data, response, error) in
                if error != nil {
                    print("error getting artist genres for artist \(artistId)");
                    fetchedArtistGenresHandler(nil);
                } else {
                    do {
                        let jsonObject = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
                        let genres = jsonObject["genres"] as! [String]
                        fetchedArtistGenresHandler(genres);
                    } catch {
                        print("error parsing artist genres for artist \(artistId)");
                    }
                }
            }).resume()
        } catch {
            fetchedArtistGenresHandler(nil);
            print("error creating request for artist genres for artist \(artistId)");
        }
    }
    
}
