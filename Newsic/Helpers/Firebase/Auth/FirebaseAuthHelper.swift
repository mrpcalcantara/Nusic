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
            guard error == nil else {
                loginCompletionHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.serverError, nusicErrorDescription: FirebaseErrorCodeDescription.getCustomToken.rawValue, systemError: error));
                return;
            }
            do {
                let parsedData = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: AnyObject]
                var nusicError: NusicError? = nil
                guard let firebaseToken = parsedData["token"] as? String else {
                    nusicError = NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.functionalError, nusicErrorDescription: FirebaseErrorCodeDescription.getCustomToken.rawValue, systemError: error);
                    return;
                }
                Auth.auth().signIn(withCustomToken: firebaseToken, completion: { (user, error) in
                    nusicError = error == nil ? nil : NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.functionalError, nusicErrorDescription: FirebaseErrorCodeDescription.getCustomToken.rawValue, systemError: error)
                    loginCompletionHandler(user?.user, nusicError)
                })
                
            } catch {
                loginCompletionHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.functionalError, nusicErrorDescription: FirebaseErrorCodeDescription.getCustomToken.rawValue, systemError: error))
            }
        }).resume()
    }

    class func addApnsDeviceToken(apnsToken: String, userId: String, apnsTokenCompletionHandler: @escaping (Bool?, NusicError?) -> ()) {
        var urlComponents = URLComponents(string: addAPNSTokenUrl)
        //
        urlComponents?.queryItems = []
        urlComponents?.queryItems?.insert(URLQueryItem(name: "deviceToken", value: apnsToken), at: 0)
        let username = userId.replaceSymbols(symbol: ".", with: "-")
        urlComponents?.queryItems?.insert(URLQueryItem(name: "uid", value: username), at: 0)
        
        let urlRequest = URLRequest(url: (urlComponents?.url)!)
        
        URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            guard error == nil else {
                apnsTokenCompletionHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.serverError, nusicErrorDescription: FirebaseErrorCodeDescription.getCustomToken.rawValue, systemError: error));
                return;
            }
            do {
                let parsedData = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: AnyObject]
                let respData = parsedData["success"] as? Bool
                apnsTokenCompletionHandler(respData, nil)
                
            } catch {
                apnsTokenCompletionHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.functionalError, nusicErrorDescription: FirebaseErrorCodeDescription.getCustomToken.rawValue, systemError: error))
            }
        }).resume()
    }

    class func deleteUserData(userId: String) {
        guard let user = Auth.auth().currentUser else { return; }
        user.delete(completion: { (error) in
            guard error == nil else { print(error); return }
        })
    }
}
