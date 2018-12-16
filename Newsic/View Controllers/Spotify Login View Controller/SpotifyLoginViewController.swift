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
import FirebaseMessaging

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
                self.nusicTitleLogo.layer.removeAllAnimations()
                self.nusicTitleLogo.transform = CGAffineTransform(scaleX: 2, y: 2)
                self.view.layoutIfNeeded()
                UIView.animate(withDuration: 2, delay: 1, options: .curveEaseInOut, animations: {
                    self.nusicTitleLogo.alpha = 0.5
                    self.nusicFullTitle.alpha = 1
                    self.view.layoutIfNeeded()
                }, completion: nil)
            } else {
                self.nusicFullTitle.alpha = 0
                self.nusicTitleLogo.alpha = 0
                self.onboardingContainerView.alpha = 0
            }
        }
    }
    
    //Data to pass to SongPicker
    var fullArtistList = [SpotifyArtist]()
    let spotifyHandler: Spotify = Spotify()
    var moodObject: NusicMood? = nil
    var fullPlaylistList = [SPTPartialPlaylist]()
    var nusicPlaylist: NusicPlaylist! = nil;
    var loadingFinished: Bool = false {
        didSet {
            let pageViewController = NusicPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
            UIApplication.shared.keyWindow?.rootViewController = pageViewController
            removeNotificationObservers()
            passDataToSideMenu()
            passDataToNusicWeekly()
            passDataToSongPicker()
            guard let rootVC = UIApplication.shared.keyWindow?.rootViewController as? NusicPageViewController, let nusicWeeklyVC = rootVC.nusicWeeklyVC else { return }
            rootVC.scrollToViewController(viewController: nusicWeeklyVC)
            DispatchQueue.main.async {
                self.present(rootVC, animated: true, completion: {
                    self.removeFromParent()
                })
            }
        }
    }
    
    var nusicUser: NusicUser! = nil {
        didSet {
            nusicUser.isPremium = self.spotifyHandler.user.isPremium()
            nusicUser.saveUser { (isSaved, error) in
                guard error == nil else { error?.presentPopup(for: self); return; }
            }
            
            guard let fcmTokenId = UserDefaults.standard.value(forKey: "fcmTokenId") as? String else { return }
            FirebaseAuthHelper.addApnsDeviceToken(apnsToken: fcmTokenId, userId: nusicUser.userName, apnsTokenCompletionHandler: { (isSuccess, error) in
                guard error == nil else { error?.presentPopup(for: self); return }
                print("adding APNS token = \(isSuccess!)")
            })
            
            guard UserDefaults.standard.value(forKey: "subscribedToTopic") == nil else { return }
            Messaging.messaging().subscribe(toTopic: "nusicWeekly")
            UserDefaults.standard.set(true, forKey: "subscribedToTopic")
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
    @IBOutlet weak var nusicTitleLogo: UILabel!
    
    @IBOutlet weak var onboardingContainerView: UIView!
    @IBAction func spotifyLoginButton(_ sender: UIButton) {
       
        toActivateTimer = true
        safariViewController = SFSafariViewController(url: loginUrl!);
        self.present(safariViewController, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        setupSpotify()
        setupLogo()
        self.view.bringSubviewToFront(loginButton)
        self.view.bringSubviewToFront(nusicFullTitle)
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
        self.removeFromParent()
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
    
    fileprivate func checkFirebaseConnectivity() {
        FirebaseDatabaseHelper.detectFirebaseConnectivity { (isConnected) in
            if isConnected {
                self.getSession()
            }
        }
    }
    
    @objc fileprivate func moveToMainScreen() {
        setupUser()
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
            self.onboardingContainerView.alpha = 1
            self.loginButton.alpha = 1;
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    fileprivate func animateLogo() {
        loginButton.alpha = 0
        nusicFullTitle.alpha = 0
        onboardingContainerView.alpha = 0
        
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
    
    fileprivate func setupUser() {
        let dispatchGroup = DispatchGroup()
        //Get User Info
        dispatchGroup.enter()
        
        spotifyHandler.getUser { (user, error) in
            guard let user = user else {
                self.showLoginErrorPopup();
                self.loadingFinished = true;
                return;
            }
            self.spotifyHandler.user = user;
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            self.handleUserLogin()
        }
    }
    
    fileprivate func handleUserLogin() {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        var tempUser: NusicUser?
        FirebaseAuthHelper.handleSpotifyLogin(
            accessToken: spotifyHandler.auth.session.accessToken,
            user: spotifyHandler.user,
            loginCompletionHandler: { (user, error) in
                guard error == nil, let userName = user?.uid else {
                    self.showLoginErrorPopup()
                    self.loadingFinished = true
                    return
                }
                tempUser = NusicUser(user: self.spotifyHandler.user)
                self.moodObject = NusicMood();
                self.moodObject?.userName = userName
                self.spotifyPlaylistCheck();
                dispatchGroup.leave()
        })
        
        dispatchGroup.notify(queue: .main) {
            guard let user = tempUser else { return }
            self.manageUserData(user: user)
        }
    }
    
    fileprivate func manageUserData(user: NusicUser) {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        user.getUser(getUserHandler: { (fbUser, error) in
            guard error == nil else { error?.presentPopup(for: self); return; }
            if fbUser == nil || fbUser?.userName == "" {
                user.setPremium(with: self.spotifyHandler.user.isPremium());
                self.nusicUser = user
                self.extractGenresFromSpotify(genreExtractionHandler: { (isSuccessful) in
                    guard isSuccessful else { error?.presentPopup(for: self, description: SpotifyErrorCodeDescription.extractGenresFromUser.rawValue); return;}
                })
            } else {
                self.nusicUser = fbUser!
                //TEMPORARY: Due to the DB restructure, migrate data if user version is < 1.1
                guard self.nusicUser.version == "1.0" else { self.fetchFavoriteGenres(); return; }
                FirebaseDatabaseHelper.migrateData(userId: self.nusicUser.userName, migrationCompletionHandler: { (success, error) in
                    guard error == nil else { error?.presentPopup(for: self); return; }
                    self.fetchFavoriteGenres()
                })
            }
        })
    }
    
    fileprivate func extractGenresFromSpotify(genreExtractionHandler: @escaping (Bool) -> ()) {
        //Get Followed Artists
        SwiftSpinner.show("Extracting Followed Artists..", animated: true)
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        DispatchQueue.main.async {
            SwiftSpinner.show("Extracting Playlists..", animated: true)
        }
        spotifyHandler.getFollowedArtistsForUser(user: spotifyHandler.user, followedArtistsHandler: { (followedArtistsList, error) in
            guard error == nil else { genreExtractionHandler(false); return; }
            
            DispatchQueue.global(qos: .default).async {
                for artist in followedArtistsList {
                    self.fullArtistList.append(artist)
                }
                dispatchGroup.leave()
            }
        })
        
        dispatchGroup.wait()
        
        //Get All Playlists from user
        dispatchGroup.enter()
        DispatchQueue.main.async {
            SwiftSpinner.show("Extracting Artists from Playlists..", animated: true)
        }
        self.spotifyHandler.getAllPlaylists(fetchedPlaylistsHandler: { (playlistList, error) in
            guard error == nil else { genreExtractionHandler(false); return; }
            
            DispatchQueue.global(qos: .default).async {
                self.fullPlaylistList = playlistList
                //Get All Artists for each playlist
                dispatchGroup.leave()
            }
        })
        
        dispatchGroup.wait()
        
        // Get all artists from playlists
        for playlist in self.fullPlaylistList {
            let playlistId = playlist.uri.absoluteString.substring(from: (playlist.uri.absoluteString.range(of: "playlist:")?.upperBound)!)
            dispatchGroup.enter()
            DispatchQueue.main.async {
                SwiftSpinner.show("Extracting Genres..", animated: true)
            }
            self.spotifyHandler.getAllArtistsForPlaylist(userId: playlist.owner.canonicalUserName!, playlistId: playlistId, fetchedPlaylistArtists: { (results, error) in
                guard error == nil else { genreExtractionHandler(false); return; }
                self.spotifyHandler.getAllGenresForArtists(results, offset: 0, artistGenresHandler: { (artistList, error) in
                    
                    if let artistList = artistList {
                        for artist in artistList {
                            self.fullArtistList.append(artist);
                        }
                    }
                    dispatchGroup.leave()
                })
            })
        }
        
        //Save genres to Firebase
        dispatchGroup.notify(queue: .main) {
            let dict = self.spotifyHandler.getGenreCount(for: self.fullArtistList);
            self.nusicUser.favoriteGenres = NusicGenre.convertGenreCountToGenres(userName: self.nusicUser.userName, dict: dict);
            self.nusicUser.saveFavoriteGenres(saveGenresHandler: { (isSaved, error) in
                if let error = error {
                    error.presentPopup(for: self)
                }
            })
            genreExtractionHandler(true)
            self.loadingFinished = true;
        }
        
    }
    
    fileprivate func spotifyPlaylistCheck() {
        nusicPlaylist = NusicPlaylist(userName: self.spotifyHandler.user.canonicalUserName);
        nusicPlaylist.getPlaylist { (playlist, error) in
            guard error == nil else { error?.presentPopup(for: self); return; }
            guard let playlistId = playlist?.id else { self.createPlaylistSpotify(); return; }
            self.spotifyHandler.checkPlaylistExists(playlistId: playlistId, playlistExistHandler: { (isExisting, error) in
                guard let isExisting = isExisting, !isExisting else { error?.presentPopup(for: self, description: SpotifyErrorCodeDescription.checkPlaylist.rawValue); return; }
                self.createPlaylistSpotify()
                FirebaseDatabaseHelper.deleteAllTracks(user: self.spotifyHandler.user.canonicalUserName, deleteTracksCompleteHandler: nil)
            })
        }
    }
    
    fileprivate func createPlaylistSpotify() {
        self.spotifyHandler.createNusicPlaylist(playlistName: "Liked in Nusic", playlistCreationHandler: { (isCreated, playlist, error) in
            guard let isCreated = isCreated, isCreated == true else { error?.presentPopup(for: self); return; }
            self.nusicPlaylist = playlist;
            playlist?.addNewPlaylist(addNewPlaylistHandler: { (isAdded, error) in
                if let error = error {
                    error.presentPopup(for: self)
                }
            })
        })
    }
    
    fileprivate func fetchFavoriteGenres() {
        self.nusicUser.getFavoriteGenres(getGenresHandler: { (dbGenreCount, error) in
            guard let dbGenreCount = dbGenreCount else { self.spotifyHandler.genreCount = Spotify.getAllValuesDict(); self.loadingFinished = true; return; }
            self.spotifyHandler.genreCount = dbGenreCount;
            self.nusicUser.saveFavoriteGenres(saveGenresHandler: { (isSaved, error) in
                guard error == nil else { error?.presentPopup(for: self); return }
            });
            self.loadingFinished = true;
        })
    }
    

    //Pass Data to View Controllers
    fileprivate func passDataToSongPicker() {
        guard let parent = UIApplication.shared.keyWindow?.rootViewController as? NusicPageViewController, let songPickerVC = parent.songPickerVC as? SongPickerViewController else { return }
        songPickerVC.fullArtistList = fullArtistList
        songPickerVC.spotifyHandler = spotifyHandler
        songPickerVC.moodObject = moodObject
        songPickerVC.fullPlaylistList = fullPlaylistList
        songPickerVC.nusicPlaylist = nusicPlaylist
        songPickerVC.nusicUser = nusicUser
    }
    
    fileprivate func passDataToSideMenu() {
        guard let parent = UIApplication.shared.keyWindow?.rootViewController as? NusicPageViewController else { return }
        let sideMenu = parent.sideMenuVC as! SideMenuViewController
        guard let nusicUser = self.nusicUser else { return; }
        sideMenu.username = self.nusicUser.displayName != "" ? self.nusicUser.displayName : self.nusicUser.userName;
        sideMenu.preferredPlayer = self.nusicUser.settingValues.preferredPlayer
        sideMenu.useMobileData = self.nusicUser.settingValues.useMobileData
        sideMenu.enablePlayerSwitch = self.nusicUser.isPremium! ? true : false
        sideMenu.nusicUser = nusicUser
        if self.spotifyHandler.user.smallestImage != nil, let imageURL = self.spotifyHandler.user.smallestImage.imageURL {
            sideMenu.profileImageURL = imageURL
        }
    }
    
    fileprivate func passDataToNusicWeekly() {
        guard let parent = UIApplication.shared.keyWindow?.rootViewController as? NusicPageViewController else { return }
        let nusicWeeklyViewController = parent.nusicWeeklyVC as! NusicWeeklyViewController
        nusicWeeklyViewController.spotify = self.spotifyHandler
    }
}
