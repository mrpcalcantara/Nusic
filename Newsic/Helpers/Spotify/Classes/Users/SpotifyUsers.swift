//
//  SpotifyBrowse.swift
//  Nusic
//
//  Created by Miguel Alcantara on 09/10/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

extension Spotify {
    
    final func getUser(completion: @escaping(SPTUser?, NusicError?) -> ()) {
        SPTUser.requestCurrentUser(withAccessToken: auth.session.accessToken) { (error, results) in
            guard let results = results else { completion(nil, NusicError(nusicErrorCode: NusicErrorCodes.spotifyError, nusicErrorSubCode: NusicErrorSubCode.technicalError)); return; }
            let userResult = results as! SPTUser
            completion(userResult, nil);
        }
    }
    
}
