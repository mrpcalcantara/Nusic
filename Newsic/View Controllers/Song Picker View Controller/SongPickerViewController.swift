//
//  ViewController.swift
//  Nusic
//
//  Created by Miguel Alcantara on 28/08/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

//import AVKit
//import MediaPlayer
import PopupDialog
import UIKit
import SwiftSpinner
import FirebaseDatabase

class SongPickerViewController: NusicDefaultViewController {
    
    
    //View variables
    let sectionInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8);
    var sectionHeaderFrame: CGRect = CGRect(x: 16, y: 8, width: 0, height: 0)
    var navbar: UINavigationBar = UINavigationBar()
    var spinner: SwiftSpinner! = nil
    var listMenuView: ChoiceListView! = nil
    var viewRotated:Bool = false
    var cellsPerRow: CGFloat = 0
    var nusicControl: NusicSegmentedControl!
    var currentSection: Int = 0
    let itemsPerRow: CGFloat = 2;
    var selectedIndexPathForMood: IndexPath?
    var sectionGenreTitles: [String] = []
    var sectionMoodTitles: [String] = []
    var sectionMoods: [[EmotionDyad]] = Array(Array()) {
        didSet {
            moodCollectionView.reloadData()
        }
    }
    
    //Nusic data variables
    var nusicPlaylist: NusicPlaylist! = nil;
    var moodObject: NusicMood? = nil;
    var nusicUser: NusicUser! = nil {
        didSet {
            let parent = self.parent as! NusicPageViewController
            let sideMenu = parent.sideMenuVC as! SideMenuViewController
            
            sideMenu.username = self.nusicUser.displayName != "" ? self.nusicUser.displayName : self.nusicUser.userName;
            
            sideMenu.preferredPlayer = self.nusicUser.settingValues.preferredPlayer
            sideMenu.useMobileData = self.nusicUser.settingValues.useMobileData
            sideMenu.enablePlayerSwitch = self.nusicUser.isPremium! ? true : false
            
            sideMenu.nusicUser = nusicUser

            if self.spotifyHandler.user.smallestImage != nil, let imageURL = self.spotifyHandler.user.smallestImage.imageURL {
                sideMenu.profileImageURL = imageURL
            } 
            nusicUser.saveUser { (isSaved, error) in
                if let error = error {
                    error.presentPopup(for: self)
                }
                
            }
            
            if let fcmTokenId = UserDefaults.standard.value(forKey: "fcmTokenId") as? String {
                FirebaseAuthHelper.addApnsDeviceToken(apnsToken: fcmTokenId, userId: nusicUser.userName, apnsTokenCompletionHandler: { (isSuccess, error) in
                    if let error = error {
                        error.presentPopup(for: self)
                    }
                    print("adding APNS token = \(isSuccess!)")
                })
            }
            
        }
    }
    var isMoodSelected: Bool = true
    var isMoodCellSelected: Bool = false {
        didSet {
            if isMoodCellSelected {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.searchButton.alpha = 1
                    }, completion: nil)
                }
            } else {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.searchButton.alpha = self.nusicControl.selectedIndex == 0 ? 0 : 1
                    }, completion: nil)
                }
            }
        }
    }
    
    var loadingFinished: Bool = false {
        didSet {
            if sectionMoods.count == 0 {
                FirebaseDatabaseHelper.fetchAllMoods(user: self.spotifyHandler.user.canonicalUserName) { (dyadList, error) in
                    self.sectionMoodTitles = dyadList.keys.map({ $0.rawValue })
                    self.sectionMoods = dyadList.map({ $0.value })
                    SwiftSpinner.show(duration: 2, title: "Done!", animated: true)
                }
            }
            handleNotificationSong()
        }
    }
    
    //Spotify variables
    var currentPlaylistIndex: Int = 0
    var fullArtistList:[SpotifyArtist] = [];
    var fullPlaylistList:[SPTPartialPlaylist] = []
    var genreList:[SpotifyGenres] = SpotifyGenres.allShownValues;
    var sectionGenres: [[SpotifyGenres]] = Array(Array())
    var spotifyHandler = Spotify();
    var user: SPTUser? = nil;
    var fetchedSongsForMood: [String: [SpotifyTrack]] = [:]
    var selectedSongsForMood: [String: [SpotifyTrack]] = [:]
    var fetchedSongsForGenre: [String: [SpotifyTrack]] = [:]
    var selectedSongsForGenre: [String: [SpotifyTrack]] = [:] {
        didSet {
            if selectedSongsForGenre.count == 0 {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.searchButton.setTitle(self.isMoodCellSelected ? "Get Songs!" : "Random it up!", for: .normal)
                    }, completion: nil)
                    self.view.layoutIfNeeded()
                }
            } else {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.searchButton.setTitle("Get Songs!", for: .normal)
                    }, completion: nil)
                    self.view.layoutIfNeeded()
                }
            }
            
        }
    }
    
    //Constraints
    @IBOutlet weak var menuTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var moodCollectionTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var moodCollectionLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var moodCollectionBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var moodCollectionTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var genreCollectionLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var genreCollectionBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var genreCollectionTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var genreCollectionTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var listViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchButtonHeightConstraint: NSLayoutConstraint!
    //Outlets
    @IBOutlet weak var mainControlView: UIView!
    @IBOutlet weak var moodText: UITextView!
    @IBOutlet weak var moodCollectionView: UICollectionView!
    @IBOutlet weak var moodGenreSegmentedControl: UISegmentedControl!
    @IBOutlet weak var genreCollectionView: UICollectionView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    
    //Actions
    
    @IBAction func getNewSong(_ sender: Any) {
        isMoodSelected = nusicControl.selectedIndex == 0 ? true : false
        if !isMoodSelected {
            let nusicMood = NusicMood()
            nusicMood.emotions = [Emotion(basicGroup: .unknown, detailedEmotions: [], rating: 0)]
            self.moodObject = nusicMood
        }
        
        if selectedIndexPathForMood != nil {
            invalidateCellsLayout(for: moodCollectionView)
        }

        self.moodObject?.userName = self.spotifyHandler.auth.session.canonicalUsername!

        if Connectivity.isConnectedToNetwork() == .connectedCellular && nusicUser.settingValues.useMobileData! == false {
            showMobileDataPopup()
        } else {
            passDataToShowSong();
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if viewRotated {
//            genreCollectionView.collectionViewLayout.invalidateLayout()
//            moodCollectionView.collectionViewLayout.invalidateLayout()
        }
        invalidateCellsLayout(for: moodCollectionView)
        invalidateCellsLayout(for: genreCollectionView)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if navbar.frame.origin.y != self.view.safeAreaLayoutGuide.layoutFrame.origin.y {
//            setupNavigationBar()
        }
        
        if viewRotated {
            reloadCellsData(for: moodCollectionView)
            reloadCellsData(for: genreCollectionView)
            
            var newY:CGFloat = 0
            if !listMenuView.isShowing {
                newY = self.view.frame.height
            } else {
                if listMenuView.isOpen {
                    newY = self.view.frame.height/2
                } else {
                    newY = self.view.safeAreaLayoutGuide.layoutFrame.maxY - listMenuView.toggleViewHeight
                }
            }
            listMenuView.maxY = self.view.safeAreaLayoutGuide.layoutFrame.maxY - listMenuView.toggleViewHeight
            listMenuView.frame = CGRect(x: listMenuView.frame.origin.x, y: newY, width: self.view.frame.width, height: listMenuView.frame.height)
            listMenuView.reloadView()
            searchButton.reloadBlurEffect()
            self.view.layoutIfNeeded()
            viewRotated = false
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if loadingFinished {
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated);
        if nusicControl.selectedIndex == 1 && listMenuView.chosenGenres.count > 0 {
            hideChoiceMenu()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        viewRotated = true
        if nusicControl.selectedIndex == 1 && listMenuView.chosenGenres.count > 0 {
            hideChoiceMenu()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        moodCollectionView.collectionViewLayout.invalidateLayout()
        genreCollectionView.collectionViewLayout.invalidateLayout()
        reloadCellsData(for: moodCollectionView)
        reloadCellsData(for: genreCollectionView)
        reloadListMenu()
        reloadNavigationBar()
        self.view.layoutIfNeeded()
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if nusicUser == nil {
            DispatchQueue.main.async {
                SwiftSpinner.show("Loading..", animated: true)
            }
            
            extractInformationFromUser { (isFinished) in
                
            }
            self.setupCollectionCellViews();
            self.setupView()
            self.setupListMenu()
            self.setupSegmentedControl()
            self.setupNavigationBar()
            self.setupNotificationHandlers()
        }
        
    }
    
    fileprivate func setupSegmentedControl() {
        nusicControl = NusicSegmentedControl(frame: navbar.frame)
        nusicControl.frame.size = CGSize(width: nusicControl.frame.width, height: 44)
        
        nusicControl.translatesAutoresizingMaskIntoConstraints = false
        nusicControl.layoutIfNeeded()
        nusicControl.sizeToFit()
        nusicControl.translatesAutoresizingMaskIntoConstraints = true
        nusicControl.delegate = self
        nusicControl.thumbColor = NusicDefaults.foregroundThemeColor
        nusicControl.borderColor = NusicDefaults.foregroundThemeColor
        nusicControl.selectedIndex = 0
        toggleCollectionViews(for: 0);
    }
    
    fileprivate func setupNavigationBar(image: UIImage? = UIImage(named: "SettingsIcon")) {
        navigationBar.barStyle = .default
        
        let leftBarButton = UIBarButtonItem(image: image!, style: .plain, target: self, action: #selector(toggleMenu));
        
        self.navigationItem.leftBarButtonItem = leftBarButton
        let showSongImage = UIImage(named: "PreferredPlayer")?.withRenderingMode(.alwaysTemplate)
        let rightBarButton = UIBarButtonItem(image: showSongImage, style: .plain, target: self, action: #selector(goToShowSongVC));
        if let pageViewController = parent as? NusicPageViewController {
            
            if pageViewController.orderedViewControllers.contains(pageViewController.showSongVC!) {
                rightBarButton.tintColor = UIColor.white
                rightBarButton.isEnabled = true
            } else {
                rightBarButton.tintColor = UIColor.gray
                rightBarButton.isEnabled = false
            }
            
            self.navigationItem.rightBarButtonItem = rightBarButton
            
        }
        
        nusicControl.frame.size.height = 44
        self.navigationItem.titleView = nusicControl
        
        let navItem = self.navigationItem
        navigationBar.items = [navItem]
        self.view.layoutIfNeeded()
        
    }
    
    fileprivate func reloadNavigationBar(image: UIImage? = UIImage(named: "SettingsIcon")) {
        if let pageViewController = parent as? NusicPageViewController {
            
            if pageViewController.orderedViewControllers.contains(pageViewController.showSongVC!) {
                navigationBar.topItem?.rightBarButtonItem?.tintColor = UIColor.white
                navigationBar.topItem?.rightBarButtonItem?.isEnabled = true
            } else {
                navigationBar.topItem?.rightBarButtonItem?.tintColor = UIColor.gray
                navigationBar.topItem?.rightBarButtonItem?.isEnabled = false
            }
            
            
        }
    }
    
    fileprivate func setupView() {
        
        self.mainControlView.backgroundColor = UIColor.clear
        self.genreCollectionView.backgroundColor = UIColor.clear
        self.moodCollectionView.backgroundColor = UIColor.clear
        self.searchButton.backgroundColor = UIColor.clear
        self.searchButton.setTitle("Random it up!", for: .normal)
        
        moodCollectionView.layer.zPosition = -1
        genreCollectionView.layer.zPosition = -1
        
        let collectionViewsPanGestureRecoginizer = UIPanGestureRecognizer(target: self, action: #selector(panCollectionViews(_:)))
        self.mainControlView.addGestureRecognizer(collectionViewsPanGestureRecoginizer)
        
    }
    
    fileprivate func setupNotificationHandlers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotificationSong), name: NSNotification.Name(rawValue: "nusicADayNotificationPushed"), object: nil)
    }
    
    @objc fileprivate func toggleMenu() {
        let parent = self.parent as! NusicPageViewController
        parent.scrollToViewController(index: 0)
    }
    
    @objc fileprivate func goToShowSongVC() {
        let parent = self.parent as! NusicPageViewController
        parent.scrollToNextViewController()
    }
    
    fileprivate func manageViewControllerShowSong() {
        let pageVC = (self.parent as! NusicPageViewController)
        if SPTAudioStreamingController.sharedInstance().initialized {
            pageVC.addViewControllerToPageVC(viewController: pageVC.showSongVC!)
        } else {
            pageVC.removeViewControllerFromPageVC(viewController: pageVC.showSongVC!)
        }
    }
    
    fileprivate func showMobileDataPopup(){
        let dialog = PopupDialog(title: "Warning!", message: "We detected that you are using mobile data and have set the app to not use this data. Please connect to a WiFi network or enable Mobile Data usage in the Settings.", transitionStyle: .zoomIn, gestureDismissal: false, completion: nil)
        
        dialog.addButton(DefaultButton(title: "Got it!", action: nil))
        
        self.present(dialog, animated: true, completion: nil)
    }
    
    fileprivate func extractInformationFromUser(extractionHandler: @escaping (Bool) -> ()) {
        
        fullArtistList = [];
        
        
        //Get User Info
        self.spotifyHandler.getUser { (user, error) in
            guard let user = user else { self.showLoginErrorPopup(); self.loadingFinished = true; return; }
            self.spotifyHandler.user = user;
            FirebaseAuthHelper.handleSpotifyLogin(
                accessToken: self.spotifyHandler.auth.session.accessToken,
                user: self.spotifyHandler.user,
                loginCompletionHandler: { (user, error) in
                    if error != nil {
                        self.showLoginErrorPopup()
                        self.loadingFinished = true
                    } else {
                        let user = NusicUser(user: self.spotifyHandler.user)
                        self.moodObject?.userName = user.userName
                        self.spotifyPlaylistCheck();
                        user.getUser(getUserHandler: { (fbUser, error) in
                            if let error = error {
                                error.presentPopup(for: self)
                            }
                            if fbUser == nil || fbUser?.userName == "" {
                                self.nusicUser = user
                                self.extractGenresFromSpotify(genreExtractionHandler: { (isSuccessful) in
                                    guard isSuccessful else { error?.presentPopup(for: self, description: SpotifyErrorCodeDescription.extractGenresFromUser.rawValue); return;}
                                })
                            } else {
                                self.nusicUser = fbUser!
                                //TEMPORARY: Due to the DB restructure, migrate data if user version is < 1.1
                                if self.nusicUser.version == "1.0" {
                                    FirebaseDatabaseHelper.migrateData(userId: self.nusicUser.userName, migrationCompletionHandler: { (success, error) in
                                        guard error == nil else { error?.presentPopup(for: self); return; }
                                        self.fetchFavoriteGenres()
                                    })
                                } else {
                                    self.fetchFavoriteGenres()
                                }
                            }
                        })
                    }
            })
        }
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
                self.currentPlaylistIndex = 0;
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
            if playlist == nil {
                self.createPlaylistSpotify()
            } else {
                guard let playlistId = playlist?.id else { return; }
                self.spotifyHandler.checkPlaylistExists(playlistId: playlistId, playlistExistHandler: { (isExisting, error) in
                    guard let isExisting = isExisting, !isExisting else { error?.presentPopup(for: self, description: SpotifyErrorCodeDescription.checkPlaylist.rawValue); return; }
                    self.createPlaylistSpotify()
                    FirebaseDatabaseHelper.deleteAllTracks(user: self.spotifyHandler.user.canonicalUserName, deleteTracksCompleteHandler: nil)
                })
            }
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
    
    @objc fileprivate func handleNotificationSong() {
        guard let suggestedTrackId = UserDefaults.standard.string(forKey: "suggestedSpotifyTrackId") else { return; }
        if let parent = UIApplication.shared.keyWindow?.rootViewController as? NusicPageViewController, let songPickerVC = parent.songPickerVC {
            parent.scrollToViewController(viewController: songPickerVC)
        }
        self.isMoodSelected = false
        self.moodObject = NusicMood(emotions: [.init(basicGroup: .unknown, detailedEmotions: [], rating: 0)], isAmbiguous: false, sentiment: 0.5, date: Date(), associatedGenres: [], associatedTracks: [])
        spotifyHandler.getTrackInfo(for: [suggestedTrackId], offset: 0, currentExtractedTrackList: [], trackInfoListHandler: { (tracks, error) in
            guard let track = tracks else { error?.presentPopup(for: self); return; }
            UserDefaults.standard.removeObject(forKey: "suggestedSpotifyTrackId")
            UserDefaults.standard.synchronize()
            track.first?.suggestedSong = true
            self.selectedSongsForGenre[EmotionDyad.unknown.rawValue] = track
            DispatchQueue.main.async {
                self.passDataToShowSong()
            }
            
        })
    }

    fileprivate func fetchFavoriteGenres() {
        self.nusicUser.getFavoriteGenres(getGenresHandler: { (dbGenreCount, error) in
            guard let dbGenreCount = dbGenreCount else { error?.presentPopup(for: self); return; }
            if dbGenreCount.count > 0 {
                self.spotifyHandler.genreCount = dbGenreCount;
                self.nusicUser.saveFavoriteGenres(saveGenresHandler: { (isSaved, error) in
                    if let error = error {
                        error.presentPopup(for: self)
                    }
                });
            } else {
                self.spotifyHandler.genreCount = Spotify.getAllValuesDict()
            }
            self.loadingFinished = true;
        })
    }

}


extension SongPickerViewController: UIGestureRecognizerDelegate {
    
    @objc final func panCollectionViews(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view!)
        let divisor = gestureRecognizer.view != nil ? gestureRecognizer.view!.frame.width : 200
        var progress = (translation.x / divisor )
        let panDirection: UISwipeGestureRecognizerDirection = translation.x < 0 ? .left : .right;
        progress = CGFloat(fminf(fmaxf(Float(abs(progress)), 0.0), 1.0))
        var toIndex = panDirection == .left ? nusicControl.selectedIndex + 1 : nusicControl.selectedIndex - 1
        var allowMove = true
        
        if toIndex < 0 {
            toIndex = 0
            allowMove = panDirection == .right ? false : true
        } else if toIndex > nusicControl.items.count - 1 {
            toIndex = nusicControl.items.count - 1
            allowMove = panDirection == .left ? false : true
        }
        
        switch gestureRecognizer.state {
        case .began:
            break
        case .changed:
            if allowMove {
                segmentedControlMove(progress, toIndex);
            }
        case .cancelled:
            segmentedControlMove(1, nusicControl.selectedIndex)
        case .ended:
            if progress > 0.5 {
                nusicControl.move(to: toIndex)
                nusicControl.delegate?.didSelect(toIndex)
            } else {
                nusicControl.delegate?.didSelect(nusicControl.selectedIndex)
            }
            
        default:
            break
        }
    }

}


