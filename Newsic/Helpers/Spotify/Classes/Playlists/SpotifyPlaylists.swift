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
        
        let playlistRequest = pageRequest != nil ? pageRequest : try? SPTPlaylistList.createRequestForGettingPlaylists(forUser: self.user.canonicalUserName, withAccessToken: self.auth.session.accessToken!);
        

        executeSpotifyCall(with: playlistRequest!, spotifyCallCompletionHandler: { (data, httpResponse, error, isSuccess) in
            let statusCode:Int! = httpResponse?.statusCode
            if isSuccess {
                
                let playlistList = try? SPTPlaylistList.init(from: data, with: httpResponse);
                let page = playlistList as! SPTListPage
                let playlists = page.items as! [SPTPartialPlaylist]
                nextPagePlaylistList?.append(contentsOf: playlists);
                
                if page.hasNextPage {
                    do {
                        let nextPageRequest = try page.createRequestForNextPage(withAccessToken: self.auth.session.accessToken!)
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
        })
    }
    
    func checkPlaylistExists(playlistId: String, playlistExistHandler: @escaping(Bool) -> ()) {
        
    }
    
    func createNewsicPlaylist(playlistName: String, playlistCreationHandler: @escaping(Bool?, NewsicPlaylist?, NewsicError?) -> ()) {
        do {
            let username: String! = auth.session.canonicalUsername
            let accessToken: String! = auth.session.accessToken!
            let url = "https://api.spotify.com/v1/users/\(username!)/playlists"
            var createPlaylistRequest = URLRequest(url: URL(string: url)!);
            createPlaylistRequest.addValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
            createPlaylistRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            createPlaylistRequest.httpMethod = "POST";
           
            
            
            let body = "{\"name\":\"\(playlistName)\"}";
            createPlaylistRequest.httpBody = body.data(using: .utf8)

            executeSpotifyCall(with: createPlaylistRequest, spotifyCallCompletionHandler: { (data, httpResponse, error, isSuccess) in
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
            })
        } catch {
            playlistCreationHandler(false, nil, NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.technicalError))
            print("error creating request creating playlist list with name \(playlistName)");
        }
    }
    
}
