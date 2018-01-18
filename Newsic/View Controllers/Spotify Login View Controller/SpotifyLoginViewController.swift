//
//  SpotifyLoginViewController.swift
//  Nusic
//
//  Created by Miguel Alcantara on 30/08/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit
import SwiftSpinner
import SafariServices
import PopupDialog
import FirebaseAuth

class SpotifyLoginViewController: NusicDefaultViewController {
    
    var auth = SPTAuth.defaultInstance()!
    var session:SPTSession!
    var loginUrl: URL? = SPTAuth.defaultInstance().spotifyWebAuthenticationURL();
    var loading: SwiftSpinner!;
    var safariViewController: SFSafariViewController!
    var timer: Timer! = Timer();
    var gotToken: Bool = false;
    
    //Constraints
    
    //Login Button
    @IBOutlet weak var loginButtonCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var loginButtonCenterXConstraint: NSLayoutConstraint!
    
    //Nusic Label
    @IBOutlet weak var nusicLabelCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var nusicLabelCenterXConstraint: NSLayoutConstraint!
    
    //Objects for extracting User and Genres
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var nusicLabl: UILabel!
    
    @IBAction func spotifyLoginButton(_ sender: UIButton) {
       
        
        safariViewController = SFSafariViewController(url: loginUrl!);
        (UIApplication.shared.delegate as! AppDelegate).safariViewController = safariViewController;
        
        self.present(safariViewController, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        checkFirebaseConnectivity()
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "loginSuccessful"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "loginUnsuccessful"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "resetLogin"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateAfterFirstLogin), name: NSNotification.Name(rawValue: "loginSuccessful"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(setupSpotify), name: NSNotification.Name(rawValue: "loginUnsuccessful"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationResetLogin), name: NSNotification.Name(rawValue: "resetLogin"), object: nil)
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        loginButton.alpha = 0
//        animateLogo()
        animateLogo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated);
        self.removeFromParentViewController()
    }
    
    @objc func fireErrorPopup() {
        let popup = NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: "Unable to connect. Please try again later.");
        popup.presentPopup(for: self);
    }
    
    func setupLabel() {
        nusicLabl.textColor = UIColor.lightText
    }
    
    func setupView() {
        loginButton.setImage(UIImage(named: "SpotifyLogin"), for: .normal);
        setupLabel()
    }
    
    func checkFirebaseConnectivity() {
        FirebaseDatabaseHelper.detectFirebaseConnectivity { (isConnected) in
            if isConnected {
                if !self.gotToken {
                    self.setupSpotify()
                    if self.timer != nil {
                        self.timer.invalidate()
                    }
                }
            } else {
                self.timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.fireErrorPopup), userInfo: nil, repeats: false)
            }
        }
    }
    
    @objc func moveToMainScreen() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "loginSuccessful"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "loginUnsuccessful"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "resetLogin"), object: nil)
        let pageViewController = NusicPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
//        self.present(pageViewController, animated: false, completion: nil);
        self.present(pageViewController, animated: true, completion: {
            self.removeFromParentViewController()
        })
    }

    @objc fileprivate func setupSpotify() {
        gotToken = false
        auth.clientID = Spotify.clientId;
        auth.redirectURL = URL(string: Spotify.redirectURI!);
        auth.requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistModifyPrivateScope, SPTAuthPlaylistModifyPublicScope, SPTAuthUserFollowReadScope, SPTAuthUserReadPrivateScope, SPTAuthUserReadEmailScope];
//        auth.requestedScopes = ["user-read-email","user-follow-read", "user-read-private"]
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
    
    @objc func updateAfterFirstLogin(notification: Notification) {
        gotToken = notification.object as! Bool
        print(gotToken)
        if gotToken {
            
        }
        getSession();
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
                _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.moveToMainScreen), userInfo: nil, repeats: false)
            }
            
        } else {
            if !gotToken {
                self.resetLogin()
            }
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
                refreshTokenCompletionHandler(false)
            }
        })
    }
    
    @objc func notificationResetLogin() {
        resetLogin()
//        viewDidLoad()
    }
    
    func resetLogin() {
        resetSpotifyLogin()
        resetViewLogin()
    }
    
    func resetSpotifyLogin() {
        self.session = nil
        self.auth.session = nil
        let userDefaults = UserDefaults.standard;
        userDefaults.set(nil, forKey: "SpotifySession")
        userDefaults.synchronize()
    }
    
    func resetViewLogin() {
        
        UIView.animate(withDuration: 1, animations: {
            self.nusicLabelCenterYConstraint.constant = -self.view.safeAreaLayoutGuide.layoutFrame.height/4
            self.view.layoutIfNeeded()
        })
        UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseOut, animations: {
            self.loginButton.alpha = 1;
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func animateLogo() {
        loginButton.alpha = 0
        nusicLabl.alpha = 0
        
        UIView.animate(withDuration: 1, animations: {
            self.nusicLabl.alpha = 1;
        })
        
        UIView.animate(withDuration: 1, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.nusicLabl.center.y += 20
            self.nusicLabl.center.y -= 20
        }, completion: nil)
    }
    
    
}
