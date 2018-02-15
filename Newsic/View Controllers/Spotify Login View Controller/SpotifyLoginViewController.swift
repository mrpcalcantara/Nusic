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
    var loadFullTitle: Bool = false {
        didSet {
            if loadFullTitle {
                UIView.animate(withDuration: 2, delay: 1, options: .curveEaseInOut, animations: {
                    self.nusicFullTitle.alpha = 1
                    self.view.layoutIfNeeded()
                }) { (isCompleted) in
                    self.nusicLabl.transform = CGAffineTransform.identity
                    self.nusicLabl.layer.removeAllAnimations()
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
    @IBOutlet weak var nusicLabelCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var nusicLabelCenterXConstraint: NSLayoutConstraint!
    
    //Objects for extracting User and Genres
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var nusicLabl: UILabel!
    @IBOutlet weak var nusicFullTitle: UILabel!
    
    @IBAction func spotifyLoginButton(_ sender: UIButton) {
       
        
        safariViewController = SFSafariViewController(url: loginUrl!);
        (UIApplication.shared.delegate as! AppDelegate).safariViewController = safariViewController;
        
        self.present(safariViewController, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        setupBackground()
        setupSpotify()
        
        gotToken = UserDefaults.standard.object(forKey: "SpotifySession") as AnyObject != nil
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
        self.nusicLabelCenterYConstraint.constant = 0
        self.nusicLabelCenterXConstraint.constant = 0
        self.view.layoutIfNeeded()
        loadFullTitle = false
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
            let appOpened = UserDefaults.standard.value(forKey: "appOpened") as? Bool
            if appOpened == nil || appOpened == false {
                if isConnected {
                    self.getSession()
                    UserDefaults.standard.setValue(true, forKey: "appOpened")
                    if !self.gotToken {
                        if self.timer != nil {
                            self.timer.invalidate()
                        }
                    }
                } else {
                    self.timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.fireErrorPopup), userInfo: nil, repeats: false)
                }
            }
        }
    }
    
    @objc fileprivate func moveToMainScreen() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "loginSuccessful"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "loginUnsuccessful"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "resetLogin"), object: nil)
        let pageViewController = NusicPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
        self.present(pageViewController, animated: true, completion: {
            self.removeFromParentViewController()
        })
    }

    @objc fileprivate func setupSpotify() {
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
        gotToken = notification.object as! Bool
        getSession();
    }
   
    fileprivate func getSession() {
        
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
                _ = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.moveToMainScreen), userInfo: nil, repeats: false)
            }
            
        } else {
            self.resetLogin()
//            if !gotToken {
//                self.resetLogin()
//            }
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
    
    @objc fileprivate func notificationResetLogin() {
        resetLogin()
//        viewDidLoad()
    }
    
    fileprivate func resetLogin() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//            self.resetViewLogin()
//        }
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
       UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.nusicLabelCenterYConstraint.constant = self.nusicFullTitle.frame.origin.y - self.nusicLabl.frame.origin.y
            self.nusicLabelCenterXConstraint.constant = self.nusicFullTitle.frame.origin.x - self.nusicLabl.frame.origin.x
            self.view.layoutIfNeeded()
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
    
}
