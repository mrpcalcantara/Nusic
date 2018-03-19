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
    var toActivateTimer: Bool = false
    var gotToken: Bool = false;
    var loadFullTitle: Bool = false {
        didSet {
            if loadFullTitle {
                self.nusicLabl.layer.removeAllAnimations()
                self.nusicLabl.transform = CGAffineTransform(scaleX: 2, y: 2)
                self.view.layoutIfNeeded()
                UIView.animate(withDuration: 2, delay: 1, options: .curveEaseInOut, animations: {
                    self.nusicLabl.alpha = 0.5
                    self.nusicFullTitle.alpha = 1
                    self.view.layoutIfNeeded()
                }) { (isCompleted) in
                    
                    
                }
            } else {
                self.nusicFullTitle.alpha = 0
            }
        }
    }
    
    //Constraints
    
    //Login Button
    @IBOutlet weak var loginButtonCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var loginButtonCenterXConstraint: NSLayoutConstraint!
    
    //Nusic Label
    @IBOutlet weak var nusicLabelCenterXConstraint: NSLayoutConstraint!
    
    //Objects for extracting User and Genres
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var nusicLabl: UILabel!
    @IBOutlet weak var nusicFullTitle: UILabel!
    
    @IBAction func spotifyLoginButton(_ sender: UIButton) {
       
        toActivateTimer = true
        safariViewController = SFSafariViewController(url: loginUrl!);
        self.present(safariViewController, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        setupBackground()
        setupSpotify()
        self.view.bringSubview(toFront: loginButton)
        self.view.bringSubview(toFront: nusicFullTitle)
        self.view.layoutIfNeeded()
        
        checkFirebaseConnectivity()
        removeNotificationObservers()
        addNotificationObservers()
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        UIApplication.shared.keyWindow?.rootViewController = self
        if toActivateTimer {
            activateTimer()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.nusicLabelCenterXConstraint.constant = 0
        self.view.layoutIfNeeded()
        loadFullTitle = false
        animateLogo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated);
        self.removeFromParentViewController()
        if timer != nil {
            deactivateTimer()
        }
        
    }
    
    @objc final func fireErrorPopup() {
        let popup = NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: "Unable to connect. Please try again later.");
        popup.presentPopup(for: self);
    }
    
    fileprivate func setupLogo() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(rotateNusicLogo))
        tapGestureRecognizer.numberOfTapsRequired = 1
        nusicLabl.addGestureRecognizer(tapGestureRecognizer)
    }
    
    fileprivate func setupLabel() {
        nusicLabl.textColor = UIColor.lightText
    }
    
    fileprivate func setupView() {
        loginButton.setImage(UIImage(named: "SpotifyLogin"), for: .normal);
        setupLabel()
    }
    
    fileprivate func setupBackground() {
        let image = UIImage(named: "BackgroundPattern")
        if let image = image {
            let imageView = UIImageView(frame: self.view.frame)
            imageView.contentMode = .scaleAspectFill
            imageView.image = image
            self.view.addSubview(imageView)
            self.view.sendSubview(toBack: imageView)
        }
    }
    
    fileprivate func checkFirebaseConnectivity() {
        FirebaseDatabaseHelper.detectFirebaseConnectivity { (isConnected) in
            if isConnected {
                self.getSession()
            }
        }
    }
    
    @objc fileprivate func moveToMainScreen() {
        removeNotificationObservers()
        let pageViewController = NusicPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        UIApplication.shared.keyWindow?.rootViewController = pageViewController
        self.present(pageViewController, animated: true, completion: {
            
            self.removeFromParentViewController()
        })
    }

    @objc fileprivate func setupSpotify() {
        safariViewController?.dismiss(animated: true, completion: nil)
        gotToken = false
        auth.clientID = Spotify.clientId;
        auth.redirectURL = URL(string: Spotify.redirectURI!);
        auth.requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistModifyPrivateScope, SPTAuthPlaylistModifyPublicScope, SPTAuthUserFollowReadScope, SPTAuthUserReadPrivateScope, SPTAuthUserReadEmailScope];
        auth.tokenSwapURL = URL(string: Spotify.swapURL)!
        auth.tokenRefreshURL = URL(string: Spotify.refreshURL)!
        
        if auth.session == nil || !auth.session.isValid() {
            loginUrl = auth.spotifyWebAuthenticationURL();
        }
        
    }
    
    @objc fileprivate func updateAfterFirstLogin(notification: Notification) {
        safariViewController?.dismiss(animated: true, completion: nil)
        gotToken = notification.object as! Bool
        getSession();
    }
   
    fileprivate func getSession() {
        activateTimer()
        let userDefaults = UserDefaults.standard
        guard let sessionObj:AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject? else { self.resetLogin(); return; }
        let sessionDataObj = sessionObj as! Data
        let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
        print("REFRESH TOKEN \(firstTimeSession.encryptedRefreshToken!)");
        print("ACCESS TOKEN \(firstTimeSession.accessToken!)");
        animateLogo()
        if !firstTimeSession.isValid() {
            self.getRefreshToken(currentSession: firstTimeSession, refreshTokenCompletionHandler: { (isRefreshed) in
                Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.moveToMainScreen), userInfo: nil, repeats: false)
            });
        } else {
            self.session = firstTimeSession
            self.auth.session = firstTimeSession;
            (UIApplication.shared.delegate as! AppDelegate).auth = self.auth;
            Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.moveToMainScreen), userInfo: nil, repeats: false)
        }
        
    }
    
    fileprivate func getRefreshToken(currentSession: SPTSession, refreshTokenCompletionHandler: @escaping (Bool) -> ()) {
        let userDefaults = UserDefaults.standard;
        SPTAuth.defaultInstance().renewSession(currentSession, callback: { (error, session) in
            if error == nil {
                print("refresh successful");
                let sessionData = NSKeyedArchiver.archivedData(withRootObject: session!)
                userDefaults.set(sessionData, forKey: "SpotifySession")
                userDefaults.synchronize()
                self.auth.session = session;
            } else {
                print("error refreshing session: \(error?.localizedDescription ?? "sdsdasasd")");
                self.loginButton.isHidden = false;
                self.loginUrl = self.auth.spotifyWebAuthenticationURL();
                self.resetLogin()
            }
            refreshTokenCompletionHandler(error == nil)
        })
    }
    
    @objc fileprivate func notificationResetLogin() {
        resetLogin()
    }
    
    fileprivate func removeNotificationObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "loginSuccessful"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "loginUnsuccessful"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "resetLogin"), object: nil)
    }
    
    fileprivate func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateAfterFirstLogin), name: NSNotification.Name(rawValue: "loginSuccessful"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setupSpotify), name: NSNotification.Name(rawValue: "loginUnsuccessful"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationResetLogin), name: NSNotification.Name(rawValue: "resetLogin"), object: nil)
    }
    
    fileprivate func resetLogin() {
        resetSpotifyLogin()
        resetViewLogin()
    }
    
    fileprivate func resetSpotifyLogin() {
        self.session = nil
        self.auth.session = nil
        let userDefaults = UserDefaults.standard;
        userDefaults.set(nil, forKey: "SpotifySession")
        userDefaults.synchronize()
    }
    
    fileprivate func resetViewLogin() {
        deactivateTimer()
        self.nusicLabl.transform = CGAffineTransform.identity
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.nusicLabl.alpha = 0
        }) { (isCompleted) in
            self.loadFullTitle = true
        }
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.loginButton.alpha = 1;
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    fileprivate func animateLogo() {
        loginButton.alpha = 0
        nusicFullTitle.alpha = 0
        
        UIView.animate(withDuration: 1, animations: {
            self.nusicLabl.alpha = 1;
        })
        rotateNusicLogo()
    }
    
    @objc fileprivate func rotateNusicLogo() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.2, options: [.curveEaseInOut], animations: {
            self.nusicLabl.transform = CGAffineTransform(rotationAngle: .pi)
        }) { (isCompleted) in
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.2, options: [.repeat, .curveEaseInOut], animations: {
                self.nusicLabl.transform = CGAffineTransform(rotationAngle: .pi * 2)
            }, completion: nil)
            
        }
    }
    
    fileprivate func activateTimer(resetPrevious: Bool? = true) {
        if resetPrevious! {
            deactivateTimer()
        }
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.fireErrorPopup), userInfo: nil, repeats: false)
    }
    
    fileprivate func deactivateTimer() {
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
    }
}
