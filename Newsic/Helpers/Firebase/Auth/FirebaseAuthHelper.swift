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
    static let addAPNSTokenUrl = "https://us-central1-newsic-54b6e.cloudfunctions.net/addAPNSToken"
    
    class func handleSpotifyLogin(accessToken: String, user: SPTUser, loginCompletionHandler: @escaping (User?, NusicError?) -> ()) {
        
        let firebaseCustomTokenURL = generateCustomTokenUrl
        
        var urlComponents = URLComponents(string: firebaseCustomTokenURL)
        //
        urlComponents?.queryItems = []
        urlComponents?.queryItems?.insert(URLQueryItem(name: "accessToken", value: accessToken), at: 0)
        let username = user.canonicalUserName.replaceSymbols(symbol: ".", with: "-")
        urlComponents?.queryItems?.insert(URLQueryItem(name: "uid", value: username), at: 0)
        if user.largestImage != nil {
            urlComponents?.queryItems?.insert(URLQueryItem(name: "photoURL", value: user.largestImage.imageURL.absoluteString), at: 0)
        }
        
        urlComponents?.queryItems?.insert(URLQueryItem(name: "displayName", value: user.displayName), at: 0)
        if user.emailAddress != nil && user.emailAddress != "" {
            urlComponents?.queryItems?.insert(URLQueryItem(name: "emailAddress", value: user.emailAddress), at: 0)
        }
        
        let urlRequest = URLRequest(url: (urlComponents?.url)!)
        
        URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            if let error = error {
                loginCompletionHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.serverError, nusicErrorDescription: FirebaseErrorCodeDescription.getCustomToken.rawValue, systemError: error));
            } else {
                do {
                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: AnyObject]
                    let firebaseToken = parsedData["token"] as? String
                    var nusicError: NusicError? = nil
                    if let firebaseToken = firebaseToken {
                        Auth.auth().signIn(withCustomToken: firebaseToken, completion: { (user, error) in
                            
                            if let error = error {
                                nusicError = NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.functionalError, nusicErrorDescription: FirebaseErrorCodeDescription.getCustomToken.rawValue, systemError: error)
                            }
                            loginCompletionHandler(user, nusicError)
                        })
                    } else {
                        nusicError = NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.functionalError, nusicErrorDescription: FirebaseErrorCodeDescription.getCustomToken.rawValue, systemError: error)
                    }
                    
                } catch {
                    loginCompletionHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.functionalError, nusicErrorDescription: FirebaseErrorCodeDescription.getCustomToken.rawValue, systemError: error))
                }
                
            }
        }).resume()
    }

    class func addApnsDeviceToken(apnsToken: String, userId: String, apnsTokenCompletionHandler: @escaping (Bool?, NusicError?) -> ()) {
        let firebaseAddAPNSUrl = addAPNSTokenUrl
        
        if let firebaseUrl = URL(string: firebaseAddAPNSUrl) {
            var urlComponents = URLComponents(string: firebaseAddAPNSUrl)
            //
            urlComponents?.queryItems = []
            urlComponents?.queryItems?.insert(URLQueryItem(name: "deviceToken", value: apnsToken), at: 0)
            let username = userId.replaceSymbols(symbol: ".", with: "-")
            urlComponents?.queryItems?.insert(URLQueryItem(name: "uid", value: username), at: 0)
            
            let urlRequest = URLRequest(url: (urlComponents?.url)!)
            
            URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
                if let error = error {
                    apnsTokenCompletionHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.serverError, nusicErrorDescription: FirebaseErrorCodeDescription.getCustomToken.rawValue, systemError: error));
                } else {
                    do {
                        let parsedData = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: AnyObject]
                        let respData = parsedData["success"] as? Bool
                        apnsTokenCompletionHandler(respData, nil)
                        
                    } catch {
                        apnsTokenCompletionHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.functionalError, nusicErrorDescription: FirebaseErrorCodeDescription.getCustomToken.rawValue, systemError: error))
                    }
                    
                }
            }).resume()
        }
    }

    class func deleteUserData(userId: String) {
        if let user = Auth.auth().currentUser {
            user.delete(completion: { (error) in
                if let error = error {
                    print(error)
                }
            })
        }
    }
}
