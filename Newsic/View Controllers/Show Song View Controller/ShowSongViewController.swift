//
//  ShowSongViewController.swift
//  Newsic
//
//  Created by Miguel Alcantara on 29/08/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit
import Koloda
import MediaPlayer
import SwiftSpinner


class ShowSongViewController: NewsicDefaultViewController {
    
    
    var user: NewsicUser! = nil;
    var player: SPTAudioStreamingController?
    var likedTrackList:[SpotifyTrack] = [] {
        didSet {
            DispatchQueue.main.async {
                self.songListTableView.reloadData()
                self.songListTableView.layoutIfNeeded()
            }
        }
    }
    var cardList:[NewsicTrack] = [];
    var playlist:NewsicPlaylist! = nil
    var spotifyHandler: Spotify! = nil;
    var auth: SPTAuth! = nil;
    var moodObject: NewsicMood? = nil;
    var currentMoodDyad: EmotionDyad? = EmotionDyad.unknown
    var trackFeatures: [SpotifyTrackFeature]? = nil
    var isPlaying: Bool = false;
    var isMenuOpen: Bool = false;
    var isPlayerMenuOpen: Bool = false;
    var isSongLiked: Bool = false;
    var isMoodSelected: Bool = false;
    var didUserSwipe: Bool = false;
    var shouldCompleteTransition: Bool = false;
    var cardCount = 10;
    var presentedCardIndex: Int = 0;
    var videoId: String! = "";
    var songArtist: String! = "";
    var songName: String! = "";
    var selectedGenreList: [String: Int]? = nil
    var initialSongListCenter: CGPoint? = nil
    var initialPlayerMenuIconCenter: CGRect? = nil
    var songListMenuProgress: CGFloat! = 0;
    var initialSwipeLocation: CGPoint! = CGPoint.zero
    var dismissProgress: CGFloat! = 0
    var seguePerformed: Bool = false;
    var swipeInteractionController: SwipeInteractionController?
    var currentPlayingTrack: SpotifyTrack?
    var playedSongsHistory: [SpotifyTrack]? = []
    //var songPosition: Double! = 0
    
    //Constraints
    @IBOutlet weak var tableViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var songCardLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var songCardView: SongKolodaView!
    @IBOutlet weak var songListTableView: UITableView!
    @IBOutlet weak var trackStackView: UIStackView!
    @IBOutlet weak var previousSong: UIButton!
    @IBOutlet weak var pausePlay: UIButton!
    @IBOutlet weak var nextSong: UIButton!
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var previousTrack: UIButton!
    @IBOutlet weak var nextTrack: UIButton!
    @IBOutlet weak var showMore: UIButton!
    @IBOutlet weak var songProgressView: UIView!
    @IBOutlet weak var songProgressSlider: UISlider!
    @IBOutlet weak var songDurationLabel: UILabel!
    @IBOutlet weak var songElapsedTime: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        setupMainView()
        setupTableView()
        setupNavigationBar()
        setupSpotify()
        setupSongs()
        setupMenu()
        setupCards()
        setupPlayerMenu()
        setupCommandCenter()
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showSwiftSpinner()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //        actionStopPlayer();
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        actionStopPlayer();
    
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
    }
    
    func setupMainView() {
        
        currentMoodDyad = moodObject?.emotions.first?.basicGroup
        
        swipeInteractionController = SwipeInteractionController(viewController: self)
        let screenEdgeRecognizerSongMenu = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleMenuScreenGesture(_:)))
        screenEdgeRecognizerSongMenu.edges = .right
        //        screenEdgeRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(screenEdgeRecognizerSongMenu);
        
        
    }
    
    func setupCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget(self, action: #selector(remoteControlSeekSong))
        
        //        commandCenter.togglePlayPauseCommand.isEnabled = true
        //        commandCenter.togglePlayPauseCommand.addTarget(self, action: #selector(actionPausePlay))
        
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
        
        //commandCenter.seekForwardCommand.isEnabled = true
        //commandCenter.seekBackwardCommand.isEnabled = true
        //        commandCenter.seekForwardCommand.addTarget(self, action: #selector(test))
    }
    
    func setupNavigationBar() {
        let navbar  = UINavigationBar(frame: CGRect(x: 0, y: 20, width: self.view.frame.width, height: 44));
        navbar.barStyle = .default
        navbar.tintColor = UIColor.white
        UINavigationBar.appearance().tintColor = UIColor.white
        
        let buttonLeft = UIButton(type: .system)
        buttonLeft.setImage(UIImage(named: "MoodIcon"), for: .normal)
        buttonLeft.addTarget(self, action: #selector(backToSongPicker), for: .touchUpInside)
        let barButtonLeft = UIBarButtonItem(customView: buttonLeft);
        self.navigationItem.leftBarButtonItem = barButtonLeft
        
        
        let buttonRight = UIButton(type: .system)
        buttonRight.setImage(UIImage(named: "MusicNote"), for: .normal)
        buttonRight.addTarget(self, action: #selector(toggleSongMenu), for: .touchUpInside)
        let barButtonRight = UIBarButtonItem(customView: buttonRight);
        
        self.navigationItem.rightBarButtonItem = barButtonRight
        
        let labelView = UILabel()
        labelView.font = UIFont(name: "Futura", size: 20)
        labelView.textColor = UIColor.white
        if let currentMoodDyad = currentMoodDyad {
            labelView.text = currentMoodDyad == EmotionDyad.unknown ? "" : "Mood: \(currentMoodDyad.rawValue)"
        }
        
        labelView.sizeToFit()
        self.navigationItem.titleView = labelView
        
        
        let navItem = self.navigationItem
        navbar.items = [navItem]
        self.view.addSubview(navbar)
    }
    
    func setupMenu() {
        
        self.view.sendSubview(toBack: trackStackView)
        self.view.sendSubview(toBack: songCardView)
        songListTableView.layer.zPosition = 1
        //self.view.sendSubview(toBack: buttonsStackView)
        self.songListTableView.tableHeaderView?.frame = CGRect(x: (self.songListTableView.tableHeaderView?.frame.origin.x)!, y: -8, width: (self.songListTableView.tableHeaderView?.frame.width)!, height: (self.songListTableView.tableHeaderView?.frame.height)!)
        
        //closeMenu()
        if moodObject?.emotions.first?.basicGroup == EmotionDyad.unknown {
            spotifyHandler.getAllTracksForPlaylist(playlistId: playlist.id!) { (spotifyTracks, error) in
                if let error = error {
//                    self.present(error.popupDialog!, animated: true, completion: nil)
//                    SwiftSpinner.hide()
                    error.presentPopup(for: self, description: SpotifyErrorCodeDescription.getPlaylistTracks.rawValue)
                    
                } else {
                    if let spotifyTracks = spotifyTracks {
                        self.likedTrackList = spotifyTracks;
                    }
                }
            }
        } else {
            moodObject?.getTrackIdListForEmotionGenre(getAssociatedTrackHandler: { (trackList) in
                if let trackList = trackList {
                    self.spotifyHandler.getTrackInfo(for: trackList, offset: 0, currentExtractedTrackList: [], trackInfoListHandler: { (spotifyTracks, error) in
                        if let error = error {
//                            self.present(error.popupDialog!, animated: true, completion: nil)
                            error.presentPopup(for: self, description: SpotifyErrorCodeDescription.getTrackInfo.rawValue)
                        } else {
                            if let spotifyTracks = spotifyTracks {
                                self.likedTrackList = spotifyTracks;
                                //                            DispatchQueue.main.async {
                                //                                self.songListTableView.reloadData()
                                //                                self.songListTableView.layoutIfNeeded()
                                //                            }
                                
                            }
                        }
                    })
                }
            })
        }
        
    }
    @IBAction func showMoreClicked(_ sender: UIButton) {
        togglePlayerMenu();
    }
    
    @IBAction func songSeek(_ sender: UISlider) {
        if sender.isTracking {
            //            print("CHANGED SLIDER VALUE")
            updateElapsedTime(elapsedTime: sender.value)
        } else {
            seekSong(interval: sender.value)
        }
    }
    
    
    @objc func toggleSongMenu() {
        let view = self.navigationItem.rightBarButtonItem?.customView as! UIButton;
        view.animateClick();
        if !isMenuOpen {
            openMenu();
            closePlayerMenu(animated: true)
        } else {
            closeMenu();
        }
        
        //isMenuOpen = !isMenuOpen;
    }
    
    
    
    func openMenu() {
        isMenuOpen = true
        self.songListTableView.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: .curveLinear, animations: {
            self.trackStackView.layer.zPosition = -1
            //            self.songListTableView.layer.zPosition = 1
            self.songListTableView.isUserInteractionEnabled = true
            self.songCardView.isUserInteractionEnabled = false
            self.previousSong.isUserInteractionEnabled = false
            self.pausePlay.isUserInteractionEnabled = false
            self.nextSong.isUserInteractionEnabled = false
            self.previousTrack.isUserInteractionEnabled = false
            self.nextTrack.isUserInteractionEnabled = false
            self.showMore.isUserInteractionEnabled = false
            self.songProgressSlider.isUserInteractionEnabled = false
            self.tableViewLeadingConstraint.constant = self.view.frame.width/6;
            self.tableViewTrailingConstraint.constant = 0
            self.trackStackView.alpha = 0.1
            
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func closeMenu() {
        //self.view.sendSubview(toBack: self.songListTableView);
        isMenuOpen = false
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: .curveLinear, animations: {
            self.trackStackView.layer.zPosition = 1
            self.songListTableView.isUserInteractionEnabled = false
            self.songCardView.isUserInteractionEnabled = true
            self.previousSong.isUserInteractionEnabled = true
            self.pausePlay.isUserInteractionEnabled = true
            self.nextSong.isUserInteractionEnabled = true
            self.previousTrack.isUserInteractionEnabled = true
            self.nextTrack.isUserInteractionEnabled = true
            self.showMore.isUserInteractionEnabled = true
            self.songProgressSlider.isUserInteractionEnabled = true
            self.tableViewLeadingConstraint.constant = self.view.frame.width
            self.tableViewTrailingConstraint.constant -= (5*self.view.frame.width)/6
            self.trackStackView.alpha = 1
            //self.trackStackView.removeBlurEffect()
//            print(self.songListTableView.center)
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    @objc func backToSongPicker() {
        
        let view = self.navigationItem.leftBarButtonItem?.customView as! UIButton;
        view.animateClick();
        self.dismiss(animated: true, completion: nil);
    }
    
    func setupSongs() {
        if selectedGenreList == nil {
            getSongsForSelectedMood();
        } else {
            getSongsForSelectedGenres();
        }
    }
    
    func getSongsForSelectedMood() {
        updateCurrentGenresAndFeatures { (genres, trackFeatures) in
            self.fetchSongsAndSetup(moodObject: self.moodObject)
        }
    }
    
    func getSongsForSelectedGenres() {
        fetchSongsAndSetup(moodObject: self.moodObject)
    }
    
    func fetchSongsAndSetup(numberOfSongs: Int? = nil, moodObject: NewsicMood?) {
        let songCountToSearch = numberOfSongs == nil ? self.cardCount : numberOfSongs
        self.spotifyHandler.searchMusicInGenres(numberOfSongs: songCountToSearch!, moodObject: moodObject, preferredTrackFeatures: trackFeatures, selectedGenreList: self.selectedGenreList) { (results, error) in
            if let error = error {
//                self.present(error.popupDialog!, animated: true, completion: nil);
                error.presentPopup(for: self, description: SpotifyErrorCodeDescription.getMusicInGenres.rawValue)
            }
            DispatchQueue.main.async {
                SwiftSpinner.show("Fetching tracks..", animated: true);
            }
            var newsicTracks:[NewsicTrack] = [];
            for track in results {
                let newsicTrack = NewsicTrack(trackInfo: track, moodInfo: self.moodObject, userName: self.auth.session.canonicalUsername);
                newsicTracks.append(newsicTrack);
                
                self.playedSongsHistory?.append(track)
            }
            self.cardList = newsicTracks;
            
            if self.cardList.count == 0 {
                self.setupSongs();
                print("SONG LIST IS ZERO")
            } else {
                print("Songs added!, count = \(self.cardList.count)")
                
            }
            
            DispatchQueue.main.async {
                self.songCardView.reloadData()
                SwiftSpinner.show(duration: 2, title: "Done!")
            }
            
            //self.updateTableView();
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
        moodObject?.getTrackIdAndFeaturesForEmotion(trackIdAndFeaturesHandler: { (trackIdList, trackFeatures) in
            if let trackIdList = trackIdList {
                self.spotifyHandler.getGenresForTrackList(trackIdList: trackIdList, trackGenreHandler: { (genres, error) in
                    if let error = error {
//                        self.present(error.popupDialog!, animated: true, completion: nil)
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
                self.moodObject?.getDefaultTrackFeatures(getDefaultTrackFeaturesHandler: { (defaultTrackFeatures) in
                    if let defaultTrackFeatures = defaultTrackFeatures {
                        genresFeaturesHandler(nil, defaultTrackFeatures)
                    } else {
                        genresFeaturesHandler(nil, nil)
                    }
                })
                
            }
            
        })
    }
    
    func fetchNewCard(cardFetchingHandler: ((Bool) -> ())?){
//        print("fetching new card...")
        let moodObject = self.moodObject
        spotifyHandler.searchMusicInGenres(numberOfSongs: 1, moodObject: moodObject, preferredTrackFeatures: trackFeatures, selectedGenreList: selectedGenreList) { (results, error)  in
            if let error = error {
//                self.present(error.popupDialog!, animated: true, completion: nil);
                error.presentPopup(for: self, description: SpotifyErrorCodeDescription.getMusicInGenres.rawValue)
            }
            
            if let track = results.first {
                let containsCheck = self.playedSongsHistory?.contains(where: { (trackInHistory) -> Bool in
                    return trackInHistory.trackId == track.trackId
                })
                if containsCheck! {
                    print("REFETCHING NEW CARD.. \(track.trackId) already in list")
                    self.spotifyHandler.searchMusicInGenres(numberOfSongs: 1, moodObject: moodObject, completionHandler: { (results, error) in
                        
//                        if let track = results.first {
//                            print("Got new song. \(track.trackId)");
//                            self.addSongToCardPlaylist(track: track)
//                            DispatchQueue.main.async {
//                                self.songCardView.reloadData();
//                            }
//                        }
                        cardFetchingHandler!(false)
                    })
                } else {
                    if let track = results.first {
                        self.addSongToCardPlaylist(track: track)
                    }
                    
                    
                    DispatchQueue.main.async {
                        self.songCardView.reloadData();
                    }
                    
                    cardFetchingHandler!(true);
                }
            }
            
        }
    }
    
    func removeTrackFromList(indexPath: IndexPath, removeTrackHandler: @escaping (Bool) -> ()) {
        
        let index = likedTrackList.count - indexPath.row-1
        let strIndex = String(index)
        let track = NewsicTrack(trackInfo: likedTrackList[indexPath.row], moodInfo: moodObject, userName: SPTAuth.defaultInstance().session.canonicalUsername)
        
        let trackDict: [String: String] = [ strIndex : track.trackInfo.trackUri ]
        spotifyHandler.removeTrackFromPlaylist(playlistId: playlist.id!, tracks: trackDict) { (didRemove, error) in
            if let error = error {
//                self.present(error.popupDialog!, animated: true, completion: nil);
                error.presentPopup(for: self, description: SpotifyErrorCodeDescription.removeTrack.rawValue)
            } else {
                track.deleteData(deleteCompleteHandler: { (ref, error) in
                    if error != nil {
                        removeTrackHandler(false)
                        print("ERROR DELETING TRACK");
                    } else {
                        self.likedTrackList.remove(at: indexPath.row)
                        removeTrackHandler(true);
                    }
                })
            }
        }
    }
    
    func addSongToCardPlaylist(track: SpotifyTrack) {
        let newsicTrack = NewsicTrack(trackInfo: track, moodInfo: self.moodObject, userName: self.auth.session.canonicalUsername);
        self.cardList.append(newsicTrack)
        self.playedSongsHistory?.append(track)
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
        actionPausePlay();
        
    }
    
    func showSwiftSpinner() {
        if let swipeInteractionController = swipeInteractionController {
            if !swipeInteractionController.interactionWasCancelled {
                if let currentMoodDyad = currentMoodDyad {
                    if EmotionDyad.allValues.contains(currentMoodDyad) {
                        SwiftSpinner.show("Mood: \(currentMoodDyad.rawValue)", animated: true)
                    } else {
                        SwiftSpinner.show("Loading...", animated: true)
                    }
                }
            }
        }
    }
}

extension ShowSongViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let result = !(touch.view is SongTableViewCell)
        return result
        //        return true;
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true;
    }
    
    @objc func handleMenuScreenGesture(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: view);
        let finalPoint = self.songListTableView.frame.width;
        
        if recognizer.state == .began {
            
        } else if recognizer.state == .changed {
            
            var translationX: CGFloat = translation.x
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
            shouldCompleteTransition = translation.x > 0 ? songListMenuProgress > CGFloat(0.5) : songListMenuProgress < CGFloat(0.5)
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

