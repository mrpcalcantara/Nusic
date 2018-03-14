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
import FirebaseDatabase

class ShowSongViewController: NusicDefaultViewController {
    
    //View variables
    var isMenuOpen: Bool = false;
    var isPlayerMenuOpen: Bool = false;
    var navbar: UINavigationBar = UINavigationBar()
    var menuEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer!
    var screenRotated: Bool = false
    var playerMenuMaxWidth: CGFloat = 0
    
    //Data variables
    var cardList:[NusicTrack] = [] {
        didSet {
            if cardList.count < 3 {
                self.fetchNewCard(numberOfSongs: 3-cardList.count, cardFetchingHandler: { (fetched) in
                    
                })

            }
        }
    }
    var playlist:NusicPlaylist! = nil
    var user: NusicUser! = nil;
    var suggestedTrackList: [NusicTrack] = Array() {
        didSet {
            DispatchQueue.main.async {
                if let parent = UIApplication.shared.keyWindow?.rootViewController as? NusicPageViewController {
                    let songListViewController = parent.songListVC as! SongListTabBarViewController
                    songListViewController.suggestedTrackList = self.suggestedTrackList
                    self.updateBadgeIcon(count: self.suggestedTrackList.filter({ ($0.suggestionInfo?.isNewSuggestion)! }).count)
                }
            }
        }
    }
    var suggestedTrackIdList = [[String : NusicSuggestion]]() {
        didSet {
            if let appendedTrackId = suggestedTrackIdList.last?.keys.first {
                fetchDataForLikedTrack(trackId: [appendedTrackId], handler: { (nusicTracks) in
                    if var nusicTrack = nusicTracks.first {
                        if let index = self.suggestedTrackIdList.index(where: { (dict) -> Bool in
                            return dict.keys.first == appendedTrackId
                        }) {
                            if let suggestionInfo = self.suggestedTrackIdList[index].first?.value {
                                nusicTrack.suggestionInfo = suggestionInfo
                                nusicTrack.trackInfo.suggestedSong = true
                            }
                        }
                        
                        if let index = self.suggestedTrackList.index(where: { $0.trackInfo.trackId == nusicTrack.trackInfo.trackId }) {
                            self.suggestedTrackList.remove(at: index)
                        }
                        self.suggestedTrackList.append(nusicTrack)
                    }
                })
            }
        }
    }
    var likedTrackList:[NusicTrack] = [] {
        didSet {
            DispatchQueue.main.async {
                if let parent = UIApplication.shared.keyWindow?.rootViewController as? NusicPageViewController {
                    let songListViewController = parent.songListVC as! SongListTabBarViewController
                    songListViewController.likedTrackList = self.likedTrackList
                }
            }
        }
    }
    var likedTrackIdList = [String]() {
        didSet {
            
            // Added track
            if oldValue.count < likedTrackIdList.count {
                if let appendedTrackId = likedTrackIdList.last {
                    fetchDataForLikedTrack(trackId: [appendedTrackId], handler: { (nusicTracks) in
                        if let nusicTrack = nusicTracks.first {
                            if !self.likedTrackList.contains(where: { (track) -> Bool in
                                return track.trackInfo.trackId == nusicTrack.trackInfo.trackId
                            }) {
                                self.likedTrackList.append(nusicTrack)
                            }
                        }
                    })
                }
            }
            // Removed Track
            else {
                
            }
            
        }
    }
    var preferredPlayer: NusicPreferredPlayer?
    var musicSearchType: NusicTrackSearch = .normal
    var moodObject: NusicMood? = nil;
    var currentMoodDyad: EmotionDyad? = EmotionDyad.unknown
    var initialLoadDone: Bool = false
    
    
    //Spotify
    var player: SPTAudioStreamingController?
    var spotifyHandler: Spotify! = nil;
    var auth: SPTAuth! = nil;
    var isPlaying: Bool = false;
    var selectedGenreList: [String: Int]? = nil
    var selectedSongs: [SpotifyTrack]? = nil
    var currentPlayingTrack: SpotifyTrack?
    var playedSongsHistory: [SpotifyTrack]? = []
    var trackFeatures: [SpotifyTrackFeature] = Array()
    var searchBasedOnArtist: [SpotifyArtist]?
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
    
    //Navigation Bar
    var rightBarButtonItem: UIBarButtonItem? {
        didSet {
            let icon = UIImage(named: "MusicNote")?.withRenderingMode(.alwaysTemplate)
            let iconSize = CGRect(origin: CGPoint.zero, size: icon!.size)
            let iconButton = UIButton(frame: iconSize)
            iconButton.setBackgroundImage(icon, for: .normal)
            rightBarButtonItem?.customView = iconButton
            rightBarButtonItem?.customView?.transform = CGAffineTransform(scaleX: 0, y: 0)
            
            UIView.animate(withDuration: 1, delay: 0.5, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: [.allowUserInteraction, .autoreverse, .repeat, .curveEaseInOut], animations: {
                self.rightBarButtonItem?.customView?.transform = CGAffineTransform.identity
            }, completion: nil)
            
            iconButton.addTarget(self, action: #selector(toggleSongMenu), for: .touchUpInside)
            
            self.navbar.items?.first?.rightBarButtonItem = self.rightBarButtonItem
        }
    }
    
    //Firebase
    let reference: DatabaseReference = Database.database().reference()
    
    
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
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    
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
//            reloadNavigationBar()
//            reloadPlayerMenu(for: self.view.safeAreaLayoutGuide.layoutFrame.size)
            if isPlayerMenuOpen {
                togglePlayerMenu()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        currentSongCardFrame = nil
        if isPlayerMenuOpen {
            togglePlayerMenu(false)
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        
        if screenRotated {
//            reloadNavigationBar()
//            reloadPlayerMenu(for: self.view.safeAreaLayoutGuide.layoutFrame.size)
            screenRotated = false
        }
        
        if currentSongCardFrame != songCardView.frame {
            currentSongCardFrame = songCardView.frame
        }
        
        self.view.layoutIfNeeded()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if isPlayerMenuOpen {
            togglePlayerMenu(false)
        }
        screenRotated = true
    }
    
    fileprivate func setupShowSongVC() {
        initialLoadDone = false
        
        if checkConnectivity() {
            preferredPlayer = user.settingValues.preferredPlayer
            showSwiftSpinner()
            setupMainView()
            setupMenu()
            setupCards()
            setupSongs()
            setupPlayerMenu()
            setupNavigationBar()
            setupMoodLabel()
            setupFirebaseListeners()
            setupSongListVC()
            if preferredPlayer == NusicPreferredPlayer.spotify {
                setupSpotify()
                setupCommandCenter()
                UIApplication.shared.beginReceivingRemoteControlEvents()
            }
            NotificationCenter.default.addObserver(self, selector: #selector(updateAuthObject), name: NSNotification.Name(rawValue: "refreshSuccessful"), object: nil)
        }
        initialLoadDone = true
        newMoodOrGenre = false
    }
    
    fileprivate func setupFirebaseListeners() {
        removeFirebaseListeners();
        reference.child("suggestedTracks").child(self.user.userName).observe(.childAdded) { (dataSnapshot) in
            var isNewSuggestion = false
            var suggestionDate = Date()
            if let dict = dataSnapshot.value as? [String: AnyObject] {
                if let newSuggestionValue = dict["isNewSuggestion"] as? NSNumber {
                    isNewSuggestion = Bool(truncating: newSuggestionValue)
                }
                if let suggestionDateValue = dict["suggestedOn"] as? String {
                    suggestionDate = Date().fromString(dateString: suggestionDateValue, dateFormat: "yyyy-MM-dd'T'HH:mm:ss+hhmm")
                }
            }
            let trackId = dataSnapshot.key
            let trackDict = [trackId:NusicSuggestion(isNewSuggestion: isNewSuggestion, suggestionDate: suggestionDate)]
            if !self.suggestedTrackIdList.contains(where: {$0.keys.contains(trackId)}) {
                self.suggestedTrackIdList.append(trackDict)
            }
        }
        
        
        reference.child("suggestedTracks").child(self.user.userName).observe(.childChanged) { (dataSnapshot) in
            var isNewSuggestion = false
            var suggestionDate = Date()
            if let dict = dataSnapshot.value as? [String: AnyObject] {
                if let newSuggestionValue = dict["isNewSuggestion"] as? NSNumber {
                    isNewSuggestion = Bool(truncating: newSuggestionValue)
                }
                if let suggestionDateValue = dict["suggestedOn"] as? String {
                    suggestionDate = Date().fromString(dateString: suggestionDateValue, dateFormat: "yyyy-MM-dd'T'HH:mm:ss+hhmm")
                }
            }
            let trackId = dataSnapshot.key
            let trackDict = [trackId:NusicSuggestion(isNewSuggestion: isNewSuggestion, suggestionDate: suggestionDate)]
            if let index = self.suggestedTrackIdList.index(where: { (dict) -> Bool in
                return dict.keys.contains(trackId)
            }) {
                self.suggestedTrackIdList.remove(at: index);
                self.suggestedTrackIdList.append(trackDict)
            }
        }
            
       if let emotion = moodObject?.emotions.first?.basicGroup.rawValue.lowercased() {
            reference.child("moodTracks").child(self.user.userName).child(emotion).observe(.childAdded) { (dataSnapshot) in
                let trackId = dataSnapshot.key
                if !self.likedTrackIdList.contains(trackId) {
                    self.likedTrackIdList.append(trackId)
                    self.reference.child("trackFeatures").child(trackId).observe(.value, with: { (childSnapshot) in
                        if childSnapshot.exists() {
                            var features = SpotifyTrackFeature()
                            features.mapDictionary(featureDictionary: childSnapshot.value as! [String: AnyObject])
                            self.trackFeatures.append(features)
                        }
                    })
                }
            }
        
            reference.child("moodTracks").child(self.user.userName).child(emotion).observe(.childRemoved) { (dataSnapshot) in
                let trackId = dataSnapshot.key
                if self.likedTrackIdList.contains(trackId) {
                    if let likedTrackIdIndex = self.likedTrackIdList.index(of: trackId) {
                        if let likedTrackIndex = self.likedTrackList.index(where: { $0.trackInfo.linkedFromTrackId == trackId }) {
                            self.likedTrackList.remove(at: likedTrackIndex)
                        }
                        self.likedTrackIdList.remove(at: likedTrackIdIndex)
                    }
                    
                    if let trackFeaturesIndex = self.trackFeatures.index(where: { $0.id == trackId }) {
                        self.trackFeatures.remove(at: trackFeaturesIndex)
                    }
                }
            }
        }
    }
    
    fileprivate func removeFirebaseListeners() {
        reference.child("suggestedTracks").child(self.user.userName).removeAllObservers()
        if let emotion = moodObject?.emotions.first?.basicGroup.rawValue.lowercased() {
            reference.child("moodTracks").child(self.user.userName).child(emotion).removeAllObservers()
        }
    }
    
    fileprivate func setupMainView() {
        
        currentMoodDyad = moodObject?.emotions.first?.basicGroup
        
    }
    
    fileprivate func setupCommandCenter() {
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
    
    fileprivate func setupNavigationBar() {
        navigationBar.barStyle = .default
        let barButtonLeft = UIBarButtonItem(image: UIImage(named: "MoodIcon"), style: .plain, target: self, action: #selector(backToSongPicker));
        self.navigationItem.leftBarButtonItem = barButtonLeft
        
        let text:String? = self.suggestedTrackList.filter({ ($0.suggestionInfo?.isNewSuggestion)! }).count > 0 ? String(self.suggestedTrackList.filter({ ($0.suggestionInfo?.isNewSuggestion)! }).count) : nil
        let barButtonRight = BadgeBarButtonItem(image: (UIImage(named: "MusicNote")?.withRenderingMode(.alwaysTemplate))!, badgeText: text, target: self, action: #selector(toggleSongMenu))
        updateBadgeIcon(count: self.suggestedTrackList.filter({ ($0.suggestionInfo?.isNewSuggestion)! }).count)
        self.navigationItem.rightBarButtonItem = barButtonRight
        
        let navItem = self.navigationItem
        navigationBar.items = [navItem]
        self.view.layoutIfNeeded()
    }
    
    fileprivate func setupMenu() {
        
        self.view.sendSubview(toBack: trackStackView)
        self.view.sendSubview(toBack: songCardView)
        fetchLikedTracks()
        
    }
    
    fileprivate func setupSongs() {
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

    fileprivate func setupMoodLabel() {
        cardTitle.text = moodObject?.emotions.first?.basicGroup == EmotionDyad.unknown ? "" : moodObject?.emotions.first?.basicGroup.rawValue
        cardTitle.font = NusicDefaults.font!
        cardTitle.textColor = NusicDefaults.foregroundThemeColor
        cardTitle.layoutIfNeeded()
        addCardBorderLayer()
    }
    
    fileprivate func setupSongListVC() {
        let parent = self.parent as! NusicPageViewController
        let songListViewController = parent.songListVC as! SongListTabBarViewController
        songListViewController.isMoodSelected = self.isMoodSelected
        songListViewController.moodObject = self.moodObject
        parent.removeViewControllerFromPageVC(viewController: songListViewController)
        parent.addViewControllerToPageVC(viewController: songListViewController)
    }
    
    
    fileprivate func resetView() {
        if isPlayerMenuOpen {
            togglePlayerMenu(false)
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
    
    fileprivate func setShowMoreOrigin() {
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
    
    @IBAction func showMoreClicked(_ sender: UIButton) {
        togglePlayerMenu();
    }
    
    @IBAction func songSeek(_ sender: UISlider) {
        print("song seeking slider")
        updateElapsedTime(elapsedTime: sender.value, duration: Float((currentPlayingTrack?.audioFeatures?.durationMs)!))
    }
    
    @IBAction func finishSeek(_ sender: UISlider) {
        print("finish seeking slider")
        if preferredPlayer == NusicPreferredPlayer.spotify {
            seekSong(interval: sender.value)
        } else {
            ytSeekTo(seconds: sender.value)
        }
    }
    
    @IBAction func previousTrackClicked(_ sender: UIButton) {
        
        sender.animateClick();
        actionPreviousSong()
        
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
                spinnerText = "Loading..."
                SwiftSpinner.show(spinnerText, animated: true).addTapHandler({
                    self.goToPreviousViewController()
                    SwiftSpinner.hide()
                }, subtitle: "Tap to go the previous screen!")
            }
        }
    }
    
    func setupConstraints(for size: CGSize) {
        //Landscape
        if size.width > size.height {
            self.songCardTrailingConstraint.constant = -size.width*(1/3)
            self.dislikeSongCenterXConstraint.constant = -size.width*(1/6)
            self.previousTrackCenterXConstraint.constant = -size.width*(1/6)
            self.pausePlayCenterXConstraint.constant = -size.width*(1/6)
            self.likeSongCenterXConstraint.constant = -size.width*(1/6)
            self.showMoreCenterXConstraint.constant = -size.width*(1/6)
            self.nextTrackCenterXConstraint.constant = -size.width*(1/6)
            self.songProgressTrailingConstraint.constant = -size.width*(1/3)
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
    
    func updateBadgeIcon(count: Int) {
        if let items = self.navbar.items, items.count > 0 {
            let text = count > 0 ? String(count) : nil
            (self.navbar.items?.first?.rightBarButtonItem as! BadgeBarButtonItem).badgeText = text
            if text == nil {
                (self.navbar.items?.first?.rightBarButtonItem as! BadgeBarButtonItem).badgeLabel.isHidden = true
            } else {
                (self.navbar.items?.first?.rightBarButtonItem as! BadgeBarButtonItem).badgeLabel.isHidden = false
            }
        }
    }
    
}

extension ShowSongViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        print("shouldbegin called")
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
}

extension ShowSongViewController {
//
    @objc func toggleSongMenu() {
        if let parent = parent as? NusicPageViewController {
            parent.scrollToNextViewController()
        }
    }
    
    @objc func backToSongPicker() {
        goToPreviousViewController()
    }
    
    @objc func updateAuthObject() {
        self.auth = (UIApplication.shared.delegate as! AppDelegate).auth
    }
    
    fileprivate func fetchDataForLikedTrack(trackId: [String], handler: @escaping ([NusicTrack]) -> ()) {
        self.spotifyHandler.getTrackInfo(for: trackId, offset: 0, currentExtractedTrackList: [], trackInfoListHandler: { (spotifyTracks, error) in
            if let error = error {
                error.presentPopup(for: self, description: SpotifyErrorCodeDescription.getTrackInfo.rawValue)
            } else {
                if let spotifyTracks = spotifyTracks {
                    
                    let spotifyArtistList = spotifyTracks.map({ $0.artist.first?.uri }) as! [String]
                    self.spotifyHandler.getAllGenresForArtists(spotifyArtistList, offset: 0, artistGenresHandler: { (fetchedArtistList, error) in
                        if let error = error {
                            error.presentPopup(for: self, description: SpotifyErrorCodeDescription.getGenresForTrackList.rawValue)
                        } else {
                            if let fetchedArtistList = fetchedArtistList {
                                for artist in fetchedArtistList {
                                    
                                    if let index = spotifyTracks.index(where: { (track) -> Bool in
                                        return track.artist.map({$0.uri}).contains(where: { $0 == artist.uri })
                                    }) {
                                        spotifyTracks[index].artist.updateArtist(artist: artist)
                                    }
                                }
                            }
                            self.getYouTubeResults(tracks: spotifyTracks, youtubeSearchHandler: { (nusicTracks) in
                                handler(nusicTracks)
                            })
                        }
                    })
                    
                }
            }
        })
    }
    
    fileprivate func fetchLikedTracks() {
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
                    self.fetchDataForLikedTrack(trackId: trackList, handler: { (nusicTracks) in
                        self.likedTrackList = nusicTracks
                    })
                }
            })
        }
    }
    
    fileprivate func fetchSongsAndSetup(numberOfSongs: Int? = nil, moodObject: NusicMood?) {
        
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
                    self.initialLoadDone = true
                    DispatchQueue.main.async {
                        self.songCardView.reloadData()
                        self.showSwiftSpinner(text: "Done!", duration: 2)
                        
                    }
                    
                    
                })
            }
        }
    }
    
    fileprivate func fetchYouTubeInfo() {
        
        for track in selectedSongs! {
            self.playedSongsHistory?.append(track)
        }
        if selectedSongs!.count == 0 {
            self.setupSongs();
        } else {
            self.getYouTubeResults(tracks: selectedSongs!, youtubeSearchHandler: { (tracks) in
                var nusicTracks:[NusicTrack] = Array()
                for var track in tracks {
                    track.suggestionInfo?.isNewSuggestion = track.trackInfo.suggestedSong
                    nusicTracks.append(track)
                }
                self.cardList = nusicTracks
                DispatchQueue.main.async {
                    self.songCardView.reloadData()
                    self.showSwiftSpinner(text: "Done!", duration: 2)
                }
            })
        }
    }
    
    fileprivate func fetchNewCard(numberOfSongs: Int? = 1, cardFetchingHandler: ((Bool) -> ())?){
        
        let addSongsHandler: ([NusicTrack]) -> Bool = { trackList in
            self.addSongsToCardList(for: nil, tracks: trackList)
            return trackList.count > 0
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
    
    fileprivate func fetchNewCardArtist(basedOnArtist: [SpotifyArtist]? = nil, numberOfSongs: Int, cardFetchingHandler: (([NusicTrack]) -> ())?) {
        var artists = [SpotifyArtist]()
        if basedOnArtist != nil {
            artists = basedOnArtist!
        } else {
            
            if let artistList = currentPlayingTrack?.artist {
                for listedArtist in artistList {
                    artists.append(listedArtist)
                }
            }
        }
        
        self.spotifyHandler.fetchRecommendations(for: .artist, numberOfSongs: numberOfSongs, market: user.territory, artists: artists) { (results, error) in
            if let error = error {
                error.presentPopup(for: self, description: SpotifyErrorCodeDescription.getMusicInGenres.rawValue)
            }
            
            self.getYouTubeResults(tracks: results, youtubeSearchHandler: { (tracks) in
                if let cardFetchingHandler = cardFetchingHandler {
                    cardFetchingHandler(tracks);
                }
            })
            
        }
        
//        if artist.id != nil {
//
//        } else {
//            cardFetchingHandler!([])
//        }
        
        
    }
    
    fileprivate func fetchNewCardTrack(basedOnTrack: SpotifyTrack? = nil, numberOfSongs: Int, cardFetchingHandler: (([NusicTrack]) -> ())?) {
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
    
    fileprivate func fetchNewCardGenre(basedOnGenres: [String : Int]? = nil, numberOfSongs: Int, insert inIndex: Int? = nil, cardFetchingHandler: (([NusicTrack]) -> ())?) {
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
    
    fileprivate func fetchNewCardNormal(numberOfSongs: Int, cardFetchingHandler: (([NusicTrack]) -> ())?) {
        var trackFeaturesAux: [SpotifyTrackFeature]? = trackFeatures
        if let emotion = moodObject?.emotions.first?.basicGroup, emotion == EmotionDyad.unknown {
            trackFeaturesAux = nil
        }
        
        self.spotifyHandler.fetchRecommendations(for: .genres, numberOfSongs: numberOfSongs, market: user.territory, moodObject: moodObject, preferredTrackFeatures: trackFeaturesAux, selectedGenreList: selectedGenreList) { (results, error) in
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
                self.fetchNewCardNormal(numberOfSongs: numberOfSongs, cardFetchingHandler: cardFetchingHandler)
            } else {
                self.getYouTubeResults(tracks: spotifyResults, youtubeSearchHandler: { (tracks) in
                    if let cardFetchingHandler = cardFetchingHandler {
                        cardFetchingHandler(tracks);
                    }
                })
            }
        }
    }
    
    fileprivate func getSongsForSelectedMood() {
       
        
        updateCurrentGenresAndFeatures { (genres, trackFeatures) in
            self.fetchSongsAndSetup(moodObject: self.moodObject)
        }
    }
    
    fileprivate func getSongsForSelectedGenres() {
        trackFeatures.removeAll()
        fetchSongsAndSetup(moodObject: self.moodObject)
    }
    
    fileprivate func getYouTubeResults(tracks: [SpotifyTrack], youtubeSearchHandler: @escaping ([NusicTrack]) -> ()) {
        var index = 0
        var ytTracks: [NusicTrack] = []
        for track in tracks {
            if let firstArtist = track.artist.first?.artistName {
                YouTubeSearch.getSongInfo(artist: firstArtist, songName: track.songName, completionHandler: { (youtubeInfo) in
                    index += 1
                    if let currentIndex = tracks.index(where: { (currentTrack) -> Bool in
                        return currentTrack.trackId == track.trackId
                    }) {
                        
                        let nusicTrack = NusicTrack(trackInfo: tracks[currentIndex], moodInfo: self.moodObject, userName: self.user.userName, youtubeInfo: youtubeInfo);
                        
                        ytTracks.append(nusicTrack);
                    }
                    if index == tracks.count {
                        youtubeSearchHandler(ytTracks)
                    }
                })
            }
        }
    }
    
    func updateCurrentGenresAndFeatures(updateGenresFeaturesHandler: @escaping ([String]?, [SpotifyTrackFeature]?) -> ()) {
        getGenresAndFeaturesForMoods(genresFeaturesHandler: { (genres, trackFeatures) in
            if let genres = genres {
                self.moodObject?.associatedGenres = genres
            }
            self.trackFeatures = trackFeatures!;
            updateGenresFeaturesHandler(genres, trackFeatures);
        });
    }
    
    fileprivate func getGenresAndFeaturesForMoods(genresFeaturesHandler: @escaping([String]?, [SpotifyTrackFeature]?) -> ()) {
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
//            if self.songCardView.currentCardIndex == 0 {
//                self.songCardView.reloadCardsInIndexRange(0..<3)
//            } else {
//                
//            }
            
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
            actionPlaySpotifyTrack(spotifyTrackId: cardList[index].trackInfo.trackUri);
        }
    }
    
    func removeTrackFromLikedTracks(track:NusicTrack, indexPath: IndexPath, removeTrackHandler: @escaping (Bool) -> ()) {
        
        let index = likedTrackList.count - indexPath.row-1
        let strIndex = String(index)
        let trackDict: [String: String] = [ strIndex : track.trackInfo.trackUri ]
        spotifyHandler.removeTrackFromPlaylist(playlistId: playlist.id!, tracks: trackDict) { (didRemove, error) in
            if let error = error {
                error.presentPopup(for: self, description: SpotifyErrorCodeDescription.removeTrack.rawValue)
            } else {
                self.isSongLiked = false;
                self.toggleLikeButtons();
                removeTrackHandler(true)
            }
        }
    }
    
    fileprivate func addSongToCardPlaylist(index: Int? = nil, track: NusicTrack) {
        if index != nil {
            self.cardList.insert(track, at: index!)
        } else {
            self.cardList.append(track)
        }
        self.playedSongsHistory?.append(track.trackInfo)
    }
    
    fileprivate func checkConnectivity() -> Bool {
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

    func playSelectedCard(track: NusicTrack) {
        let frontPosition = songCardView.currentCardIndex;
        
        isSongLiked = true; toggleLikeButtons();
        addSongToPosition(track: track, position: frontPosition);
        
        if preferredPlayer == NusicPreferredPlayer.spotify {
            actionPlaySpotifyTrack(spotifyTrackId: cardList[frontPosition].trackInfo.trackUri);
        }
    }
    
    func containsTrack(trackId: String) -> Bool {
        for track in likedTrackList {
            if track.trackInfo.trackId == trackId {
                return true;
            }
        }
        return false;
    }
}


