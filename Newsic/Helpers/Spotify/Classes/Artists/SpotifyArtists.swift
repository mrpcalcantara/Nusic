//
//  SpotifyBrowse.swift
//  Newsic
//
//  Created by Miguel Alcantara on 09/10/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

extension Spotify {
    
    func getFollowedArtistsForUser(user: SPTUser, artistList:[SpotifyArtist]? = nil, searchFollowedUrl: String? = nil, followedArtistsHandler: @escaping([SpotifyArtist], NewsicError?) -> ()) {
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
                if isSuccess {
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
                            self.getFollowedArtistsForUser(user: user, artistList: currentArtistList, searchFollowedUrl: next, followedArtistsHandler: { (fullArtistsList, nil) in
                                followedArtistsHandler(fullArtistsList, nil);
                            })
                        } else {
                            followedArtistsHandler(currentArtistList, nil);
                        }
                        
                    } catch {
                        print("error parsing data in followed artists");
                    }
                } else {
                    switch statusCode {
                    case 400...499:
                        followedArtistsHandler([], NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.clientError))
                    case 500...599:
                        followedArtistsHandler([], NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.serverError))
                    default: followedArtistsHandler([], NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.technicalError));
                    }
                }
            })
        } catch {
            print("error creating request for followed artists");
        }
        
    }
    
    
    func getAllArtistsForPlaylist(userId: String, playlistId: String, nextTrackPageRequest: URLRequest? = nil, currentArtistList: [String]? = nil, fetchedPlaylistArtists: @escaping([String], NewsicError?) -> ()) {
        
        var currentList: [String] = currentArtistList != nil ? currentArtistList! : [];
        var pageRequest = nextTrackPageRequest;
        if pageRequest == nil {
            let url = "https://api.spotify.com/v1/users/\(userId)/playlists/\(playlistId)/tracks?fields=next,items(track(artists(uri)))"
            pageRequest = URLRequest(url: URL(string: url)!);
        }
        
        pageRequest?.addValue("Bearer \(self.auth.session.accessToken!)", forHTTPHeaderField: "Authorization")
        let session = URLSession.shared;
        
        if let pageRequest = pageRequest {
            executeSpotifyCall(with: pageRequest, spotifyCallCompletionHandler: { (data, httpResponse, error, isSuccess) in
                let statusCode:Int! = httpResponse != nil ? httpResponse?.statusCode : -1
                if isSuccess {
                    do {
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
                            self.getAllArtistsForPlaylist(userId: userId, playlistId: playlistId, nextTrackPageRequest: nextPageUrlRequest, currentArtistList: currentList, fetchedPlaylistArtists: { (currentArtistList, nil) in
                                fetchedPlaylistArtists(currentArtistList, nil)
                            })
                        } else {
                            fetchedPlaylistArtists(currentList, nil);
                        }
                    } catch { }
                } else {
                    switch statusCode {
                    case 400...499:
                        fetchedPlaylistArtists([], NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.clientError))
                    case 500...599:
                        fetchedPlaylistArtists([], NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.serverError))
                    default: fetchedPlaylistArtists([], NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.technicalError));
                    }
                }
            })
            
        }
    }
    
    func getAllGenresForArtists(_ artistList: [String], offset: Int, currentFollowedArtistList: [SpotifyArtist]? = nil, artistGenresHandler: @escaping([SpotifyArtist]?, NewsicError?) -> ()) {
        
        if artistList.count <= 0 {
            artistGenresHandler(nil, nil);
            return;
        }
        var spotifyFollowedArtistList: [SpotifyArtist] = currentFollowedArtistList != nil ? currentFollowedArtistList! : []
        var currentArtistList:[String] = []
        var hasNext:Bool = true
        let checkLimit = artistList.count-offset
        
        
        if checkLimit > 50 {
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
            

            executeSpotifyCall(with: request, spotifyCallCompletionHandler: { (data, httpResponse, error, isSuccess) in
                let statusCode:Int! = httpResponse != nil ? httpResponse?.statusCode : -1
                if isSuccess {
                    do {
                        let jsonObject = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
                        
                        if let error = jsonObject["error"] as? [String: AnyObject] {
                            print(error);
                            artistGenresHandler(nil, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.functionalError))
                        } else {
                            let items =  jsonObject["artists"] as! [[String: AnyObject]];

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
                                self.getAllGenresForArtists(artistList, offset: nextOffset, currentFollowedArtistList: spotifyFollowedArtistList, artistGenresHandler: { (spotifyArtistList, nil) in
                                    artistGenresHandler(spotifyArtistList, nil)
                                })
                                
                            } else {
                                artistGenresHandler(spotifyFollowedArtistList, nil);
                            }
                        }
                        
                    } catch {
                        print("error parsing data in followed artists");
                    }
                } else {
                    switch statusCode {
                    case 400...499:
                        artistGenresHandler(nil, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.clientError))
                    case 500...599:
                        artistGenresHandler(nil, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.serverError))
                    default: artistGenresHandler(nil, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.technicalError));
                    }
                }
            })
            
        } catch {
            
        }
        
    }
    
    
    func getGenresForArtist(artistId: String, fetchedArtistGenresHandler: @escaping ([String]?, NewsicError?) -> () ) {
        do {
            
            let trackUrl = URL(string: "spotify:artist:\(artistId)")!
            let artistGenresRequest = try SPTArtist.createRequest(forArtist: trackUrl, withAccessToken: auth.session.accessToken!);

            executeSpotifyCall(with: artistGenresRequest, spotifyCallCompletionHandler: { (data, httpResponse, error, isSuccess) in
                let statusCode:Int! = httpResponse != nil ? httpResponse?.statusCode : -1
                if isSuccess {
                    do {
                        let jsonObject = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
                        let genres = jsonObject["genres"] as! [String]
                        fetchedArtistGenresHandler(genres, nil);
                    } catch {
                        print("error parsing artist genres for artist \(artistId)");
                    }
                } else {
                    switch statusCode {
                    case 400...499:
                        fetchedArtistGenresHandler(nil, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.clientError))
                    case 500...599:
                        fetchedArtistGenresHandler(nil, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.serverError))
                    default: fetchedArtistGenresHandler(nil, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.technicalError));
                    }
                }
            })
        } catch { fetchedArtistGenresHandler(nil, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.technicalError));
                        print("error creating request for artist genres for artist \(artistId)");
            
        }
    }
    
}
