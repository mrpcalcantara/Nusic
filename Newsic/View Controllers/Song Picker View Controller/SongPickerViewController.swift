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
    
    var genreList:[SpotifyGenres] = SpotifyGenres.allShownValues;
    let itemsPerRow: CGFloat = 2;
    let sectionInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8);
    var sectionTitles: [String] = []
    var sectionGenres: [[SpotifyGenres]] = [[]]
    var sectionHeaderFrame: CGRect = CGRect(x: 16, y: 8, width: 0, height: 0)
    var currentSection: Int = 0
    let username = "81d1a191-5d1e-47df-934a-c4bf91b63dd0"
    let password = "Ibls3Rzrbuy0"
    var spotifyHandler = Spotify();
    var moodObject: NusicMood? = nil;
    var genres:[NusicGenre]! = nil;
    var moods:[EmotionDyad]! = [] {
        didSet {
            moodCollectionView.reloadData();
        }
    }
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
            
        }
    }
    var nusicPlaylist: NusicPlaylist! = nil;
    var moodHacker: MoodHacker? = nil;
    var user: SPTUser? = nil;
    var selectedGenres: [String: Int] = [:] {
        didSet {
            if selectedGenres.count == 0 {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.searchButton.setTitle(self.isMoodCellSelected ? "Get Songs!" : "Random it up!", for: .normal)
                    }, completion: nil)
                }
//                listMenuView.removeFromSuperview()
                
            } else {
                
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.searchButton.setTitle("Get Songs!", for: .normal)
                    }, completion: nil)
                }
            }
            self.view.layoutIfNeeded()

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
    var fullArtistList:[SpotifyArtist] = [];
    var fullPlaylistList:[SPTPartialPlaylist] = []
    var currentPlaylistIndex: Int = 0
    var navbar: UINavigationBar = UINavigationBar()
    var loadingFinished: Bool = false {
        didSet {
            SwiftSpinner.show(duration: 2, title: "Done!", animated: true)
        }
    }
    var spinner: SwiftSpinner! = nil
    var listMenuView: ChoiceListView! = nil
    var viewRotated:Bool = false
    var cellsPerRow: CGFloat = 0
    
    //Segues
    let sideMenuSegue = "showSideMenuSegue"
    let showVideoSegue = "showVideoSegue"
    
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
    @IBOutlet weak var nusicControl: NusicSegmentedControl!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var logoutButton: UIButton!
    
    
    //Actions
    
    @IBAction func getNewSong(_ sender: Any) {
        if !isMoodSelected {
            var nusicMood = NusicMood();
            nusicMood.emotions = [Emotion(basicGroup: .unknown, detailedEmotions: [], rating: 0)]
            self.moodObject = nusicMood;
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
        genreCollectionView.collectionViewLayout.invalidateLayout()
        moodCollectionView.collectionViewLayout.invalidateLayout()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if navbar.frame.origin.y != self.view.safeAreaLayoutGuide.layoutFrame.origin.y {
            setupNavigationBar()
        }
        
        if viewRotated {
            genreCollectionView.reloadData()
            moodCollectionView.reloadData()
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
//            searchButton.removeBlurEffect();
//            searchButton.addBlurEffect(style: .dark, alpha: 1)
            self.view.layoutIfNeeded()
            viewRotated = false
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        viewRotated = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        genreCollectionView.collectionViewLayout.invalidateLayout()
        moodCollectionView.collectionViewLayout.invalidateLayout()
        genreCollectionView.reloadData()
        moodCollectionView.reloadData()
        listMenuView.reloadView()
        setupNavigationBar()
        self.view.layoutIfNeeded()
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad SongPicker")
        if nusicUser == nil {
            DispatchQueue.main.async {
                SwiftSpinner.show("Getting User..", animated: true)
            }
            
            extractInformationFromUser { (isFinished) in
                print(isFinished)
                
            }
            self.setupCollectionCellViews();
            self.setupView()
            self.setupListMenu()
            self.setupSegmentedControl()
        }
        
    }
    
    func setupSegmentedControl() {
        self.nusicControl.selectedIndex = 0
        self.nusicControl.delegate = self
        toggleCollectionViews(for: 0);
    }
    
    func setupNavigationBar(image: UIImage? = UIImage(named: "SettingsIcon")) {
        if self.view.subviews.contains(navbar) {
            navbar.removeFromSuperview()
        }
        navbar = UINavigationBar(frame: CGRect(x: 0, y: self.view.safeAreaLayoutGuide.layoutFrame.origin.y, width: self.view.frame.width, height: 44));
        navbar.barStyle = .default
        
        let barButton = UIBarButtonItem(image: image!, style: .plain, target: self, action: #selector(toggleMenu));

        self.navigationItem.leftBarButtonItem = barButton
        
        if let pageViewController = parent as? NusicPageViewController {
            let showSongImage = UIImage(named: "PreferredPlayer")?.withRenderingMode(.alwaysTemplate)
            let barButton = UIBarButtonItem(image: showSongImage, style: .plain, target: self, action: #selector(goToShowSongVC));
            if pageViewController.orderedViewControllers.contains(pageViewController.showSongVC!) {
                barButton.tintColor = UIColor.white
                barButton.isEnabled = true
            } else {
                barButton.tintColor = UIColor.gray
                barButton.isEnabled = false
            }
            
            self.navigationItem.rightBarButtonItem = barButton
            
        }
        
        
        
        let navItem = self.navigationItem
        
//        navItem.titleView = NusicSegmentedControl(frame: (navItem.titleView?.bounds)!)
        navbar.items = [navItem]
        
        self.view.addSubview(navbar)
        self.navbar.setNeedsLayout()
    }
    
    func setupView() {
        
        self.mainControlView.backgroundColor = UIColor.clear
        self.genreCollectionView.backgroundColor = UIColor.clear
        self.moodCollectionView.backgroundColor = UIColor.clear
        self.nusicControl.backgroundColor = UIColor.clear
        self.nusicControl.layer.zPosition = 1
        self.searchButton.backgroundColor = UIColor.clear
        self.searchButton.setTitle("Random it up!", for: .normal)
        
        moodCollectionView.layer.zPosition = -1
        genreCollectionView.layer.zPosition = -1
        
        self.mainControlView.bringSubview(toFront: nusicControl)
        
        let collectionViewsPanGestureRecoginizer = UIPanGestureRecognizer(target: self, action: #selector(panCollectionViews(_:)))
        self.mainControlView.addGestureRecognizer(collectionViewsPanGestureRecoginizer)
    }
    
    @objc func toggleMenu() {
        let parent = self.parent as! NusicPageViewController
        parent.scrollToViewController(index: 0)
    }
    
    @objc func goToShowSongVC() {
        let parent = self.parent as! NusicPageViewController
        parent.scrollToViewController(index: parent.orderedViewControllers.count-1)
    }
    
    func manageViewControllerShowSong() {
        let pageVC = (self.parent as! NusicPageViewController)
        if SPTAudioStreamingController.sharedInstance().initialized {
            pageVC.addViewControllerToPageVC(viewController: pageVC.showSongVC!)
        } else {
            pageVC.removeViewControllerFromPageVC(viewController: pageVC.showSongVC!)
        }
    }
    
    func showMobileDataPopup(){
        let dialog = PopupDialog(title: "Warning!", message: "We detected that you are using mobile data and have set the app to not use this data. Please connect to a WiFi network or enable Mobile Data usage in the Settings.", transitionStyle: .zoomIn, gestureDismissal: false, completion: nil)
        
        dialog.addButton(DefaultButton(title: "Got it!", action: nil))
        
        self.present(dialog, animated: true, completion: nil)
    }
    
    func extractInformationFromUser(extractionHandler: @escaping (Bool) -> ()) {
        
        fullArtistList = [];
        
        
        //Get User Info
        self.spotifyHandler.getUser { (user, error) in
            if error != nil {
                self.showLoginErrorPopup()
                self.loadingFinished = true
            } else {
                if let user = user {
                    self.spotifyHandler.user = user;
                    FirebaseAuthHelper.handleSpotifyLogin(
                        accessToken: self.spotifyHandler.auth.session.accessToken,
                        user: self.spotifyHandler.user,
                        loginCompletionHandler: { (user, error) in
                            if let error = error {
                                self.showLoginErrorPopup()
                                self.loadingFinished = true
                            } else {
                                FirebaseDatabaseHelper.fetchAllMoods(user: self.spotifyHandler.user.canonicalUserName) { (dyadList, error) in
                                    self.moods = dyadList
                                }
                                let username = self.spotifyHandler.user.canonicalUserName!
                                let displayName = self.spotifyHandler.user.displayName != nil ? self.spotifyHandler.user.displayName : ""
                                let profileImage = self.spotifyHandler.user.smallestImage != nil ? self.spotifyHandler.user.smallestImage.imageURL.absoluteString : ""
                                let territory = self.spotifyHandler.user.territory != nil ? self.spotifyHandler.user.territory! : "";
                                let isPremium = self.spotifyHandler.user.product == SPTProduct.premium ? true : false
                                let user = NusicUser(userName: username, displayName: displayName!, imageURL: profileImage, territory: territory, isPremium: isPremium)
                                self.moodObject?.userName = username;
                                self.spotifyPlaylistCheck();
                                user.getUser(getUserHandler: { (fbUser, error) in
                                    if let error = error {
                                        error.presentPopup(for: self)
                                    }
                                    if fbUser == nil || fbUser?.userName == "" {
                                        self.nusicUser = user
                                        self.extractGenresFromSpotify(genreExtractionHandler: { (isSuccessful) in
                                            if !isSuccessful {
                                                if let error = error {
                                                    error.presentPopup(for: self, description: SpotifyErrorCodeDescription.extractGenresFromUser.rawValue)
                                                }
                                            }
                                        })
                                    } else {
                                        self.nusicUser = fbUser!
                                        
                                        DispatchQueue.main.async {
                                            SwiftSpinner.show("Getting Favorite Genres..", animated: true);
                                        }
                                        self.nusicUser.getFavoriteGenres(getGenresHandler: { (dbGenreCount, error) in
                                            if let error = error {
                                                error.presentPopup(for: self)
                                            }
                                            if let dbGenreCount = dbGenreCount {
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
                                            }
                                        })
                                    }
                                })
                            }
                    })
                    
                }
            }
        }
    }
    
    func extractGenresFromSpotify(genreExtractionHandler: @escaping (Bool) -> ()) {
        //Get Followed Artists
        SwiftSpinner.show("Extracting Followed Artists..", animated: true)
        spotifyHandler.getFollowedArtistsForUser(user: spotifyHandler.user, followedArtistsHandler: { (followedArtistsList, error) in
            if error != nil {
                genreExtractionHandler(false)
            }
            DispatchQueue.main.sync {
                for artist in followedArtistsList {
                    self.fullArtistList.append(artist)
                }
            }
            DispatchQueue.main.async {
                SwiftSpinner.show("Extracting Playlists..", animated: true)
            }
            //Get All Playlists from user
            self.spotifyHandler.getAllPlaylists(fetchedPlaylistsHandler: { (playlistList, error) in
                if error != nil {
                    genreExtractionHandler(false)
                }
                self.fullPlaylistList = playlistList
                //Get All Artists for each playlist
                self.currentPlaylistIndex = 0;
                DispatchQueue.main.async {
                    SwiftSpinner.show("Extracting Artists from Playlists..", animated: true)
                }
                for playlist in self.fullPlaylistList {
                    let playlistId = playlist.uri.absoluteString.substring(from: (playlist.uri.absoluteString.range(of: "playlist:")?.upperBound)!)
                    self.spotifyHandler.getAllArtistsForPlaylist(userId: playlist.owner.canonicalUserName!, playlistId: playlistId, fetchedPlaylistArtists: { (results, error) in
                        if error != nil {
                            genreExtractionHandler(false)
                        }
                        DispatchQueue.main.async {
                            SwiftSpinner.show("Extracting Genres..", animated: true)
                        }
                        self.spotifyHandler.getAllGenresForArtists(results, offset: 0, artistGenresHandler: { (artistList, error) in
                            
                            DispatchQueue.main.async {
                                if let artistList = artistList {
                                    for artist in artistList {
                                        self.fullArtistList.append(artist);
                                    }
                                }
                                
                                
                                self.currentPlaylistIndex += 1;
                                
                                if self.currentPlaylistIndex == self.fullPlaylistList.count {
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
                            
                        })
                    })
                }
                
            })
        })
    }
    
    func spotifyPlaylistCheck() {
        nusicPlaylist = NusicPlaylist(userName: self.spotifyHandler.user.canonicalUserName);
        nusicPlaylist.getPlaylist { (playlist, error) in
            if let error = error {
                error.presentPopup(for: self)
            }
            if playlist == nil {
                self.createPlaylistSpotify()
            } else {
                if let playlistId = playlist?.id {
                    self.spotifyHandler.checkPlaylistExists(playlistId: playlistId, playlistExistHandler: { (isExisting, error) in
                        if let error = error {
                            error.presentPopup(for: self, description: SpotifyErrorCodeDescription.checkPlaylist.rawValue)
                        } else {
                            if let isExisting = isExisting, !isExisting {
                                self.createPlaylistSpotify()
                                FirebaseDatabaseHelper.deleteAllTracks(user: self.nusicUser.userName, deleteTracksCompleteHandler: { (reference, error) in
                                    
                                })
                            }
                        }
                    })
                }
                
            }
        }
    }
    
    func createPlaylistSpotify() {
        self.spotifyHandler.createNusicPlaylist(playlistName: "Liked in Nusic", playlistCreationHandler: { (isCreated, playlist, error) in
            if let error = error {
                error.presentPopup(for: self, description: SpotifyErrorCodeDescription.createPlaylist.rawValue)
            } else {
                if let isCreated = isCreated {
                    if isCreated {
                        self.nusicPlaylist = playlist;
                        playlist?.addNewPlaylist(addNewPlaylistHandler: { (isAdded, error) in
                            if let error = error {
                                error.presentPopup(for: self)
                            }
                        })
                    }
                }
            }
        })
    }
    
}


extension SongPickerViewController: UIGestureRecognizerDelegate {
    
    @objc func panCollectionViews(_ gestureRecognizer: UIPanGestureRecognizer) {
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


