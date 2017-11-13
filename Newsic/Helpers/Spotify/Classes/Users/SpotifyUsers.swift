//
//  SpotifyBrowse.swift
//  Newsic
//
//  Created by Miguel Alcantara on 09/10/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

extension Spotify {
    
    func getUser(completion: @escaping(SPTUser?) -> ()) {
        let auth = SPTAuth.defaultInstance();
        print("\(String(describing: auth?.session))");
        SPTUser.requestCurrentUser(withAccessToken: auth?.session.accessToken) { (error, results) in
            if error != nil {
                print("error getting user")
                completion(nil)
            }
            let userResult = results as! SPTUser
            completion(userResult);
            
        }
        
    }
    
}
