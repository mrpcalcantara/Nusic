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
import PopupDialog

class SpotifyLoginViewController: NewsicDefaultViewController {
    
    var auth = SPTAuth.defaultInstance()!
    var session:SPTSession!
    var loginUrl: URL?
    var loading: SwiftSpinner!;
    var safariViewController: SFSafariViewController!
    var timer: Timer! = Timer();
    
    //Objects for extracting User and Genres
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var newsicLabl: UILabel!
    
    @IBAction func spotifyLoginButton(_ sender: UIButton) {
       
        
        safariViewController = SFSafariViewController(url: loginUrl!);
        (UIApplication.shared.delegate as! AppDelegate).safariViewController = safariViewController;
        
        self.present(safariViewController, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateAfterFirstLogin), name: NSNotification.Name(rawValue: "loginSuccessful"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setupSpotify), name: NSNotification.Name(rawValue: "loginUnsuccessful"), object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        animateLogo()
        checkFirebaseConnectivity()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        loginButton.alpha = 0
//        animateLogo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated);
        self.removeFromParentViewController()
    }
    
    
    @objc func fireErrorPopup() {
        let popup = NewsicError(newsicErrorCode: NewsicErrorCodes.firebaseError, newsicErrorSubCode: NewsicErrorSubCode.technicalError, newsicErrorDescription: "Unable to connect. Please try again later.");
        popup.presentPopup(for: self);
    }
    
    func setupLabel() {
        newsicLabl.textColor = UIColor.lightText
    }
    
    func setupView() {
        loginButton.setImage(UIImage(named: "SpotifyLogin"), for: .normal);
        setupLabel()
    }
    
    func checkFirebaseConnectivity() {
        FirebaseHelper.detectFirebaseConnectivity { (isConnected) in
            if isConnected {
                self.setupSpotify()
                if self.timer != nil {
                    self.timer.invalidate()
                }
                
            } else {
                self.timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.fireErrorPopup), userInfo: nil, repeats: false)
            }
        }
    }
    
    @objc func moveToMainScreen() {
        
        let pageViewController = NewsicPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
//        self.present(pageViewController, animated: false, completion: nil);
        self.present(pageViewController, animated: true) {
//            self.dismiss(animated: false, completion: nil)
        }
    }
    
    
    @objc fileprivate func setupSpotify() {
        auth.clientID = Spotify.clientId;
        auth.redirectURL = URL(string: Spotify.redirectURI!);
        auth.requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistModifyPrivateScope, SPTAuthPlaylistModifyPublicScope, SPTAuthUserFollowReadScope, SPTAuthUserReadPrivateScope];
        //
        
        auth.tokenSwapURL = URL(string: Spotify.swapURL)!
        auth.tokenRefreshURL = URL(string: Spotify.refreshURL)!
        
        getSession();
        
        if auth.session != nil && auth.session.isValid() {
//            updateAfterFirstLogin()
        } else {
            loginUrl = auth.spotifyWebAuthenticationURL();
            //loginUrl = auth.spotifyAppAuthenticationURL();
        }
        
        
    }
    
    @objc func updateAfterFirstLogin () {
        getSession();
    }
    
    func animateLogo() {
        loginButton.alpha = 0
        newsicLabl.alpha = 0
        
        UIView.animate(withDuration: 1, animations: {
            self.newsicLabl.alpha = 1;
        })
        
        UIView.animate(withDuration: 1, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.newsicLabl.center.y += 20
            self.newsicLabl.center.y -= 20
        }, completion: nil)
    }
    
    func getSession() {
        
        let userDefaults = UserDefaults.standard
        if let sessionObj:AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject? {
            //SwiftSpinner.show("Logging in..", animated: true);
            let sessionDataObj = sessionObj as! Data
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            print("REFRESH TOKEN \(firstTimeSession.encryptedRefreshToken!)");
            print("ACCESS TOKEN \(firstTimeSession.accessToken!)");
            animateLogo()
            if !firstTimeSession.isValid() {
                self.getRefreshToken(currentSession: firstTimeSession, refreshTokenCompletionHandler: { (isRefreshed) in
                    _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.moveToMainScreen), userInfo: nil, repeats: false)
                });
            } else {
                self.session = firstTimeSession
                self.auth.session = firstTimeSession;
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate;
                appDelegate.auth = self.auth;
                _ = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.moveToMainScreen), userInfo: nil, repeats: false)
                
            }
            
        } else {
            self.resetLogin()
            self.setViewResetLogin()
        }
        
    }
    
    func getRefreshToken(currentSession: SPTSession, refreshTokenCompletionHandler: @escaping (Bool) -> ()) {
        let userDefaults = UserDefaults.standard;
        SPTAuth.defaultInstance().renewSession(currentSession, callback: { (error, session) in
            if error == nil {
                print("refresh successful");
                let sessionData = NSKeyedArchiver.archivedData(withRootObject: session!)
                userDefaults.set(sessionData, forKey: "SpotifySession")
                userDefaults.synchronize()
                
                self.auth.session = session;
                refreshTokenCompletionHandler(true)
            } else {
                print("error refreshing session: \(error?.localizedDescription ?? "sdsdasasd")");
                self.loginButton.isHidden = false;
                self.loginUrl = self.auth.spotifyWebAuthenticationURL();
                self.resetLogin()
                self.setViewResetLogin()
                refreshTokenCompletionHandler(false)
            }
        })
    }
    
    func resetLogin() {
        self.session = nil
        self.auth.session = nil
        let userDefaults = UserDefaults.standard;
        userDefaults.set(nil, forKey: "SpotifySession")
        userDefaults.synchronize()
    }
    
    func setViewResetLogin() {
        UIView.animate(withDuration: 1, animations: {
            self.newsicLabl.center.y = self.view.bounds.height / 4
        })
        UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseOut, animations: {
            self.loginButton.alpha = 1;
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    
}
