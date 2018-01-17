//
//  FirebaseAuthHelper.swift
//  Newsic
//
//  Created by Miguel Alcantara on 17/01/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import Foundation
import FirebaseAuth

class FirebaseAuthHelper {
    
    static let generateCustomTokenUrl = "https://us-central1-newsic-54b6e.cloudfunctions.net/generateCustomToken"
    
    class func handleSpotifyLogin(accessToken: String, uid: String, loginCompletionHandler: @escaping (User?, NusicError?) -> ()) {
        
        let firebaseCustomTokenURL = generateCustomTokenUrl
        
        if let firebaseUrl = URL(string: firebaseCustomTokenURL) {
            var urlComponents = URLComponents(string: firebaseCustomTokenURL)
            //
            urlComponents?.queryItems = []
            urlComponents?.queryItems?.insert(URLQueryItem(name: "accessToken", value: accessToken), at: 0)
            urlComponents?.queryItems?.insert(URLQueryItem(name: "uid", value: uid), at: 0)
            let urlRequest = URLRequest(url: (urlComponents?.url)!)
            
            URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
                if let error = error {
                    loginCompletionHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.serverError, nusicErrorDescription: FirebaseErrorCodeDescription.getCustomToken.rawValue, systemError: error));
                } else {
                    do {
                        let parsedData = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: AnyObject]
                        let firebaseToken = parsedData["token"] as! String
                        Auth.auth().signIn(withCustomToken: firebaseToken, completion: { (user, error) in
                            var nusicError: NusicError? = nil
                            if let error = error {
                                nusicError = NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.functionalError, nusicErrorDescription: FirebaseErrorCodeDescription.getCustomToken.rawValue, systemError: error)
                            }
                            loginCompletionHandler(user, nusicError)
                        })
                    } catch {
                        
                    }
                    
                }
            }).resume()
        }
    }
}
