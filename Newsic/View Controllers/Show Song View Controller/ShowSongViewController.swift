//
//  ShowSongViewController.swift
//  Nusic
//
//  Created by Miguel Alcantara on 29/08/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit
import Koloda
import MediaPlayer
import SwiftSpinner
import PopupDialog


class ShowSongViewController: NusicDefaultViewController {
    
    //Views
    var isMenuOpen: Bool = false;
    var isPlayerMenuOpen: Bool = false;
    var navbar: UINavigationBar = UINavigationBar()
    var menuEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer!
    var screenRotated: Bool = false
    var playerMenuMaxWidth: CGFloat = 0
    
    //Nusic Objects
    var cardList:[NusicTrack] = [];
    var playlist:NusicPlaylist! = nil
    var user: NusicUser! = nil;
    var likedTrackList:[NusicTrack] = [] {
        didSet {
            DispatchQueue.main.async {
                self.songListTableView.reloadData()
                self.songListTableView.layoutIfNeeded()
            }
        }
    }
    var preferredPlayer: NusicPreferredPlayer?
    var musicSearchType: NusicSearch = .normal
    var moodObject: NusicMood? = nil;
    var currentMoodDyad: EmotionDyad? = EmotionDyad.unknown
    
    //Spotify
    var player: SPTAudioStreamingController?
    var spotifyHandler: Spotify! = nil;
    var auth: SPTAuth! = nil;
    var isPlaying: Bool = false;
    var selectedGenreList: [String: Int]? = nil
    var currentPlayingTrack: SpotifyTrack?
    var playedSongsHistory: [SpotifyTrack]? = []
    var trackFeatures: [SpotifyTrackFeature]? = nil
    
    //Koloda Cards
    var isSongLiked: Bool = false;
    var didUserSwipe: Bool = false;
    var presentedCardIndex: Int = 0;
    var playOnCellularData: Bool?
    var isMoodSelected: Bool = false;
    var shouldCompleteTransition: Bool = false;
    var cardCount = 10;
    var initialSongListCenter: CGPoint? = nil
    var initialPlayerMenuIconCenter: CGRect? = nil
    var currentSongCardFrame: CGRect? = nil
    var showMoreOpenPosition: CGPoint? = nil
    var showMoreClosePosition: CGPoint? = nil
    var songListMenuProgress: CGFloat! = 0;
    var initialSwipeLocation: CGPoint! = CGPoint.zero
    var dismissProgress: CGFloat! = 0
    var seguePerformed: Bool = false;
    var newMoodOrGenre: Bool = true
    
    
    //Constraints
    @IBOutlet weak var tableViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var songCardLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var songCardTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var songCardBottomConstraint: NSLayoutConstraint!
    
    
    
    @IBOutlet weak var songCardView: SongKolodaView!
    @IBOutlet weak var songListTableView: UITableView!
    @IBOutlet weak var trackStackView: UIStackView!
    @IBOutlet weak var previousSong: UIButton!
    @IBOutlet weak var pausePlay: UIButton!
    @IBOutlet weak var nextSong: UIButton!
    @IBOutlet weak var previousTrack: UIButton!
    @IBOutlet weak var nextTrack: UIButton!
    @IBOutlet weak var showMore: UIButton!
    @IBOutlet weak var songProgressView: UIView!
    @IBOutlet weak var songProgressSlider: UISlider!
    @IBOutlet weak var songDurationLabel: UILabel!
    @IBOutlet weak var songElapsedTime: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        setupShowSongVC()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.auth = (UIApplication.shared.delegate as! AppDelegate).auth
        
        if newMoodOrGenre {
            self.viewDidLoad()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if newMoodOrGenre {
            resetView()
            showSwiftSpinner()
            _ = checkConnectivity()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        closePlayerMenu(animated: true)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
//        print("viewWillLayoutSubviews() called, songCardView.frame = \(songCardView.frame)")
//        if let headerCell = songListTableView.headerView(forSection: 0) as? SongTableViewHeader {
//            if UIApplication.shared.statusBarOrientation.isLandscape {
//                removeHeaderGestureRecognizer(for: headerCell)
//                removeMenuSwipeGestureRecognizer()
//            } else {
//                addHeaderGestureRecognizer(for: headerCell)
//                addMenuSwipeGestureRecognizer()
//            }
//        }
        setShowMoreOrigin()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
//        print("viewDidLayoutSubviews() called, songCardView.frame = \(songCardView.frame)")
//         showMore.frame.origin = CGPoint(x: songCardView.frame.origin.x + songCardView.frame.size.width/2, y: songCardView.frame.height + songCardBottomConstraint.constant)
        if navbar.frame.origin.y != self.view.safeAreaLayoutGuide.layoutFrame.origin.y || navbar.frame.width != self.view.safeAreaLayoutGuide.layoutFrame.width {
            setupNavigationBar()
        }
        
        if screenRotated {
            
//            self.songCardView.reloadData()
            self.setupPlayerMenu()
//            self.view.layoutIfNeeded()
            screenRotated = false
            print("screen stop rotating")
        }
        
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if let headerCell = songListTableView.headerView(forSection: 0) as? SongTableViewHeader {
            if size.width > size.height {
                removeHeaderGestureRecognizer(for: headerCell)
                removeMenuSwipeGestureRecognizer()
            } else {
                addHeaderGestureRecognizer(for: headerCell)
                addMenuSwipeGestureRecognizer()
            }
        }
        setupConstraints(for: size)
        self.songCardView.layoutSubviews()
        closePlayerMenu(animated: true)
        closeMenu()
        screenRotated = true
        print("screen rotated")
    }
    
    func setupConstraints(for size: CGSize) {
        //Landscape
        print("songCardView.frame on setupConstraints \(songCardView.frame)")
        if size.width > size.height {
            self.songCardTrailingConstraint.constant = -size.width*(1/3)
            self.tableViewLeadingConstraint.constant = size.width*(2/3)
            self.tableViewTrailingConstraint.constant = 0
            songListTableView.isUserInteractionEnabled = true
        } else {
            self.songCardTrailingConstraint.constant = -8
            
        }
    }
    
    func setupShowSongVC() {
        
        if checkConnectivity() {
            preferredPlayer = user.settingValues.preferredPlayer
            showSwiftSpinner()
            setupMainView()
            setupMenu()
            setupCards()
            setupTableView()
            setupSongs()
            setupPlayerMenu()
            
            if preferredPlayer == NusicPreferredPlayer.spotify {
                setupSpotify()
                setupCommandCenter()
                UIApplication.shared.beginReceivingRemoteControlEvents()
            }
            
            NotificationCenter.default.addObserver(self, selector: #selector(updateAuthObject), name: NSNotification.Name(rawValue: "refreshSuccessful"), object: nil)
            
        }
        
        newMoodOrGenre = false
    }
    
    func setupMainView() {
        
        currentMoodDyad = moodObject?.emotions.first?.basicGroup
        addMenuSwipeGestureRecognizer()
        
        
    }
    
    func setupCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget(self, action: #selector(remoteControlSeekSong))
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget(self, action: #selector(remoteControlPlaySong))
        
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget(self, action: #selector(remoteControlPauseSong))
        
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget(self, action: #selector(actionNextSong))
        
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget(self, action: #selector(actionPreviousSong))
        
        //        commandCenter.likeCommand.isEnabled = true
        //        commandCenter.likeCommand.addTarget(self, action: #selector(likeSongClicked(_:)))
        //
    }
    
    func setupNavigationBar() {
        if self.view.subviews.contains(navbar) {
            navbar.removeFromSuperview()
        }
        navbar  = UINavigationBar(frame: CGRect(x: 0, y: self.view.safeAreaLayoutGuide.layoutFrame.origin.y, width: self.view.frame.width, height: 44));
        navbar.barStyle = .default
        
        let barButtonLeft = UIBarButtonItem(image: UIImage(named: "MoodIcon"), style: .plain, target: self, action: #selector(backToSongPicker));
        self.navigationItem.leftBarButtonItem = barButtonLeft
        
        let barButtonRight = UIBarButtonItem(image: UIImage(named: "MusicNote"), style: .plain, target: self, action: #selector(toggleSongMenu));
        
        if UIApplication.shared.statusBarOrientation.isLandscape {
            barButtonRight.isEnabled = false
        } else {
            barButtonRight.isEnabled = true
        }
        
        self.navigationItem.rightBarButtonItem = barButtonRight
        
        
        let labelView = UILabel()
        labelView.font = UIFont(name: "Futura", size: 20)
        labelView.textColor = UIColor.white
        if let currentMoodDyad = currentMoodDyad {
            labelView.text = currentMoodDyad == EmotionDyad.unknown ? "" : "Mood: \(currentMoodDyad.rawValue)"
        }
        
        self.navigationItem.titleView = labelView
        
        let navItem = self.navigationItem
        navbar.items = [navItem]
        self.view.insertSubview(navbar, at: 0)
        //        self.view.addSubview(navbar)
    }
    
    func setupMenu() {
        
        self.view.sendSubview(toBack: trackStackView)
        self.view.sendSubview(toBack: songCardView)
        songListTableView.layer.zPosition = 1
        self.songListTableView.tableHeaderView?.frame = CGRect(x: (self.songListTableView.tableHeaderView?.frame.origin.x)!, y: -8, width: (self.songListTableView.tableHeaderView?.frame.width)!, height: (self.songListTableView.tableHeaderView?.frame.height)!)
        
        fetchLikedTracks()
        
    }
    
    func setupSongs() {
        if selectedGenreList == nil {
            getSongsForSelectedMood();
        } else {
            getSongsForSelectedGenres();
        }
    }

    @IBAction func showMoreClicked(_ sender: UIButton) {
        togglePlayerMenu();
    }
    
    @IBAction func songSeek(_ sender: UISlider) {
        updateElapsedTime(elapsedTime: sender.value, duration: Float((currentPlayingTrack?.audioFeatures?.durationMs)!))
    }
    
    @IBAction func finishSeek(_ sender: UISlider) {
        if preferredPlayer == NusicPreferredPlayer.spotify {
            seekSong(interval: sender.value)
        } else {
            ytSeekTo(seconds: sender.value)
        }
    }
    
    @IBAction func previousTrackClicked(_ sender: UIButton) {
        
        sender.animateClick();
        songCardView.revertAction();
        
    }
    
    @IBAction func nextTrackClicked(_ sender: UIButton) {
        
        sender.animateClick();
        songCardView.swipe(.left)
        
    }
    
    @IBAction func dislikeSongClicked(_ sender: UIButton) {
        
        sender.animateClick();
        songCardView.swipe(.left)
        
    }
    
    @IBAction func likeSongClicked(_ sender: UIButton) {
        
        sender.animateClick();
        likeTrack(in: presentedCardIndex)
    }
    
    @IBAction func pausePlayClicked(_ sender: UIButton) {
        
        sender.animateClick();
        if preferredPlayer == NusicPreferredPlayer.spotify {
            spotifyPausePlay();
        } else {
            ytPausePlay()
        }
        
        
    }
    
    func showSwiftSpinner(delay: Double? = nil, text: String? = nil, duration: Double? = nil) {
        
        var spinnerText = ""
        if let text = text {
            spinnerText = text
            if let duration = duration {
                SwiftSpinner.show(duration: duration, title: spinnerText)
            } else if let delay = delay {
                let delayInSeconds = DispatchTime.now() + Double(Int64(Double(NSEC_PER_SEC) * delay )) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayInSeconds, execute: {
                    if SwiftSpinner.sharedInstance.animating {
                        SwiftSpinner.show(duration: 1, title: text, animated: true)
                    }
                })
            }
            else {
                SwiftSpinner.show(spinnerText, animated: true);
            }
            
        } else {
            if let currentMoodDyad = moodObject?.emotions.first?.basicGroup {
                
                if EmotionDyad.allValues.contains(currentMoodDyad) {
                    spinnerText = "Mood: \(currentMoodDyad.rawValue)"
                } else {
                    spinnerText = "Loading..."
                }
                
                SwiftSpinner.show(spinnerText, animated: true).addTapHandler({
                    self.goToPreviousViewController()
                    SwiftSpinner.hide()
                }, subtitle: "Tap to go the previous screen!")
            }
        }
    }
    
    func resetView() {
        self.cardList.removeAll();
        self.songCardView.resetCurrentCardIndex()
        self.songCardView.reloadData();
        
        if preferredPlayer == NusicPreferredPlayer.youtube {
            if let player = player, player.initialized {
                resetPlaybackDelegate()
                resetStreamingDelegate()
                actionStopPlayer()
            }
        }
    }

    func setShowMoreOrigin() {
        if currentSongCardFrame != songCardView.frame {
            currentSongCardFrame = songCardView.frame
            showMoreOpenPosition = CGPoint(x: songCardView.frame.origin.x + songCardView.frame.size.width/2, y: songCardView.frame.height + songCardBottomConstraint.constant)
            showMoreOpenPosition?.x = songCardView.frame.origin.x + songCardView.frame.size.width/2 - songCardLeadingConstraint.constant 
            
            showMoreOpenPosition?.y = self.preferredPlayer == NusicPreferredPlayer.spotify ? self.view.safeAreaLayoutGuide.layoutFrame.height * 0.84 - showMore.frame.width : self.view.safeAreaLayoutGuide.layoutFrame.height * 0.9 - showMore.frame.width
            showMoreClosePosition = CGPoint(x: songCardView.frame.origin.x + songCardView.frame.size.width/2, y: songCardView.frame.height + songCardBottomConstraint.constant)
            showMoreClosePosition?.x = (showMoreOpenPosition?.x)!
            showMoreClosePosition?.y = songCardView.frame.height + songCardBottomConstraint.constant
            initialPlayerMenuIconCenter = CGRect(origin: showMoreClosePosition!, size: showMore.frame.size)
            if isPlayerMenuOpen {
                self.showMore.frame.origin = self.showMoreOpenPosition!
            } else {
                self.showMore.frame.origin = self.showMoreClosePosition!
            }
            
        }
    }
}

extension ShowSongViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    
    
    @objc func handleMenuScreenGesture(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: view);
        let finalPoint = self.songListTableView.frame.width;
        
        if recognizer.state == .began {
            shouldCompleteTransition = false
        } else if recognizer.state == .changed {
            
            let translationX: CGFloat = translation.x
            if translation.x > 0 {
                self.tableViewLeadingConstraint.constant = self.view.frame.width/6 + translationX
                self.tableViewTrailingConstraint.constant = translationX * -1
                
                songListMenuProgress = (translation.x)/finalPoint
            } else {
                self.tableViewLeadingConstraint.constant = self.view.frame.width + translationX
                self.tableViewTrailingConstraint.constant = (self.view.frame.width) * (-5/6) - translationX
                
                songListMenuProgress = (translation.x * -1)/finalPoint;
            }
            
            songListMenuProgress = CGFloat(fminf(fmaxf(Float(songListMenuProgress), 0.0), 1.0))
            shouldCompleteTransition = translation.x > 0 && songListMenuProgress > CGFloat(0.25) ? true : false
            self.view.layoutIfNeeded();
            
        } else if recognizer.state == .ended {
            if shouldCompleteTransition {
                closeMenu()
            } else {
                openMenu()
                closePlayerMenu(animated: true)
            }
            songListMenuProgress = 0
        }
        
    }
    
    @objc func handleDismissSwipe(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        let touchPoint = gestureRecognizer.location(in: self.view)
        let finalPoint = self.view.frame.width
        let translation = gestureRecognizer.translation(in: self.view)
        
        if gestureRecognizer.state == .began {
            initialSwipeLocation = touchPoint
        } else if gestureRecognizer.state == .changed {
            self.view.frame = CGRect(x: translation.x, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            dismissProgress = CGFloat(fminf(fmaxf(Float(translation.x/finalPoint), 0.0), 1.0))
        } else if gestureRecognizer.state == .cancelled || gestureRecognizer.state == .ended {
            if dismissProgress > 0.5 {
                backToSongPicker();
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
                })
            }
        }
    }
    
}


