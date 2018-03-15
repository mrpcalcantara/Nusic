//
//  SpotifyBrowse.swift
//  Nusic
//
//  Created by Miguel Alcantara on 09/10/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

extension Spotify {
    
    final func getAllPlaylists(for pageRequest: URLRequest? = nil, currentPlaylistList: [SPTPartialPlaylist]? = nil, fetchedPlaylistsHandler: @escaping ([SPTPartialPlaylist], NusicError?) -> ()) {
        
        var nextPagePlaylistList = currentPlaylistList == nil ? [] : currentPlaylistList;
        let playlistRequest = pageRequest != nil ? pageRequest : try? SPTPlaylistList.createRequestForGettingPlaylists(forUser: self.user.canonicalUserName, withAccessToken: self.auth.session.accessToken!);
        
        executeSpotifyCall(with: playlistRequest!, spotifyCallCompletionHandler: { (data, httpResponse, error, isSuccess) in
            let statusCode:Int! = httpResponse != nil ? httpResponse?.statusCode : -1
            guard isSuccess else { fetchedPlaylistsHandler([], NusicError.manageError(statusCode: statusCode, errorCode: NusicErrorCodes.spotifyError, description: SpotifyErrorCodeDescription.getPlaylistTracks.rawValue)); return; }
            let playlistList = try? SPTPlaylistList.init(from: data, with: httpResponse);
            let page = playlistList as! SPTListPage
            guard let playlists = page.items as? [SPTPartialPlaylist] else { fetchedPlaylistsHandler([], nil); return; }
            nextPagePlaylistList?.append(contentsOf: playlists);
            guard page.hasNextPage else { fetchedPlaylistsHandler(nextPagePlaylistList!, nil); return; }
            do {
                let nextPageRequest = try page.createRequestForNextPage(withAccessToken: self.auth.session.accessToken!)
                self.getAllPlaylists(for: nextPageRequest, currentPlaylistList: nextPagePlaylistList, fetchedPlaylistsHandler: { (currentPlaylistList, error) in
                    fetchedPlaylistsHandler(currentPlaylistList, nil);
                })
            } catch {
                print("error in recursive get all playlists function")
            }
        })
    }
    
    final func checkPlaylistExists(playlistId: String, playlistExistHandler: @escaping(Bool?, NusicError?) -> ()) {
        self.getAllPlaylists { (playListList, error) in
            if let error = error {
                playlistExistHandler(nil, error);
            } else {
                let hasElement = playListList.contains(where: { (existingPlaylist) -> Bool in
                    return existingPlaylist.uri.absoluteString.contains(playlistId);
                })
                
                playlistExistHandler(hasElement, nil);
            }
        }
    }
    
    final func createNusicPlaylist(playlistName: String, playlistCreationHandler: @escaping(Bool?, NusicPlaylist?, NusicError?) -> ()) {
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
            do {
                let statusCode:Int! = httpResponse != nil ? httpResponse?.statusCode : -1
                if isSuccess {
                    let jsonObject = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject];
                    //print(jsonObject);
                    let playlistId: String = jsonObject["id"] as! String
                    let nusicPlaylist = NusicPlaylist(name : playlistName, id: playlistId, userName: username)
                    playlistCreationHandler(true, nusicPlaylist, nil)
                } else {
                    playlistCreationHandler(false, nil, NusicError.manageError(statusCode: statusCode, errorCode: NusicErrorCodes.spotifyError, description: SpotifyErrorCodeDescription.createPlaylist.rawValue))
                }
            } catch {
                playlistCreationHandler(false, nil, NusicError(nusicErrorCode: NusicErrorCodes.spotifyError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: SpotifyErrorCodeDescription.createPlaylist.rawValue))
                print("error creating request creating playlist list with name \(playlistName)");
            }
        })
    }
    
}
