//
//  ViewController.swift
//  Newsic
//
//  Created by Miguel Alcantara on 28/08/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import AVKit
import MediaPlayer

import UIKit
import SwiftSpinner

class SongPickerViewController: NewsicDefaultViewController {
    
    var genreList:[SpotifyGenres] = SpotifyGenres.allShownValues;
    let itemsPerRow: CGFloat = 2;
    let sectionInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8);
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
                self.userProfileImageView.downloadedFrom(url: imageURL, contentMode: .scaleAspectFit, roundImage: true);
                self.newsicUser.profileImage?.downloadImage(from: imageURL, downloadImageHandler: { (image) in
                    self.userProfileImageView.image? = image!;
                    
                })
            } else {
                self.userProfileImageView.backgroundColor = UIColor.black
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
    var loadingFinished: Bool = false {
        didSet {
            newsicUser.saveFavoriteGenres();
//            print("treatment all finished")
//            print(spotifyHandler.genreCount)
            SwiftSpinner.show(duration: 2, title: "Done!", animated: true)
        }
    }
    
    var spinner: SwiftSpinner! = nil
    
    //Transition Delegate
    var customNavigationAnimationController = CustomNavigationAnimationController()
    let customInteractionController = CustomInteractionController()
    
    //Segues
    let sideMenuSegue = "showSideMenuSegue"
    let showVideoSegue = "showVideoSegue"
    
    //Constraints
    @IBOutlet weak var menuTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuLeadingConstraint: NSLayoutConstraint!
    
    
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
        //self.navigationController?.popViewController(animated: true);
    }
    
    func swipeToShowOtherCollectionView(sender: UISwipeGestureRecognizer) {
        if sender.direction == .right {
            if !isMoodSelected {
                toggleCollectionViews(for: 1)
                DispatchQueue.main.async {
                    UIView.transition(from: self.moodCollectionView, to: self.genreCollectionView, duration: 1, options: [.transitionFlipFromLeft, .showHideTransitionViews], completion: nil)
                }
                
            }
        } else if sender.direction == .left {
            if isMoodSelected {
                toggleCollectionViews(for: 0)
                DispatchQueue.main.async {
                    UIView.transition(from: self.genreCollectionView, to: self.moodCollectionView, duration: 1, options: [.transitionFlipFromRight, .showHideTransitionViews], completion: nil)
                }
                
            }
        }
    }
    
    @IBAction func moodGenreControlClicked(_ sender: NewsicSegmentedControl) {
        toggleCollectionViews(for: sender.selectedIndex)
    }
    
    @IBAction func moodGenreSCClicked(_ sender: UISegmentedControl) {
        toggleCollectionViews(for: sender.selectedSegmentIndex)
    }
    
    @IBAction func getNewSong(_ sender: Any) {
        
        
        UIView.animate(withDuration: 0.2, animations: {
            //self.searchButton.titleLabel?.frame.origin.x = self.view.frame.width + 8;
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
        
        self.performSegue(withIdentifier: showVideoSegue, sender: self);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        customNavigationAnimationController.slideDirection = .right
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //SwiftSpinner.show("Loading...", animated: true);
    }
//
//    lazy var playerQueue : AVQueuePlayer = {
//        return AVQueuePlayer()
//    }()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupCollectionCellViews();
        setupSegmentedControl()
        setupMenuView();
        setupTransitionDelegate();
        //navigationController?.delegate = self
        //hideKeyboardWhenTappedAround();
        setupCollectionViewTapGestureRecognizer();
        moodHacker = MoodHacker()
        
        extractInformationFromUser { (isFinished) in
            print(isFinished)
        }
        
        
//        let urlstring = "http://radio.spainmedia.es/wp-content/uploads/2015/12/tailtoddle_lo4.mp3"
//        let url = URL(string: urlstring)
//        print("the url = \(url!)")
//
//        if let url = url { //this is an URL fetch from somewhere. In this if you make sure that URL is valid
//            let playerItem = AVPlayerItem.init(url: url)
//            self.playerQueue.insert(playerItem, after: nil)
//            self.playerQueue.play()
//
//            let trackInfo: [String: AnyObject] = [
//
//                MPMediaItemPropertyTitle: "titke" as AnyObject,
//                MPMediaItemPropertyArtist: "artist" as AnyObject,
//                MPNowPlayingInfoPropertyElapsedPlaybackTime: 0 as AnyObject,
//                MPMediaItemPropertyPlaybackDuration: 124 as AnyObject,
//                MPNowPlayingInfoPropertyPlaybackRate: 1 as AnyObject
//            ]
//
//            MPNowPlayingInfoCenter.default().nowPlayingInfo = trackInfo as [String : AnyObject]
//        }
//
//        do {
//
//
//        } catch let error as NSError {
//            //self.player = nil
//            print(error.localizedDescription)
//        } catch {
//            print("AVAudioPlayer init failed")
//        }
        
    }
    
    
    func setupSegmentedControl() {
        self.newsicControl.selectedIndex = 0
        toggleCollectionViews(for: 0);
    }
    
    func setupView() {
        self.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "MenuIcon"), for: .normal)
        button.addTarget(self, action: #selector(toggleMenu), for: UIControlEvents.touchUpInside)
        let barButton = UIBarButtonItem(customView: button);
        self.navigationItem.leftBarButtonItem = barButton
        
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

//        
//        let screenEdgeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(toggleMenu))
//        screenEdgeGesture.edges = .left
//        self.view.addGestureRecognizer(screenEdgeGesture)
        /*
        let leftSwipeCollectionsRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeToShowOtherCollectionView(sender:)))
        leftSwipeCollectionsRecognizer.direction = .left
        self.mainControlView.addGestureRecognizer(leftSwipeCollectionsRecognizer);
        
        let rightSwipeCollectionsRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeToShowOtherCollectionView(sender:)))
        rightSwipeCollectionsRecognizer.direction = .right
        self.mainControlView.addGestureRecognizer(rightSwipeCollectionsRecognizer);
        */
    }
    
    func setupMenuView() {
        self.menuLeadingConstraint.constant = -(5*self.view.frame.width)/6;
        self.menuTrailingConstraint.constant = self.view.frame.width
        self.view.layoutIfNeeded()
        
        userProfileImageView.contentMode = .scaleAspectFit;
    }
    
    @objc func toggleMenu() {
        customNavigationAnimationController.slideDirection = .left
        self.performSegue(withIdentifier: sideMenuSegue, sender: self);
//
//        if !isMenuOpen {
//            openMenu();
//        } else {
//            closeMenu();
//        }
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
                self.spotifyHandler.createNewsicPlaylist(playlistName: "Liked in Newsic", playlistCreationHandler: { (isCreated, playlist) in
                    if isCreated! {
                        self.newsicPlaylist = playlist;
                        playlist?.saveData(saveCompleteHandler: { (reference, error) in
                            
                        })
                    }
                })
            } 
        }
        
        
        self.spotifyHandler.getUser { (user) in
            if let user = user {
                self.spotifyHandler.user = user;
                let username = user.canonicalUserName!
                
                let displayName = user.displayName != nil ? user.displayName : ""
                let profileImage = user.smallestImage.imageURL.absoluteString
                let territory = "";
                self.newsicUser = NewsicUser(userName: username, displayName: displayName!, imageURL: profileImage, territory: territory)
                self.moodObject?.userName = username;
                self.newsicUser.getUser(getUserHandler: { (usernameDB) in
//                    print(usernameDB);
                    if usernameDB == "" {
                        self.newsicUser.saveUser();
                        self.extractGenresFromSpotify();
                    } else {
                        DispatchQueue.main.async {
                            SwiftSpinner.show("Getting Favorite Genres..", animated: true);
                        }
                        self.newsicUser.getFavoriteGenres(getGenresHandler: { (dbGenreCount) in
                            if let dbGenreCount = dbGenreCount {
                                self.spotifyHandler.genreCount = dbGenreCount;
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
    
    func extractGenresFromSpotify() {
        //Get Followed Artists
        SwiftSpinner.show("Extracting Followed Artists..", animated: true)
        spotifyHandler.getFollowedArtistsForUser(user: spotifyHandler.user, followedArtistsHandler: { (followedArtistsList) in
            DispatchQueue.main.sync {
                for artist in followedArtistsList {
                    self.fullArtistList.append(artist)
                }
            }
            DispatchQueue.main.async {
                SwiftSpinner.show("Extracting Playlists..", animated: true)
            }
            //Get All Playlists from user
            self.spotifyHandler.getAllPlaylists(fetchedPlaylistsHander: { (playlistList) in
                self.fullPlaylistList = playlistList
                //Get All Artists for each playlist
                print(self.fullPlaylistList.count)
                self.currentPlaylistIndex = 0;
                DispatchQueue.main.async {
                    SwiftSpinner.show("Extracting Artists from Playlists..", animated: true)
                }
                for playlist in self.fullPlaylistList {
                    let playlistId = playlist.uri.absoluteString.substring(from: (playlist.uri.absoluteString.range(of: "playlist:")?.upperBound)!)
                    self.spotifyHandler.getAllArtistsForPlaylist(userId: playlist.owner.canonicalUserName!, playlistId: playlistId, fetchedPlaylistArtists: { (results) in
                        
                        self.spotifyHandler.getAllGenresForArtists(results, offset: 0, artistGenresHandler: { (artistList) in
                            
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

extension SongPickerViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        //location is relative to the current view
        // do something with the touched point
        if let view = touch?.view {
            if view == moodCollectionView {
                let moodView = moodCollectionView
                if let moodView = moodView {
                    let location = touch?.location(in: moodView)
                    if let location = location {
                        let indexPath = moodView.indexPathForItem(at: location)
                        if let indexPath = indexPath {
                            moodView.delegate?.collectionView!(moodView, didSelectItemAt: indexPath)
                            print(location)
                        }
                    }
                }
                
            }
            
            if view == genreCollectionView {
                let moodView = genreCollectionView
                if let moodView = moodView {
                    let location = touch?.location(in: moodView)
                    if let location = location {
                        let indexPath = moodView.indexPathForItem(at: location)
                        if let indexPath = indexPath {
                            moodView.delegate?.collectionView!(moodView, didSelectItemAt: indexPath)
                            print(location)
                        }
                    }
                }
            }
        }
    }
}
