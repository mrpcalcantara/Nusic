//
//  SpotifyBrowse.swift
//  Newsic
//
//  Created by Miguel Alcantara on 09/10/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

extension Spotify {
    
    func getUser(completion: @escaping(SPTUser?, NewsicError?) -> ()) {
        SPTUser.requestCurrentUser(withAccessToken: auth.session.accessToken) { (error, results) in
            if error != nil {
                print("error getting user: \(error?.localizedDescription)")
                let error = NewsicError(newsicErrorCode: NewsicErrorCodes.spotifyError, newsicErrorSubCode: NewsicErrorSubCode.technicalError)
                completion(nil, error)
            }
            
            let userResult = results as! SPTUser
            
            completion(userResult, nil);
            
        }
        
    }
    
}
