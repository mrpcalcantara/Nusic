//
//  SpotifyBrowse.swift
//  Newsic
//
//  Created by Miguel Alcantara on 09/10/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

extension Spotify {
    
    func getAllPlaylists(for pageRequest: URLRequest? = nil, currentPlaylistList: [SPTPartialPlaylist]? = nil, fetchedPlaylistsHander: @escaping ([SPTPartialPlaylist]) -> ()) {
        
        var nextPagePlaylistList = currentPlaylistList == nil ? [] : currentPlaylistList;
        
        let playlistRequest = pageRequest != nil ? pageRequest : try? SPTPlaylistList.createRequestForGettingPlaylists(forUser: self.user.canonicalUserName, withAccessToken: self.auth.session.accessToken);
        
        let session = URLSession.shared;
        
        session.dataTask(with: playlistRequest!) { (data, response, error) in
            let httpResponse = response as! HTTPURLResponse
            if httpResponse.statusCode == ErrorCodes.tooManyRequests.rawValue {
                let retryTimer = Double(httpResponse.allHeaderFields["retry-after"] as! String);
                let dispatchTime = DispatchTime.now();
                
                DispatchQueue.main.asyncAfter(deadline: dispatchTime+retryTimer!, execute: {
                    self.getAllPlaylists(for: pageRequest, currentPlaylistList: currentPlaylistList, fetchedPlaylistsHander: { (currentPlaylistList) in
                    })
                })
                
            } else if httpResponse.statusCode == ErrorCodes.okResponse.rawValue {
                let playlistList = try? SPTPlaylistList.init(from: data, with: response);
                let page = playlistList as! SPTListPage
                let playlists = page.items as! [SPTPartialPlaylist]
                nextPagePlaylistList?.append(contentsOf: playlists);
                
                if page.hasNextPage {
                    do {
                        let nextPageRequest = try page.createRequestForNextPage(withAccessToken: self.auth.session.accessToken)
                        self.getAllPlaylists(for: nextPageRequest, currentPlaylistList: nextPagePlaylistList, fetchedPlaylistsHander: { (currentPlaylistList) in
                            fetchedPlaylistsHander(currentPlaylistList);
                        })
                    } catch {
                        print("error in recursive get all playlists function")
                    }
                } else {
                    fetchedPlaylistsHander(nextPagePlaylistList!);
                }
            }
            
            }.resume()
        
    }
    
    
    func checkPlaylistExists(playlistId: String, playlistExistHandler: @escaping(Bool) -> ()) {
        
    }
    
    func createNewsicPlaylist(playlistName: String, playlistCreationHandler: @escaping(Bool?, NewsicPlaylist?) -> ()) {
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
            
            session.dataTask(with: createPlaylistRequest, completionHandler: { (data, response, error) in
                if error != nil {
                    print("error creating playlist \(body)");
                    playlistCreationHandler(false, nil)
                } else {
                    let httpResponse = response as! HTTPURLResponse
                    if httpResponse.statusCode == ErrorCodes.tooManyRequests.rawValue {
                        let retryTimer = Double(httpResponse.allHeaderFields["retry-after"] as! String);
                        let dispatchTime = DispatchTime.now();
                        
                        DispatchQueue.main.asyncAfter(deadline: dispatchTime+retryTimer!, execute: {
                            self.createNewsicPlaylist(playlistName: playlistName, playlistCreationHandler: { (isCreated, playList)  in
                                
                            })
                        })
                        
                    } else {
                        let jsonObject = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject];
                        print(jsonObject);
                        let playlistId: String = jsonObject["id"] as! String
                        let newsicPlaylist = NewsicPlaylist(name : playlistName, id: playlistId, userName: username)
                        playlistCreationHandler(true, newsicPlaylist)
                    }
                    
                }
            }).resume()
        } catch {
            playlistCreationHandler(false, nil)
            print("error creating request creating playlist list with name \(playlistName)");
        }
    }
    
}
