//
//  SpotifyBrowse.swift
//  Newsic
//
//  Created by Miguel Alcantara on 09/10/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

extension Spotify {
    
    func getAllPlaylists(for pageRequest: URLRequest? = nil, currentPlaylistList: [SPTPartialPlaylist]? = nil, fetchedPlaylistsHander: @escaping ([SPTPartialPlaylist], NewsicError?) -> ()) {
        
        var nextPagePlaylistList = currentPlaylistList == nil ? [] : currentPlaylistList;
        
        let playlistRequest = pageRequest != nil ? pageRequest : try? SPTPlaylistList.createRequestForGettingPlaylists(forUser: self.user.canonicalUserName, withAccessToken: self.auth.session.accessToken);
        
        let session = URLSession.shared;
        
        session.executeCall(with: playlistRequest!) { (data, httpResponse, error, isSuccess) in
            let statusCode:Int! = httpResponse?.statusCode
            if isSuccess {
                
                let playlistList = try? SPTPlaylistList.init(from: data, with: httpResponse);
                let page = playlistList as! SPTListPage
                let playlists = page.items as! [SPTPartialPlaylist]
                nextPagePlaylistList?.append(contentsOf: playlists);
                
                if page.hasNextPage {
                    do {
                        let nextPageRequest = try page.createRequestForNextPage(withAccessToken: self.auth.session.accessToken)
                        self.getAllPlaylists(for: nextPageRequest, currentPlaylistList: nextPagePlaylistList, fetchedPlaylistsHander: { (currentPlaylistList, error) in
                            fetchedPlaylistsHander(currentPlaylistList, nil);
                        })
                    } catch {
                        print("error in recursive get all playlists function")
                    }
                } else {
                    fetchedPlaylistsHander(nextPagePlaylistList!, nil);
                }
            } else {
                switch statusCode {
                case 400...499:
                    fetchedPlaylistsHander([], NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.clientError))
                case 500...599:
                    fetchedPlaylistsHander([], NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.serverError))
                default: return;
                }
            }
        }
    }
//
//        session.dataTask(with: playlistRequest!) { (data, response, error) in
//            let httpResponse = response as! HTTPURLResponse
//            let statusCode = httpResponse.statusCode
//            switch statusCode {
//                case 200...299:
//                    let playlistList = try? SPTPlaylistList.init(from: data, with: response);
//                    let page = playlistList as! SPTListPage
//                    let playlists = page.items as! [SPTPartialPlaylist]
//                    nextPagePlaylistList?.append(contentsOf: playlists);
//
//                    if page.hasNextPage {
//                        do {
//                            let nextPageRequest = try page.createRequestForNextPage(withAccessToken: self.auth.session.accessToken)
//                            self.getAllPlaylists(for: nextPageRequest, currentPlaylistList: nextPagePlaylistList, fetchedPlaylistsHander: { (currentPlaylistList, error) in
//                                fetchedPlaylistsHander(currentPlaylistList, nil);
//                            })
//                        } catch {
//                            print("error in recursive get all playlists function")
//                        }
//                    } else {
//                        fetchedPlaylistsHander(nextPagePlaylistList!, nil);
//                    }
//                case 400...499:
//                    if statusCode == HTTPErrorCodes.tooManyRequests.rawValue {
//                        let retryTimer = Double(httpResponse.allHeaderFields["retry-after"] as! String);
//                        let dispatchTime = DispatchTime.now();
//
//                        DispatchQueue.main.asyncAfter(deadline: dispatchTime+retryTimer!, execute: {
//                            self.getAllPlaylists(for: pageRequest, currentPlaylistList: currentPlaylistList, fetchedPlaylistsHander: { (currentPlaylistList, error) in
//                            })
//                        })
//
//                    } else {
//                        fetchedPlaylistsHander([], NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, spotifyErrorCode: SpotifyErrorCodes.clientError))
//                    }
//                case 500...599:
//                    fetchedPlaylistsHander([], NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, spotifyErrorCode: SpotifyErrorCodes.serverError))
//                default: return;
//                }
//            }.resume()
//
//    }
    
    
    func checkPlaylistExists(playlistId: String, playlistExistHandler: @escaping(Bool) -> ()) {
        
    }
    
    func createNewsicPlaylist(playlistName: String, playlistCreationHandler: @escaping(Bool?, NewsicPlaylist?, NewsicError?) -> ()) {
        let auth = SPTAuth.defaultInstance();
        do {
            let username: String! = auth?.session.canonicalUsername!
            let accessToken: String! = auth?.session.accessToken!
            let url = "https://api.spotify.com/v1/users/\(username!)/playlists"
            var createPlaylistRequest = URLRequest(url: URL(string: url)!);
            createPlaylistRequest.addValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
            createPlaylistRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            createPlaylistRequest.httpMethod = "POST";
            let session = URLSession.shared;
            
            let body = "{\"name\":\"\(playlistName)\"}";
            createPlaylistRequest.httpBody = body.data(using: .utf8)
            
            session.executeCall(with: createPlaylistRequest) { (data, httpResponse, error, isSuccess) in
                let statusCode:Int! = httpResponse?.statusCode
                if isSuccess {
                    let jsonObject = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject];
                    //print(jsonObject);
                    let playlistId: String = jsonObject["id"] as! String
                    let newsicPlaylist = NewsicPlaylist(name : playlistName, id: playlistId, userName: username)
                    playlistCreationHandler(true, newsicPlaylist, nil)
                } else {
                    switch statusCode {
                    case 400...499:
                        playlistCreationHandler(false, nil, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.clientError))
                    case 500...599:
                        playlistCreationHandler(false, nil, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.serverError))
                    default: return;
                    }
                }
            }
        } catch {
            playlistCreationHandler(false, nil, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.technicalError))
            print("error creating request creating playlist list with name \(playlistName)");
        }
    }
            
//
//            session.dataTask(with: createPlaylistRequest, completionHandler: { (data, response, error) in
//                if error != nil {
//                    print("error creating playlist \(body)");
//                    playlistCreationHandler(false, nil, nil)
//                } else {
//                    let httpResponse = response as! HTTPURLResponse
//                    let statusCode = httpResponse.statusCode
//                    switch statusCode {
//                    case 200...299:
//                        let jsonObject = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject];
//                        //print(jsonObject);
//                        let playlistId: String = jsonObject["id"] as! String
//                        let newsicPlaylist = NewsicPlaylist(name : playlistName, id: playlistId, userName: username)
//                        playlistCreationHandler(true, newsicPlaylist, nil)
//                    case 400...499:
//                        if statusCode == HTTPErrorCodes.tooManyRequests.rawValue {
//                            let retryTimer = Double(httpResponse.allHeaderFields["retry-after"] as! String);
//                            let dispatchTime = DispatchTime.now();
//
//                            DispatchQueue.main.asyncAfter(deadline: dispatchTime+retryTimer!, execute: {
//                                self.createNewsicPlaylist(playlistName: playlistName, playlistCreationHandler: { (isCreated, playList, error)  in
//
//                                })
//                            })
//
//                        } else {
//                            playlistCreationHandler(false, nil, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, spotifyErrorCode: SpotifyErrorCodes.clientError))
//                        }
//                    case 500...599:
//                        playlistCreationHandler(false, nil, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, spotifyErrorCode: SpotifyErrorCodes.serverError))
//                    default: return;
//                    }
//                }
//            }).resume()
//        } catch {
//            playlistCreationHandler(false, nil, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, spotifyErrorCode: SpotifyErrorCodes.technicalError))
//            print("error creating request creating playlist list with name \(playlistName)");
//        }
//    }
    
}
