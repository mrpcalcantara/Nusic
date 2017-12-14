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
import PopupDialog


class ShowSongViewController: NewsicDefaultViewController {
    
    var user: NewsicUser! = nil;
    var player: SPTAudioStreamingController?
    var likedTrackList:[NewsicTrack] = [] {
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
//    var swipeInteractionController: SwipeInteractionController?
    var currentPlayingTrack: SpotifyTrack?
    var playedSongsHistory: [SpotifyTrack]? = []
    var newMoodOrGenre: Bool = true
    var navbar: UINavigationBar = UINavigationBar()
    var menuEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer!
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
//            self.viewDidLoad()
        } else {
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //        actionStopPlayer();
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        actionStopPlayer();
        closePlayerMenu(animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
    }
    
    func resetView() {
        self.cardList.removeAll();
        self.songCardView.resetCurrentCardIndex()
        self.songCardView.reloadData();
        
        if user.preferredPlayer == NewsicPreferredPlayer.youtube {
            if let player = player, player.initialized {
                resetPlaybackDelegate()
                resetStreamingDelegate()
                actionStopPlayer()
            }
        }
    }
    
    func setupShowSongVC() {
        if checkConnectivity() {
            showSwiftSpinner()
            setupMainView()
            setupNavigationBar()
            setupMenu()
            setupCards()
            setupTableView()
            setupSongs()
            setupPlayerMenu()
            if user.preferredPlayer == NewsicPreferredPlayer.spotify {
                setupSpotify()
                setupCommandCenter()
                UIApplication.shared.beginReceivingRemoteControlEvents()
            }
            
            NotificationCenter.default.addObserver(self, selector: #selector(updateAuthObject), name: NSNotification.Name(rawValue: "refreshSuccessful"), object: nil)
            
        }
        
        newMoodOrGenre = false
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
    
    func setupMainView() {
        
        
        
        currentMoodDyad = moodObject?.emotions.first?.basicGroup
        
//        swipeInteractionController = SwipeInteractionController(viewController: self)
        menuEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleMenuScreenGesture(_:)))
        menuEdgePanGestureRecognizer.edges = .right
        //        screenEdgeRecognizer.cancelsTouchesInView = false
        
        self.view.addGestureRecognizer(menuEdgePanGestureRecognizer);
       
//        let exitEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(backToSongPicker))
//        exitEdgePanGestureRecognizer.edges = .left
//        //        screenEdgeRecognizer.cancelsTouchesInView = false
//
//        self.view.addGestureRecognizer(exitEdgePanGestureRecognizer);
        
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
    }
    
    func setupNavigationBar() {
        if self.view.subviews.contains(navbar) {
            navbar.removeFromSuperview()
        }
        navbar  = UINavigationBar(frame: CGRect(x: 0, y: 20, width: self.view.frame.width, height: 44));
        navbar.barStyle = .default
//        navbar.tintColor = UIColor.white
//        UINavigationBar.appearance().tintColor = UIColor.white
        
//        let buttonLeft = UIButton(type: .system)
//        buttonLeft.setImage(UIImage(named: "MoodIcon"), for: .normal)
//        buttonLeft.addTarget(self, action: #selector(backToSongPicker), for: .touchUpInside)
//        let barButtonLeft = UIBarButtonItem(customView: buttonLeft);
//        self.navigationItem.leftBarButtonItem = barButtonLeft
//
        let barButtonLeft = UIBarButtonItem(image: UIImage(named: "MoodIcon"), style: .plain, target: self, action: #selector(backToSongPicker));
        
        self.navigationItem.leftBarButtonItem = barButtonLeft
        
//        let buttonRight = UIButton(type: .system)
//        buttonRight.setImage(UIImage(named: "MusicNote"), for: .normal)
//        buttonRight.addTarget(self, action: #selector(toggleSongMenu), for: .touchUpInside)
//        let barButtonRight = UIBarButtonItem(customView: buttonRight);
//
        
        
        let barButtonRight = UIBarButtonItem(image: UIImage(named: "MusicNote"), style: .plain, target: self, action: #selector(toggleSongMenu));
        
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
                    error.presentPopup(for: self, description: SpotifyErrorCodeDescription.getPlaylistTracks.rawValue)
                    
                } else {
                    if let spotifyTracks = spotifyTracks {
                        
                        self.getYouTubeResults(tracks: spotifyTracks, youtubeSearchHandler: { (newsicTracks) in
                            self.likedTrackList = newsicTracks;
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
                                self.getYouTubeResults(tracks: spotifyTracks, youtubeSearchHandler: { (newsicTracks) in
                                    self.likedTrackList = newsicTracks
                                })
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
            if user.preferredPlayer == NewsicPreferredPlayer.spotify {
                seekSong(interval: sender.value)
            } else {
                ytSeekTo(seconds: sender.value)
            }
            
        }
    }
    
    
    @objc func toggleSongMenu() {
//        let view = self.navigationItem.rightBarButtonItem?.customView as! UIButton;
//        view.animateClick();
        if !isMenuOpen {
            openMenu();
            closePlayerMenu(animated: true)
        } else {
            closeMenu();
        }
        songListMenuProgress = 0
        //isMenuOpen = !isMenuOpen;
    }
    
    @objc func backToSongPicker() {
        
        goToPreviousViewController()
//        self.dismiss(animated: true, completion: nil);
//        self.dismiss(animated: true) {
//            NotificationCenter.default.post(name: Notification.Name(rawValue: "songDismissed"), object: nil);
//            NotificationCenter.default.post(name: Notification.Name(rawValue: "songDismissed"), object: nil, userInfo: self)
//            NotificationCenter.default.post(name: Notification.Name(rawValue: "songDismissed"), object: nil);
//        }
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
            var newsicTracks:[SpotifyTrack] = [];
            for track in results {
                newsicTracks.append(track);
                self.playedSongsHistory?.append(track)
            }
            if newsicTracks.count == 0 {
                self.setupSongs();
            } else {
                self.getYouTubeResults(tracks: newsicTracks, youtubeSearchHandler: { (tracks) in
                    self.cardList = tracks
                    DispatchQueue.main.async {
                        self.songCardView.reloadData()
                        SwiftSpinner.show(duration: 2, title: "Done!")
                    }
                    
                    
                })
            }
        }
    }
    
    func getYouTubeResults(tracks: [SpotifyTrack], youtubeSearchHandler: @escaping ([NewsicTrack]) -> ()) {
        var index = 0
        var ytTracks: [NewsicTrack] = []
        for track in tracks {
            YouTubeSearch.getSongInfo(artist: track.artist.artistName, songName: track.songName, completionHandler: { (youtubeInfo) in
                index += 1
                if let currentIndex = tracks.index(where: { (currentTrack) -> Bool in
                    return currentTrack.trackId == track.trackId
                }) {
                    
                    let newsicTrack = NewsicTrack(trackInfo: tracks[currentIndex], moodInfo: self.moodObject, userName: self.auth.session.canonicalUsername, youtubeInfo: youtubeInfo);
                    
                    ytTracks.append(newsicTrack);
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
    
    func fetchNewCard(cardFetchingHandler: ((Bool) -> ())?){
//        print("fetching new card...")
        let moodObject = self.moodObject
        
        spotifyHandler.searchMusicInGenres(numberOfSongs: 1, moodObject: moodObject, preferredTrackFeatures: trackFeatures, selectedGenreList: selectedGenreList) { (results, error)  in
            if let error = error {
                error.presentPopup(for: self, description: SpotifyErrorCodeDescription.getMusicInGenres.rawValue)
            }
            
            if let track = results.first {
                let containsCheck = self.playedSongsHistory?.contains(where: { (trackInHistory) -> Bool in
                    return trackInHistory.trackId == track.trackId
                })
                if containsCheck! {
//                    print("REFETCHING NEW CARD.. \(track.trackId) already in list")
                    self.spotifyHandler.searchMusicInGenres(numberOfSongs: 1, moodObject: moodObject, completionHandler: { (results, error) in
                        
                        if let cardFetchingHandler = cardFetchingHandler {
                            cardFetchingHandler(false)
                        }
                        
                    })
                } else {
                    if let track = results.first {
                        self.getYouTubeResults(tracks: [track], youtubeSearchHandler: { (tracks) in
                            for track in tracks {
                                self.addSongToCardPlaylist(track: track)
                            }
                            DispatchQueue.main.async {
                                self.songCardView.reloadData();
                            }
                        })
                        
                    }
//
//
//                    DispatchQueue.main.async {
//                        self.songCardView.reloadData();
//                    }
                    
                    if let cardFetchingHandler = cardFetchingHandler {
                        cardFetchingHandler(true);
                    }
                    
                }
            }
            
        }
    }
    
    func removeTrackFromList(indexPath: IndexPath, removeTrackHandler: @escaping (Bool) -> ()) {
        
        let index = likedTrackList.count - indexPath.row-1
        let strIndex = String(index)
//        let track = NewsicTrack(trackInfo: likedTrackList[indexPath.row], moodInfo: moodObject, userName: SPTAuth.defaultInstance().session.canonicalUsername)
        let track = likedTrackList[indexPath.row]
        
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
    
    func addSongToCardPlaylist(track: NewsicTrack) {
//        let newsicTrack = NewsicTrack(trackInfo: track, moodInfo: self.moodObject, userName: self.auth.session.canonicalUsername, youtubeInfo: youtubeInfo);
        self.cardList.append(track)
        self.playedSongsHistory?.append(track.trackInfo)
        
        
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
        if user.preferredPlayer == NewsicPreferredPlayer.spotify {
            spotifyPausePlay();
        } else {
            ytPausePlay()
        }
        
        
    }
    
    func showSwiftSpinner() {
        if let currentMoodDyad = moodObject?.emotions.first?.basicGroup {
            var spinnerText = ""
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
//        if let swipeInteractionController = swipeInteractionController {
//            if !swipeInteractionController.interactionWasCancelled {
//                if let currentMoodDyad = currentMoodDyad {
//                    var spinnerText = ""
//                    if EmotionDyad.allValues.contains(currentMoodDyad) {
//                        spinnerText = "Mood: \(currentMoodDyad.rawValue)"
//                    } else {
//                        spinnerText = "Loading..."
//                    }
//
//                    SwiftSpinner.show(spinnerText, animated: true).addTapHandler({
//                        self.dismiss(animated: true, completion: nil)
//                        SwiftSpinner.hide()
//                    }, subtitle: "Tap to go the previous screen!")
//                }
//            }
//        }
    }
    
    @objc func updateAuthObject() {
        self.auth = (UIApplication.shared.delegate as! AppDelegate).auth
    }
}

extension ShowSongViewController: UIGestureRecognizerDelegate {
    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        let gesture1 = gestureRecognizer
//        let gesture2 = otherGestureRecognizer
//        gesture2.
//        return ;
//    }
    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        <#code#>
//    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let result = !(touch.view is SongTableViewCell)
        return result
        //        return true;
    }
    
    
//    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        let gesture = gestureRecognizer
//
//        return true
//    }
    
    
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
            shouldCompleteTransition = translation.x > 0 ? songListMenuProgress > CGFloat(0.5) : songListMenuProgress < CGFloat(0.5)
            self.view.layoutIfNeeded();
            
        } else if recognizer.state == .ended {
            
//            for subview in self.view.subviews {
//                if let view = subview as? UIScrollView {
//                    view.panGestureRecognizer.shouldBeRequiredToFail(by: menuEdgePanGestureRecognizer)
////                    view.panGestureRecognizer.shouldRequireFailure(of: menuEdgePanGestureRecognizer)
//                }
//            }
            
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

