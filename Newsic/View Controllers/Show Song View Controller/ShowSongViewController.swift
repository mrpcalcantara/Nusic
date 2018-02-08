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
            sortTableView(by: songListTableViewHeader.currentSortElement)
            DispatchQueue.main.async {
                self.songListTableView.reloadData()
                self.songListTableView.layoutIfNeeded()
            }
        }
    }
    var preferredPlayer: NusicPreferredPlayer?
    var musicSearchType: NusicTrackSearch = .normal
    var moodObject: NusicMood? = nil;
    var currentMoodDyad: EmotionDyad? = EmotionDyad.unknown
    
    //Spotify
    var player: SPTAudioStreamingController?
    var spotifyHandler: Spotify! = nil;
    var auth: SPTAuth! = nil;
    var isPlaying: Bool = false;
    var selectedGenreList: [String: Int]? = nil
    var selectedSongs: [SpotifyTrack]? = nil
    var currentPlayingTrack: SpotifyTrack?
    var playedSongsHistory: [SpotifyTrack]? = []
    var trackFeatures: [SpotifyTrackFeature]? = nil
    var searchBasedOnArtist: SpotifyArtist?
    var searchBasedOnTrack: SpotifyTrack?
    var searchBasedOnGenres: [String: Int]?
    
    
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
    var currentSongCardFrame: CGRect? = nil {
        didSet {
            addCardBorderLayer()
        }
    }
    var showMoreOpenPosition: CGPoint? = nil
    var showMoreClosePosition: CGPoint? = nil
    var songListMenuProgress: CGFloat! = 0;
    var initialSwipeLocation: CGPoint! = CGPoint.zero
    var dismissProgress: CGFloat! = 0
    var seguePerformed: Bool = false;
    var newMoodOrGenre: Bool = true
    
    //Table View
    var sectionTitles: [String?] = []
    var sectionSongs: [[NusicTrack]] = []
    
    
    //Constraints
    @IBOutlet weak var tableViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var songCardLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var songCardTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var songCardBottomConstraint: NSLayoutConstraint!
    
    //Show More
    @IBOutlet weak var showMoreCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var showMoreTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var showMoreBottomConstraint: NSLayoutConstraint!

    //Next Track
    @IBOutlet weak var nextTrackCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var nextTrackTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var nextTrackBottomConstraint: NSLayoutConstraint!

    //Previous Track
    @IBOutlet weak var previousTrackCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var previousTrackTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var previousTrackBottomConstraint: NSLayoutConstraint!

    //Pause/Play Track
    @IBOutlet weak var pausePlayCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var pausePlayTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var pausePlayBottomConstraint: NSLayoutConstraint!

    //Like Song
    @IBOutlet weak var likeSongCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var likeSongTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var likeSongBottomConstraint: NSLayoutConstraint!

    //Dislike Song
    @IBOutlet weak var dislikeSongCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var dislikeSongTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var dislikeSongBottomConstraint: NSLayoutConstraint!

    //Song Progress View
    @IBOutlet weak var songProgressTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var songProgressBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var songProgressTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var songProgressLeadingConstraint: NSLayoutConstraint!

    
    
    //Storyboard Elements
    @IBOutlet weak var songCardView: SongKolodaView!
    @IBOutlet weak var songListTableView: UITableView!
    @IBOutlet weak var songListTableViewHeader: SongTableViewHeader!
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
    @IBOutlet weak var cardTitle: UILabel!
    
    
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
        } else {
            reloadNavigationBar()
            reloadPlayerMenu(for: self.view.safeAreaLayoutGuide.layoutFrame.size)
            if UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown {
                closeMenu()
            }
            if isPlayerMenuOpen {
                closePlayerMenu(animated: true)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        currentSongCardFrame = nil
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        
        if screenRotated {
            reloadNavigationBar()
            reloadPlayerMenu(for: self.view.safeAreaLayoutGuide.layoutFrame.size)
            screenRotated = false
        }
        
        if currentSongCardFrame != songCardView.frame {
            currentSongCardFrame = songCardView.frame
        }
        
        self.view.layoutIfNeeded()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if size.width > size.height {
            removeHeaderGestureRecognizer(for: songListTableViewHeader)
            removeMenuSwipeGestureRecognizer()
            
        } else {
            addHeaderGestureRecognizer(for: songListTableViewHeader)
            addMenuSwipeGestureRecognizer()
        }
        
        closeMenu()
        if isPlayerMenuOpen {
            closePlayerMenu(animated: true)
        }
        screenRotated = true
    }
    
    func setupConstraints(for size: CGSize) {
        //Landscape
//        print("songCardView.frame on setupConstraints \(songCardView.frame)")
        if size.width > size.height {
            self.songCardTrailingConstraint.constant = -size.width*(1/3)
            self.dislikeSongCenterXConstraint.constant = -size.width*(1/6)
            self.previousTrackCenterXConstraint.constant = -size.width*(1/6)
            self.pausePlayCenterXConstraint.constant = -size.width*(1/6)
            self.likeSongCenterXConstraint.constant = -size.width*(1/6)
            self.showMoreCenterXConstraint.constant = -size.width*(1/6)
            self.nextTrackCenterXConstraint.constant = -size.width*(1/6)
            self.songProgressTrailingConstraint.constant = -size.width*(1/3)
            self.tableViewLeadingConstraint.constant = size.width*(2/3)
            self.tableViewTrailingConstraint.constant = 0
            songListTableView.isUserInteractionEnabled = true
        } else {
            self.dislikeSongCenterXConstraint.constant = 0
            self.previousTrackCenterXConstraint.constant = 0
            self.pausePlayCenterXConstraint.constant = 0
            self.likeSongCenterXConstraint.constant = 0
            self.showMoreCenterXConstraint.constant = 0
            self.nextTrackCenterXConstraint.constant = 0
            self.songProgressTrailingConstraint.constant = 0
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
            setupNavigationBar()
            setupMoodLabel()
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
        if navbar != nil {
            navbar.removeFromSuperview()
        }
        navbar = UINavigationBar(frame: CGRect(x: 0, y: self.view.safeAreaLayoutGuide.layoutFrame.origin.y, width: self.view.frame.width, height: 44));
        navbar.barStyle = .default
        navbar.translatesAutoresizingMaskIntoConstraints = false
        
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
        
//        self.navigationItem.titleView = labelView
        
        let navItem = self.navigationItem
        navbar.items = [navItem]
        
        if !self.view.subviews.contains(navbar) {
            self.view.addSubview(navbar)
        }
        NSLayoutConstraint.activate([
            navbar.widthAnchor.constraint(equalToConstant: self.view.frame.width),
            navbar.heightAnchor.constraint(equalToConstant: 44),
            navbar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            navbar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            navbar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0)
            ])
        
        self.view.layoutIfNeeded()
    }
    
    func reloadNavigationBar() {
        if navbar != nil {
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
            
            //        self.navigationItem.titleView = labelView
            
            let navItem = self.navigationItem
            navbar.items = [navItem]
        }
    }
    
    func setupMenu() {
        
        self.view.sendSubview(toBack: trackStackView)
        self.view.sendSubview(toBack: songCardView)
        songListTableView.layer.zPosition = 1
        self.songListTableView.tableHeaderView?.frame = CGRect(x: (self.songListTableView.tableHeaderView?.frame.origin.x)!, y: -8, width: (self.songListTableView.tableHeaderView?.frame.width)!, height: (self.songListTableView.tableHeaderView?.frame.height)!)
        
        fetchLikedTracks()
        
    }
    
    func setupSongs() {
        musicSearchType = .normal
        if let selectedSongs = selectedSongs, selectedSongs.count > 0 {
            fetchYouTubeInfo()
        } else {
            if selectedGenreList == nil {
                getSongsForSelectedMood();
            } else {
                getSongsForSelectedGenres();
            }
        }
    }

    func setupMoodLabel() {
        cardTitle.text = moodObject?.emotions.first?.basicGroup == EmotionDyad.unknown ? "" : moodObject?.emotions.first?.basicGroup.rawValue
        cardTitle.font = NusicDefaults.font!
        cardTitle.textColor = NusicDefaults.foregroundThemeColor
        cardTitle.layoutIfNeeded()
        addCardBorderLayer()
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
        if isPlayerMenuOpen {
            closePlayerMenu(animated: false)
        }
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
                isMenuOpen = false;
                toggleSongMenu()
//                openMenu()
//                closePlayerMenu(animated: true)
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

extension ShowSongViewController {
    
    @objc func toggleSongMenu() {
        if !isMenuOpen {
            openMenu();
            if isPlayerMenuOpen {
                closePlayerMenu(animated: true)
            }
        } else {
            closeMenu();
        }
        songListMenuProgress = 0
    }
    
    @objc func backToSongPicker() {
        goToPreviousViewController()
    }
    
    @objc func updateAuthObject() {
        self.auth = (UIApplication.shared.delegate as! AppDelegate).auth
    }
    
    func fetchLikedTracks() {
        likedTrackList.removeAll()
        if moodObject?.emotions.first?.basicGroup == EmotionDyad.unknown {
            spotifyHandler.getAllTracksForPlaylist(playlistId: playlist.id!, fetchGenres: true) { (spotifyTracks, error) in
                if let error = error {
                    error.presentPopup(for: self, description: SpotifyErrorCodeDescription.getPlaylistTracks.rawValue)
                    
                } else {
                    
                    if let spotifyTracks = spotifyTracks {
                        
                        self.getYouTubeResults(tracks: spotifyTracks, youtubeSearchHandler: { (nusicTracks) in
                            self.likedTrackList = nusicTracks;
                        })
                    }
                }
            }
        } else {
            moodObject?.getTrackIdListForEmotionGenre(getAssociatedTrackHandler: { (trackList, error) in
                if let error = error {
                    error.presentPopup(for: self)
                }
                if let trackList = trackList {
                    self.spotifyHandler.getTrackInfo(for: trackList, offset: 0, currentExtractedTrackList: [], trackInfoListHandler: { (spotifyTracks, error) in
                        if let error = error {
                            error.presentPopup(for: self, description: SpotifyErrorCodeDescription.getTrackInfo.rawValue)
                        } else {
                            if let spotifyTracks = spotifyTracks {
                                
                                let spotifyArtistList = spotifyTracks.map({ $0.artist.uri }) as! [String]
                                self.spotifyHandler.getAllGenresForArtists(spotifyArtistList, offset: 0, artistGenresHandler: { (fetchedArtistList, error) in
                                    if let error = error {
                                        error.presentPopup(for: self, description: SpotifyErrorCodeDescription.getGenresForTrackList.rawValue)
                                    } else {
                                        if let fetchedArtistList = fetchedArtistList {
                                            for artist in fetchedArtistList {
                                                if let index = spotifyTracks.index(where: { (track) -> Bool in
                                                    return track.artist.uri == artist.uri
                                                }) {
                                                    spotifyTracks[index].artist = artist
                                                }
                                            }
                                        }
                                        self.getYouTubeResults(tracks: spotifyTracks, youtubeSearchHandler: { (nusicTracks) in
                                            self.likedTrackList = nusicTracks
                                        })
                                    }
                                })
                                
                            }
                        }
                    })
                }
            })
        }
    }
    
    func fetchSongsAndSetup(numberOfSongs: Int? = nil, moodObject: NusicMood?) {
        
        DispatchQueue.main.async {
            self.showSwiftSpinner(text: "Fetching tracks..")
        }
        
        let songCountToSearch = numberOfSongs == nil ? self.cardCount : numberOfSongs
        self.spotifyHandler.fetchRecommendations(for: .genres, numberOfSongs: songCountToSearch!, market: user.territory, moodObject: moodObject, preferredTrackFeatures: trackFeatures, selectedGenreList: self.selectedGenreList) { (results, error) in
            if let error = error {
                error.presentPopup(for: self, description: SpotifyErrorCodeDescription.getMusicInGenres.rawValue)
            }
            
            var nusicTracks:[SpotifyTrack] = [];
            for track in results {
                nusicTracks.append(track);
                self.playedSongsHistory?.append(track)
            }
            if nusicTracks.count == 0 {
                self.setupSongs();
            } else {
                self.getYouTubeResults(tracks: nusicTracks, youtubeSearchHandler: { (tracks) in
                    self.cardList = tracks
                    DispatchQueue.main.async {
                        self.songCardView.reloadData()
                        self.showSwiftSpinner(text: "Done!", duration: 2)
                    }
                    
                    
                })
            }
        }
    }
    
    func fetchYouTubeInfo() {
        
        DispatchQueue.main.async {
            self.showSwiftSpinner(text: "Fetching tracks..")
        }
        
        for track in selectedSongs! {
            self.playedSongsHistory?.append(track)
        }
        if selectedSongs!.count == 0 {
            self.setupSongs();
        } else {
            self.getYouTubeResults(tracks: selectedSongs!, youtubeSearchHandler: { (tracks) in
                self.cardList = tracks
                DispatchQueue.main.async {
                    self.songCardView.reloadData()
                    self.showSwiftSpinner(text: "Done!", duration: 2)
                }
            })
        }
    }
    
    func fetchNewCard(numberOfSongs: Int? = 1, cardFetchingHandler: ((Bool) -> ())?){
        
        let addSongsHandler: ([NusicTrack]) -> Bool = { trackList in
            self.addSongsToCardList(for: nil, tracks: trackList)
            return trackList.count > 0
        }
        
        let completionHandler: (Bool) -> Void = { isHandled in
            cardFetchingHandler!(isHandled);
        }
        
        fetchNewCardsFromSpotify { (tracks) in
            cardFetchingHandler?(addSongsHandler(tracks));
        }
        
    }
    
    func fetchNewCardsFromSpotify(numberOfSongs: Int? = 1, fetchedCardsHandler: @escaping ([NusicTrack]) -> ()) {
        switch musicSearchType {
        case NusicTrackSearch.normal:
            fetchNewCardNormal(numberOfSongs: numberOfSongs!, cardFetchingHandler: { (tracks) in
                fetchedCardsHandler(tracks)
            })
        case NusicTrackSearch.genre:
            fetchNewCardGenre(basedOnGenres: searchBasedOnGenres, numberOfSongs: numberOfSongs!, cardFetchingHandler: { (tracks) in
                fetchedCardsHandler(tracks)
            })
        case NusicTrackSearch.artist:
            fetchNewCardArtist(basedOnArtist: searchBasedOnArtist, numberOfSongs: numberOfSongs!, cardFetchingHandler: { (tracks) in
                fetchedCardsHandler(tracks)
            })
        case NusicTrackSearch.track:
            fetchNewCardTrack(basedOnTrack: searchBasedOnTrack, numberOfSongs: numberOfSongs!, cardFetchingHandler: { (tracks) in
                fetchedCardsHandler(tracks)
            })
        }
    }
    
    func fetchNewCardArtist(basedOnArtist: SpotifyArtist? = nil, numberOfSongs: Int, cardFetchingHandler: (([NusicTrack]) -> ())?) {
        var artist: SpotifyArtist = SpotifyArtist()
        if basedOnArtist != nil {
            artist = basedOnArtist!
        } else {
            if let currentArtist = currentPlayingTrack?.artist {
                artist = currentArtist
            }
        }
        
        if artist.id != nil {
            self.spotifyHandler.fetchRecommendations(for: .artist, numberOfSongs: numberOfSongs, market: user.territory, artists: [artist]) { (results, error) in
                if let error = error {
                    error.presentPopup(for: self, description: SpotifyErrorCodeDescription.getMusicInGenres.rawValue)
                }
                
                self.getYouTubeResults(tracks: results, youtubeSearchHandler: { (tracks) in
                    if let cardFetchingHandler = cardFetchingHandler {
                        cardFetchingHandler(tracks);
                    }
                })
                
            }
        } else {
            cardFetchingHandler!([])
        }
        
        
    }
    
    func fetchNewCardTrack(basedOnTrack: SpotifyTrack? = nil, numberOfSongs: Int, cardFetchingHandler: (([NusicTrack]) -> ())?) {
        var track: SpotifyTrack = SpotifyTrack()
        if basedOnTrack != nil {
            track = basedOnTrack!
        } else {
            if let currentTrack = currentPlayingTrack {
                track = currentTrack
            }
            track = currentPlayingTrack!
        }
        
        if track.trackId != nil {
            self.spotifyHandler.fetchRecommendations(for: .track, numberOfSongs: numberOfSongs, market: user.territory, tracks: [track]) { (results, error) in
                if let error = error {
                    error.presentPopup(for: self, description: SpotifyErrorCodeDescription.getMusicInGenres.rawValue)
                }
                
                self.getYouTubeResults(tracks: results, youtubeSearchHandler: { (tracks) in
                    if let cardFetchingHandler = cardFetchingHandler {
                        cardFetchingHandler(tracks);
                    }
                })
                
                
            }
        } else {
            cardFetchingHandler!([])
        }
        
    }
    
    func fetchNewCardGenre(basedOnGenres: [String : Int]? = nil, numberOfSongs: Int, insert inIndex: Int? = nil, cardFetchingHandler: (([NusicTrack]) -> ())?) {
        var genres: [String: Int]
        if basedOnGenres != nil {
            genres = basedOnGenres!
        } else {
            if let selectedGenreList = selectedGenreList {
                genres = selectedGenreList
            } else {
                return;
            }
            
        }
        
        if currentPlayingTrack != nil {
            
            self.spotifyHandler.fetchRecommendations(for: .genres, numberOfSongs: numberOfSongs, market: user.territory, moodObject: moodObject, selectedGenreList: genres) { (results, error) in
                if let error = error {
                    error.presentPopup(for: self, description: SpotifyErrorCodeDescription.getMusicInGenres.rawValue)
                }
                
                self.getYouTubeResults(tracks: results, youtubeSearchHandler: { (tracks) in
                    if let cardFetchingHandler = cardFetchingHandler {
                        cardFetchingHandler(tracks);
                    }
                })
                
            }
        } else {
            cardFetchingHandler!([])
        }
    }
    
    func fetchNewCardNormal(numberOfSongs: Int, cardFetchingHandler: (([NusicTrack]) -> ())?) {
        self.spotifyHandler.fetchRecommendations(for: .genres, numberOfSongs: numberOfSongs, market: user.territory, moodObject: moodObject, preferredTrackFeatures: trackFeatures, selectedGenreList: selectedGenreList) { (results, error) in
            if let error = error {
                error.presentPopup(for: self, description: SpotifyErrorCodeDescription.getMusicInGenres.rawValue)
            }
            var spotifyResults:[SpotifyTrack] = []
            for track in results {
                let containsCheck = self.playedSongsHistory?.contains(where: { (trackInHistory) -> Bool in
                    return trackInHistory.trackId == track.trackId
                })
                if !containsCheck! {
                    spotifyResults.insert(track, at: 0)
                }
            }
            
            if spotifyResults.count == 0 {
                self.spotifyHandler.fetchRecommendations(for: .genres, numberOfSongs: numberOfSongs, market: self.user.territory, moodObject: self.moodObject, completionHandler: { (results, error) in
                    if let cardFetchingHandler = cardFetchingHandler {
                        cardFetchingHandler([])
                    }
                })
            } else {
                self.getYouTubeResults(tracks: spotifyResults, youtubeSearchHandler: { (tracks) in
                    if let cardFetchingHandler = cardFetchingHandler {
                        cardFetchingHandler(tracks);
                    }
                })
            }
        }
    }
    
    func getSongsForSelectedMood() {
        updateCurrentGenresAndFeatures { (genres, trackFeatures) in
            self.fetchSongsAndSetup(moodObject: self.moodObject)
        }
    }
    
    func getSongsForSelectedGenres() {
        trackFeatures?.removeAll()
        fetchSongsAndSetup(moodObject: self.moodObject)
    }
    
    func getYouTubeResults(tracks: [SpotifyTrack], youtubeSearchHandler: @escaping ([NusicTrack]) -> ()) {
        var index = 0
        var ytTracks: [NusicTrack] = []
        for track in tracks {
            YouTubeSearch.getSongInfo(artist: Spotify.getFirstArtist(artistName: track.artist.artistName), songName: track.songName, completionHandler: { (youtubeInfo) in
                index += 1
                if let currentIndex = tracks.index(where: { (currentTrack) -> Bool in
                    return currentTrack.trackId == track.trackId
                }) {
                    
                    let nusicTrack = NusicTrack(trackInfo: tracks[currentIndex], moodInfo: self.moodObject, userName: self.user.userName, youtubeInfo: youtubeInfo);
                    
                    ytTracks.append(nusicTrack);
                }
                //                print("index: \(index) ==== \(track.title) -> trackId = \(youtubeInfo?.trackId)")
                
                if index == tracks.count {
                    youtubeSearchHandler(ytTracks)
                }
            })
        }
        
    }
    
    func updateCurrentGenresAndFeatures(updateGenresFeaturesHandler: @escaping ([String]?, [SpotifyTrackFeature]?) -> ()) {
        getGenresAndFeaturesForMoods(genresFeaturesHandler: { (genres, trackFeatures) in
            if let genres = genres {
                self.moodObject?.associatedGenres = genres
            }
            self.trackFeatures = trackFeatures;
            updateGenresFeaturesHandler(genres, trackFeatures);
        });
    }
    
    func getGenresAndFeaturesForMoods(genresFeaturesHandler: @escaping([String]?, [SpotifyTrackFeature]?) -> ()) {
        moodObject?.getTrackIdAndFeaturesForEmotion(trackIdAndFeaturesHandler: { (trackIdList, trackFeatures, error) in
            if let error = error {
                error.presentPopup(for: self)
            }
            if let trackIdList = trackIdList {
                self.spotifyHandler.getGenresForTrackList(trackIdList: trackIdList, trackGenreHandler: { (genres, error) in
                    if let error = error {
                        error.presentPopup(for: self, description: SpotifyErrorCodeDescription.getGenresForTrackList.rawValue)
                    } else {
                        if let genres = genres {
                            //print("GENRES EXTRACTED = \(genres)");
                            genresFeaturesHandler(genres, trackFeatures)
                            
                        } else {
                            genresFeaturesHandler(nil, trackFeatures);
                        }
                    }
                })
            } else {
                self.moodObject?.getDefaultTrackFeatures(getDefaultTrackFeaturesHandler: { (defaultTrackFeatures, error) in
                    if let error = error {
                        error.presentPopup(for: self)
                    }
                    if let defaultTrackFeatures = defaultTrackFeatures {
                        genresFeaturesHandler(nil, defaultTrackFeatures)
                    } else {
                        genresFeaturesHandler(nil, nil)
                    }
                })
                
            }
            
        })
    }
    
    func addSongsToCardList(for startIndex: Int?, tracks: [NusicTrack]) {
        for track in tracks {
            self.addSongToCardPlaylist(index: startIndex, track: track)
        }
        DispatchQueue.main.async {
            self.songCardView.reloadData();
        }
    }
    
    func getNextSong() {
        let handler: (Bool) -> Void = { didHandle in
            if self.songCardView.countOfVisibleCards < 3 || !didHandle {
                self.fetchNewCard(cardFetchingHandler: nil)
            }
            else {
                DispatchQueue.main.sync {
                    self.songCardView.reloadData()
                }
            }
        }
        
        fetchNewCard { (isFetched) in
            handler(isFetched);
        }
    }
    
    func playCard(at index:Int) {
        if preferredPlayer == NusicPreferredPlayer.spotify {
//            print("attempting to start track = \(cardList[index].trackInfo.songName)")
            actionPlaySpotifyTrack(spotifyTrackId: cardList[index].trackInfo.trackUri);
        }
    }
    
    func removeTrackFromLikedTracks(indexPath: IndexPath, removeTrackHandler: @escaping (Bool) -> ()) {
        
        let index = likedTrackList.count - indexPath.row-1
        let strIndex = String(index)
        
//        let track = likedTrackList[indexPath.row]
        let track = sectionSongs[indexPath.section][indexPath.row]
        
        let trackDict: [String: String] = [ strIndex : track.trackInfo.trackUri ]
        spotifyHandler.removeTrackFromPlaylist(playlistId: playlist.id!, tracks: trackDict) { (didRemove, error) in
            if let error = error {
                error.presentPopup(for: self, description: SpotifyErrorCodeDescription.removeTrack.rawValue)
            } else {
                track.deleteData(deleteCompleteHandler: { (ref, error) in
                    if error != nil {
                        removeTrackHandler(false)
                        print("ERROR DELETING TRACK");
                    } else {
                        self.sectionSongs[indexPath.section].remove(at: indexPath.row)
                        if let index = self.likedTrackList.index(where: { (likedTrack) -> Bool in
                            return likedTrack.trackInfo == track.trackInfo
                        }) {
                            self.likedTrackList.remove(at: index)
                        }
                        
                        removeTrackHandler(true);
                    }
                })
            }
        }
    }
    
    func addSongToCardPlaylist(index: Int? = nil, track: NusicTrack) {
//        print("added track = \(track.trackInfo.songName)")
        if index != nil {
            self.cardList.insert(track, at: index!)
        } else {
            self.cardList.append(track)
        }
        self.playedSongsHistory?.append(track.trackInfo)
    }
    
    func checkConnectivity() -> Bool {
        let title = "Error!"
        var message = ""
        if Connectivity.isConnectedToNetwork() == .notConnected {
            message = "No connectivity to the network. Please try again when you're connected to a network."
            let popup = PopupDialog(title: title, message: message, transitionStyle: .zoomIn, gestureDismissal: false, completion: nil);
            
            let backButton = DefaultButton(title: "OK", action: {
                self.dismiss(animated: true, completion: nil)
            })
            
            popup.addButton(backButton)
            self.present(popup, animated: true, completion: nil);
            return false
        }
        
        return true;
    }

}


