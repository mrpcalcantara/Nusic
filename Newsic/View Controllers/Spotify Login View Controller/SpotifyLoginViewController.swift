//
//  SpotifyLoginViewController.swift
//  Newsic
//
//  Created by Miguel Alcantara on 30/08/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit
import SwiftSpinner
import SafariServices

class SpotifyLoginViewController: NewsicDefaultViewController {
    
    var auth = SPTAuth.defaultInstance()!
    var session:SPTSession!
    var loginUrl: URL?
    var loading: SwiftSpinner!;
    var safariViewController: SFSafariViewController!
    
    //Objects for extracting User and Genres
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var newsicLabl: UILabel!
    
    @IBAction func spotifyLoginButton(_ sender: UIButton) {
       
        
        safariViewController = SFSafariViewController(url: loginUrl!);
        (UIApplication.shared.delegate as! AppDelegate).safariViewController = safariViewController;
        
        self.present(safariViewController, animated: true, completion: nil)
        //window?.insertSubview(safariViewController.view, atIndex: 0)
//        UIApplication.shared.open(loginUrl!, options: [:]) { (result) in
//            if self.auth.canHandle(self.auth.redirectURL) {
//                // To do - build in error handling
//            }
//        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        NotificationCenter.default.addObserver(self, selector: #selector(updateAfterFirstLogin), name: NSNotification.Name(rawValue: "loginSuccessfull"), object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        setupSpotify()
        
        
    }
    
    func setupLabel() {
        newsicLabl.textColor = UIColor.lightText
    }
    
    func setupView() {
        loginButton.setImage(UIImage(named: "SpotifyLogin"), for: .normal);
        setupLabel()
    }
    
    @objc func moveToMainScreen() {
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SongPicker") as! SongPickerViewController;
        let navigationController = UINavigationController(rootViewController: viewController)
//        let navigationController = CustomNavigationController(rootViewController: viewController)
        self.modalPresentationStyle = .popover
        self.present(navigationController, animated: true) {
            //SwiftSpinner.show(duration: 2, title: "Welcome!");
        }
        
        //self.performSegue(withIdentifier: "showWatsonSegue", sender: self)
        
        
    }
    
    
    fileprivate func setupSpotify() {
        auth.clientID = Spotify.clientId;
        auth.redirectURL = URL(string: Spotify.redirectURI!);
        auth.requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistModifyPrivateScope, SPTAuthPlaylistModifyPublicScope, SPTAuthUserFollowReadScope];
        //
        
        auth.tokenSwapURL = URL(string: Spotify.swapURL)!
        auth.tokenRefreshURL = URL(string: Spotify.refreshURL)!
        getSession();
        
        if auth.session != nil && auth.session.isValid() {
            updateAfterFirstLogin()
        } else {
            loginUrl = auth.spotifyWebAuthenticationURL();
            //loginUrl = auth.spotifyAppAuthenticationURL();
        }
        
        
    }
    
    @objc func updateAfterFirstLogin () {
        getSession();
    }
    
    func getSession() {
        
        loginButton.alpha = 0
        newsicLabl.alpha = 0
        
        //self.newsicLabl.animate(newText: "Newsic", characterDelay: 0.5)
        //self.newsicLabl.startShimmering()
        UIView.animate(withDuration: 1, animations: {
            self.newsicLabl.alpha = 1;
        })

        UIView.animate(withDuration: 1, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.newsicLabl.center.y += 20
            self.newsicLabl.center.y -= 20
        }, completion: nil)
        
        let userDefaults = UserDefaults.standard
        if let sessionObj:AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject? {
            //SwiftSpinner.show("Logging in..", animated: true);
            let sessionDataObj = sessionObj as! Data
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            print("REFRESH TOKEN \(firstTimeSession.encryptedRefreshToken)");
            print("ACCESS TOKEN \(firstTimeSession.accessToken)");
            
            if !firstTimeSession.isValid() {
                self.getRefreshToken(currentSession: firstTimeSession);
            } else {
                self.session = firstTimeSession
                self.auth.session = firstTimeSession;
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate;
                appDelegate.auth = self.auth;
                _ = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.moveToMainScreen), userInfo: nil, repeats: false)
                
            }
            
        } else {
            self.session = nil
            self.auth.session = nil
            UIView.animate(withDuration: 1, animations: {
                self.newsicLabl.center.y = self.view.bounds.height / 4
            })
            UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseOut, animations: {
                self.loginButton.alpha = 1;
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
        
    }
    
    func getRefreshToken(currentSession: SPTSession) {
        let userDefaults = UserDefaults.standard;
        SPTAuth.defaultInstance().renewSession(currentSession, callback: { (error, session) in
            if error == nil {
                print("refresh successful");
                let sessionData = NSKeyedArchiver.archivedData(withRootObject: session!)
                userDefaults.set(sessionData, forKey: "SpotifySession")
                userDefaults.synchronize()
                
                self.auth.session = session;
                _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.moveToMainScreen), userInfo: nil, repeats: false)
            } else {
                print("error refreshing session: \(error?.localizedDescription ?? "sdsdasasd")");
                self.loginButton.isHidden = false;
                self.loginUrl = self.auth.spotifyWebAuthenticationURL();
                
            }
        })
    }
    
    
    
}
