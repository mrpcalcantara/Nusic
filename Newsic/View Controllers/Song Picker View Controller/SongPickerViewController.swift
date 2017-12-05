//
//  ViewController.swift
//  Newsic
//
//  Created by Miguel Alcantara on 28/08/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

//import AVKit
//import MediaPlayer
import PopupDialog
import UIKit
import SwiftSpinner

class SongPickerViewController: NewsicDefaultViewController {
    
    var genreList:[SpotifyGenres] = SpotifyGenres.allShownValues;
    let itemsPerRow: CGFloat = 2;
    let sectionInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8);
    var sectionTitles: [String] = []
    var sectionGenres: [[SpotifyGenres]] = [[]]
    var sectionHeaderFrame: CGRect = CGRect(x: 16, y: 8, width: 0, height: 0)
    var currentSection: Int = 0
    let numberOfCards:Int = 1;
    let numberOfSongs:Int = 5;
    var dataSource: [UIImage] = {
        var array: [UIImage] = []
        for index in 0..<1 {
            array.append(UIImage(named: "Test")!)
        }
        
        return array
    }()
    let username = "81d1a191-5d1e-47df-934a-c4bf91b63dd0"
    let password = "Ibls3Rzrbuy0"
    var spotifyHandler = Spotify();
    var songImage: UIImage! = UIImage(named: "Test");
    
    var moodObject: NewsicMood? = nil;
    var genres:[NewsicGenre]! = nil
    var newsicUser: NewsicUser! = nil {
        didSet {
            self.usernameLabel.text = newsicUser.displayName;
            if let imageURL = self.spotifyHandler.user.smallestImage.imageURL {
                let parent = self.parent as! NewsicPageViewController
                let sideMenu = parent.sideMenuVC as! SideMenuViewController
                
                sideMenu.username = self.newsicUser.displayName
                sideMenu.profileImageURL = imageURL
                let iconImage = UIImage(); iconImage.downloadImage(from: imageURL, downloadImageHandler: { (image) in
                    DispatchQueue.main.async {
                        
//                        self.setupNavigationBar(image: image)
                    }
                    
                })
                
            }
            
        }
    }
    var newsicPlaylist: NewsicPlaylist! = nil;
    var moodHacker: MoodHacker? = nil;
    var user: SPTUser? = nil;
    var selectedGenres: [String: Int] = [:]
    var isMoodSelected: Bool = true;
    var isMenuOpen: Bool = false
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
    
    //Outlets
    @IBOutlet weak var mainControlView: UIView!
    @IBOutlet weak var moodText: UITextView!
    @IBOutlet weak var moodCollectionView: UICollectionView!
    @IBOutlet weak var moodGenreSegmentedControl: UISegmentedControl!
    @IBOutlet weak var genreCollectionView: UICollectionView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var newsicControl: NewsicSegmentedControl!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var logoutButton: UIButton!
    
    
    //Actions
    
    @IBAction func logoutClicked(_ sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: "SpotifySession");
        UserDefaults.standard.synchronize();
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SpotifyLogin") as! SpotifyLoginViewController
        self.present(viewController, animated: true, completion: nil);
    }
    
    @IBAction func getNewSong(_ sender: Any) {
        
        UIView.animate(withDuration: 0.2, animations: {
            self.searchButton.titleLabel?.bounds.origin.x = self.view.frame.width + 8;
        }, completion: nil)
        
        let spinnerLabel = "Loading.."
        DispatchQueue.main.async {
            SwiftSpinner.show(spinnerLabel, animated: true);
        }
        self.searchButton.isUserInteractionEnabled = false;
        if !isMoodSelected {
            var newsicMood = NewsicMood();
            newsicMood.emotions = [Emotion(basicGroup: .unknown, detailedEmotions: [], rating: 0)]
            self.moodObject = newsicMood;
        }
        
        self.searchButton.isUserInteractionEnabled = true;
        
        self.moodObject?.userName = self.spotifyHandler.auth.session.canonicalUsername!
        self.moodObject?.saveData(saveCompleteHandler: { (reference, error) in  })
        
        passDataToShowSong();
        //self.performSegue(withIdentifier: showVideoSegue, sender: self);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        genreCollectionView.layoutIfNeeded()
        moodCollectionView.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //SwiftSpinner.show("Loading...", animated: true);
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupNavigationBar()
        setupCollectionCellViews();
        setupSegmentedControl()
        setupMenuView();
        setupCollectionViewTapGestureRecognizer();
        moodHacker = MoodHacker()
        
        extractInformationFromUser { (isFinished) in
            print(isFinished)
        }
        
    }
    
    
    func setupSegmentedControl() {
        self.newsicControl.selectedIndex = 0
        self.newsicControl.delegate = self
        toggleCollectionViews(for: 0);
    }
    
    func setupNavigationBar(image: UIImage? = UIImage(named: "MenuIcon")) {
        let navbar  = UINavigationBar(frame: CGRect(x: 0, y: 20, width: self.view.frame.width, height: 44));
        navbar.barStyle = .default
        
        let barButton2 = UIBarButtonItem(image: image!, style: .plain, target: self, action: #selector(toggleMenu));
        self.navigationItem.leftBarButtonItem = barButton2
        
        let navItem = self.navigationItem
        navbar.items = [navItem]
        
        self.view.addSubview(navbar)
    }
    
    func setupView() {
        
        //self.mainControlView.layer.zPosition = -1
        self.mainControlView.backgroundColor = UIColor.clear
        self.genreCollectionView.backgroundColor = UIColor.clear
        self.moodCollectionView.backgroundColor = UIColor.clear
        self.newsicControl.backgroundColor = UIColor.clear
        self.newsicControl.layer.zPosition = 1
        self.searchButton.backgroundColor = UIColor.clear
        
        moodCollectionView.layer.zPosition = -1
        genreCollectionView.layer.zPosition = -1
        
        self.mainControlView.bringSubview(toFront: newsicControl)
        
        let collectionViewsPanGestureRecoginizer = UIPanGestureRecognizer(target: self, action: #selector(panCollectionViews(_:)))
        self.mainControlView.addGestureRecognizer(collectionViewsPanGestureRecoginizer)
    }
    
    func setupMenuView() {
        self.menuLeadingConstraint.constant = -(5*self.view.frame.width)/6;
        self.menuTrailingConstraint.constant = self.view.frame.width
        self.view.layoutIfNeeded()
        
        userProfileImageView.contentMode = .scaleAspectFit;
    }
    
    @objc func toggleMenu() {
        let parent = self.parent as! NewsicPageViewController
        parent.scrollToViewController(index: 0)
    }
    
    func openMenu() {
        isMenuOpen = true
        self.mainControlView.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.menuLeadingConstraint.constant = 0
            self.menuTrailingConstraint.constant = self.view.frame.width/6;
            self.mainControlView.alpha = 0.1
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    func closeMenu() {
        isMenuOpen = false
        self.mainControlView.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.menuLeadingConstraint.constant = -(5*self.view.frame.width)/6;
            self.menuTrailingConstraint.constant = self.view.frame.width
            self.mainControlView.alpha = 1;
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    func extractInformationFromUser(extractionHandler: @escaping (Bool) -> ()) {
        
        fullArtistList = [];
        //Get User Info
        DispatchQueue.main.async {
            
            SwiftSpinner.show("Getting User..", animated: true)
            
        }
        
        newsicPlaylist = NewsicPlaylist(userName: SPTAuth.defaultInstance().session.canonicalUsername);
        newsicPlaylist.getPlaylist { (playlist) in
            if playlist == nil {
                self.spotifyHandler.createNewsicPlaylist(playlistName: "Liked in Newsic", playlistCreationHandler: { (isCreated, playlist, error) in
                    if let error = error {
                        error.presentPopup(for: self, description: SpotifyErrorCodeDescription.createPlaylist.rawValue)
                    } else {
                        if let isCreated = isCreated {
                            if isCreated {
                                self.newsicPlaylist = playlist;
                                playlist?.saveData(saveCompleteHandler: { (reference, error) in
                                    
                                })
                            }
                        }
                    }
                })
            } 
        }
        
        
        self.spotifyHandler.getUser { (user, error) in
            if let error = error {
                error.presentPopup(for: self, description: SpotifyErrorCodeDescription.getUser.rawValue)
                self.loadingFinished = true
            } else {
                if let user = user {
                    self.spotifyHandler.user = user;
                    let username = user.canonicalUserName!
                    
                    let displayName = user.displayName != nil ? user.displayName : ""
                    let profileImage = user.smallestImage.imageURL.absoluteString
                    let territory = "";
                    self.newsicUser = NewsicUser(userName: username, displayName: displayName!, imageURL: profileImage, territory: territory)
                    self.moodObject?.userName = username;
                    self.newsicUser.getUser(getUserHandler: { (usernameDB) in
                        if usernameDB == "" {
                            self.newsicUser.saveUser();
                            self.extractGenresFromSpotify(genreExtractionHandler: { (isSuccessful) in
                                if !isSuccessful {
                                    if let error = error {
                                        error.presentPopup(for: self, description: SpotifyErrorCodeDescription.extractGenresFromUser.rawValue)
                                    }
                                }
                            })
                        } else {
                            DispatchQueue.main.async {
                                SwiftSpinner.show("Getting Favorite Genres..", animated: true);
                            }
                            self.newsicUser.getFavoriteGenres(getGenresHandler: { (dbGenreCount) in
                                if let dbGenreCount = dbGenreCount {
                                    self.spotifyHandler.genreCount = dbGenreCount;
                                    self.newsicUser.saveFavoriteGenres();
                                    self.loadingFinished = true;
                                }
                            })
                        }
                    })
                } else {
                    self.loadingFinished = true
                }
            }
        }
    }
    
    func extractGenresFromSpotify(genreExtractionHandler: @escaping (Bool) -> ()) {
        //Get Followed Artists
        SwiftSpinner.show("Extracting Followed Artists..", animated: true)
        spotifyHandler.getFollowedArtistsForUser(user: spotifyHandler.user, followedArtistsHandler: { (followedArtistsList, error) in
            if let error = error {
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
            self.spotifyHandler.getAllPlaylists(fetchedPlaylistsHander: { (playlistList, error) in
                if let error = error {
                    genreExtractionHandler(false)
                }
                self.fullPlaylistList = playlistList
                //Get All Artists for each playlist
                print(self.fullPlaylistList.count)
                self.currentPlaylistIndex = 0;
                DispatchQueue.main.async {
                    SwiftSpinner.show("Extracting Artists from Playlists..", animated: true)
                }
                for playlist in self.fullPlaylistList {
                    let playlistId = playlist.uri.absoluteString.substring(from: (playlist.uri.absoluteString.range(of: "playlist:")?.upperBound)!)
                    self.spotifyHandler.getAllArtistsForPlaylist(userId: playlist.owner.canonicalUserName!, playlistId: playlistId, fetchedPlaylistArtists: { (results, error) in
                        if let error = error {
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
                                    self.newsicUser.favoriteGenres = NewsicGenre.convertGenreCountToGenres(userName: self.newsicUser.userName, dict: dict);
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == showVideoSegue {
            let playerViewController = segue.destination as! ShowSongViewController
            playerViewController.transitioningDelegate = self
            playerViewController.user = newsicUser;
            playerViewController.playlist = newsicPlaylist;
            playerViewController.spotifyHandler = spotifyHandler;
            playerViewController.moodObject = moodObject
            playerViewController.selectedGenreList = !selectedGenres.isEmpty ? selectedGenres : nil;
            playerViewController.isMoodSelected = isMoodSelected
            
            
        } else if segue.identifier == sideMenuSegue {
            let sideMenuViewController = segue.destination as! SideMenuViewController
            sideMenuViewController.profileImage = newsicUser.profileImage
            sideMenuViewController.username = newsicUser.displayName
        }
    }

}


extension SongPickerViewController: UIGestureRecognizerDelegate {
    
    @objc func panCollectionViews(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view!)
        let divisor = gestureRecognizer.view != nil ? gestureRecognizer.view!.frame.width : 200
        var progress = (translation.x / divisor )
        let panDirection: UISwipeGestureRecognizerDirection = translation.x < 0 ? .left : .right;
        progress = CGFloat(fminf(fmaxf(Float(abs(progress)), 0.0), 1.0))
        var toIndex = panDirection == .left ? newsicControl.selectedIndex + 1 : newsicControl.selectedIndex - 1
        var allowMove = true
        if toIndex < 0 {
            toIndex = 0
            allowMove = panDirection == .right ? false : true
        } else if toIndex > newsicControl.items.count - 1 {
            toIndex = newsicControl.items.count - 1
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
            segmentedControlMove(1, newsicControl.selectedIndex)
        case .ended:
            if progress > 0.5 {
                newsicControl.move(to: toIndex)
                newsicControl.delegate?.didSelect(toIndex)
            } else {
                newsicControl.delegate?.didSelect(newsicControl.selectedIndex)
            }
            
        default:
            break
        }
    }
}

extension SongPickerViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        for vc in pendingViewControllers {
            if vc is ShowSongViewController {
                print("SHOWING SONG")
            }
        }
    }
    
}

