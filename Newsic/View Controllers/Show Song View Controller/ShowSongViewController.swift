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


class ShowSongViewController: UIViewController {
    
    
    var user: NewsicUser! = nil;
    var player: SPTAudioStreamingController?
    var likedTrackList:[SpotifyTrack] = []
    var cardList:[NewsicTrack] = [];
    var playlist:NewsicPlaylist! = nil
    var spotifyHandler: Spotify! = nil;
    var auth: SPTAuth! = nil;
    var moodObject: NewsicMood? = nil;
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
    //var songPosition: Double! = 0
    
    
    @IBOutlet weak var tableViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTrailingConstraint: NSLayoutConstraint!
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
    
    override func viewDidLoad() {
        super.viewDidLoad();
        navigationController?.interactivePopGestureRecognizer?.delegate = self;
        let dyad = moodObject?.emotions.first?.basicGroup.rawValue;
        SwiftSpinner.show("Mood: \(dyad!)", animated: true);
        setupTableView()
        setupSpotify()
        setupSongs()
        setupMenu()
        setupCards()
        setupCommandCenter()
        setupPlayerMenu()
        //
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
    
    func setupCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.seekForwardCommand.isEnabled = true
        commandCenter.seekBackwardCommand.isEnabled = true
    }
    
    func setupMenu() {
        
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(named: "MusicNote"), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn1.addTarget(self, action: #selector(toggleSongMenu), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        self.navigationItem.rightBarButtonItem = item1;
        
        //self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "MoodIcon");
        //self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "MoodIcon");
        //self.navigationController?.
        let btn2 = UIButton(type: .custom)
        btn2.setImage(UIImage(named: "MoodIcon"), for: .normal)
        btn2.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn2.addTarget(self, action: #selector(backToSongPicker), for: .touchUpInside)
        let item2 = UIBarButtonItem(customView: btn2)
        self.navigationItem.leftBarButtonItem = item2;
        /*
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(backToSongPicker))
        self.navigationItem.leftBarButtonItem?.setBackgroundImage(UIImage(named: "MoodIcon"), for: .normal, barMetrics: .default)
        self.navigationItem.leftBarButtonItem?.width = 30
        */
        //self.navigationItem.backBarButtonItem?.setBackgroundImage(UIImage(named: "MoodIcon"), for: .normal, barMetrics: .default)
        //self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        
        self.view.sendSubview(toBack: trackStackView)
        self.view.sendSubview(toBack: songCardView)
        songListTableView.layer.zPosition = 1
        //self.view.sendSubview(toBack: buttonsStackView)
        self.songListTableView.tableHeaderView?.frame = CGRect(x: (self.songListTableView.tableHeaderView?.frame.origin.x)!, y: -8, width: (self.songListTableView.tableHeaderView?.frame.width)!, height: (self.songListTableView.tableHeaderView?.frame.height)!)
        
        //closeMenu()
        if moodObject?.emotions.first?.basicGroup == EmotionDyad.unknown {
            spotifyHandler.getAllTracksForPlaylist(playlistId: playlist.id!) { (spotifyTracks) in
                if let spotifyTracks = spotifyTracks {
                    self.likedTrackList = spotifyTracks;
                    DispatchQueue.main.async {
                        self.songListTableView.reloadData()
                    }
                    
                }
            }
        } else {
            moodObject?.getTrackIdListForEmotionGenre(getAssociatedTrackHandler: { (trackList) in
                if let trackList = trackList {
                    self.spotifyHandler.getTrackInfo(for: trackList, offset: 0, currentExtractedTrackList: [], trackInfoListHandler: { (spotifyTracks) in
                        if let spotifyTracks = spotifyTracks {
                            self.likedTrackList = spotifyTracks;
                            DispatchQueue.main.async {
                                self.songListTableView.reloadData()
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
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            
            self.trackStackView.layer.zPosition = -1
            self.songListTableView.layer.zPosition = 1
            self.songListTableView.isUserInteractionEnabled = true
            self.songCardView.isUserInteractionEnabled = false
            self.previousSong.isUserInteractionEnabled = false
            self.pausePlay.isUserInteractionEnabled = false
            self.nextSong.isUserInteractionEnabled = false
            self.previousTrack.isUserInteractionEnabled = false
            self.nextTrack.isUserInteractionEnabled = false
            self.showMore.isUserInteractionEnabled = false
            
            /*
            self.previousSong.alpha = 0
            self.nextSong.alpha = 0
 
            self.toggleLikeButtons();
            self.pausePlay.alpha = 0
            self.previousTrack.alpha = 0
            self.nextTrack.alpha = 0
            //self.showMore.alpha = 0
            */
            self.tableViewLeadingConstraint.constant = self.view.frame.width/6;
            self.tableViewTrailingConstraint.constant = 0
            self.trackStackView.alpha = 0.1
            //self.trackStackView.addBlurEffect()
            
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    func closeMenu() {
        //self.view.sendSubview(toBack: self.songListTableView);
        isMenuOpen = false
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            
            self.trackStackView.layer.zPosition = 1
            //self.view.sendSubview(toBack: self.songListTableView);
            self.songListTableView.isUserInteractionEnabled = false
            self.songCardView.isUserInteractionEnabled = true
            self.previousSong.isUserInteractionEnabled = true
            self.pausePlay.isUserInteractionEnabled = true
            self.nextSong.isUserInteractionEnabled = true
            self.previousTrack.isUserInteractionEnabled = true
            self.nextTrack.isUserInteractionEnabled = true
            self.showMore.isUserInteractionEnabled = true
            
            /*
            self.previousSong.alpha = 1
            self.nextSong.alpha = 1
 
            self.toggleLikeButtons();
            self.pausePlay.alpha = 1
            
            self.previousTrack.alpha = 1
            self.nextTrack.alpha = 1
            self.showMore.alpha = 1
            */
            self.tableViewLeadingConstraint.constant = self.view.frame.width
            self.tableViewTrailingConstraint.constant -= (5*self.view.frame.width)/6
            self.trackStackView.alpha = 1
            //self.trackStackView.removeBlurEffect()
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    @objc func backToSongPicker() {
        let view = self.navigationItem.leftBarButtonItem?.customView as! UIButton;
        view.animateClick();
        swipeBack(sender: nil)
        actionStopPlayer();
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
    
    func fetchSongsAndSetup(numberOfSongs: Int? = 5, moodObject: NewsicMood?) {
        
        self.spotifyHandler.searchMusicInGenres(numberOfSongs: 5, moodObject: moodObject, preferredTrackFeatures: trackFeatures, selectedGenreList: self.selectedGenreList) { (results) in
            DispatchQueue.main.async {
                SwiftSpinner.show("Fetching tracks..", animated: true);
            }
            var newsicTracks:[NewsicTrack] = [];
            for track in results {
                let newsicTrack = NewsicTrack(trackInfo: track, moodInfo: self.moodObject, userName: self.auth.session.canonicalUsername);
                newsicTracks.append(newsicTrack);
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
                self.spotifyHandler.getGenresForTrackList(trackIdList: trackIdList, trackGenreHandler: { (genres) in
                    if let genres = genres {
                        //print("GENRES EXTRACTED = \(genres)");
                        genresFeaturesHandler(genres, trackFeatures)
                        
                    } else {
                        genresFeaturesHandler(nil, trackFeatures);
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
        print("fetching new card...")
        let moodObject = self.moodObject
        spotifyHandler.searchMusicInGenres(numberOfSongs: 1, moodObject: moodObject, preferredTrackFeatures: trackFeatures, selectedGenreList: selectedGenreList) { (results) in
        
            //var newsicTracks:[NewsicTrack] = [];
            for track in results {
                let newsicTrack = NewsicTrack(trackInfo: track, moodInfo: self.moodObject, userName: self.auth.session.canonicalUsername);
                
                self.cardList.append(newsicTrack)
                //self.cardList.remove(at: 0)
            }
            
            
            DispatchQueue.main.async {
                //self.songCardView.resetCurrentCardIndex()
                self.songCardView.reloadData();
            }
            
            cardFetchingHandler!(true);
        }
    }
    
    func removeTrackFromList(indexPath: IndexPath, removeTrackHandler: @escaping (Bool) -> ()) {
        
        let index = likedTrackList.count - indexPath.row-1
        let strIndex = String(index)
        let track = NewsicTrack(trackInfo: likedTrackList[indexPath.row], moodInfo: moodObject, userName: SPTAuth.defaultInstance().session.canonicalUsername) 
        
        let trackDict: [String: String] = [ strIndex : track.trackInfo.trackUri ]
        //print("indexPath = \(indexPath.row)")
        spotifyHandler.removeTrackFromPlaylist(playlistId: playlist.id!, tracks: trackDict) { (didRemove) in
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
    
    
    override func remoteControlReceived(with event: UIEvent?) {
        
        if event?.type == UIEventType.remoteControl {
            print("subtype = \(event?.subtype)");
            //if event?.subtype == UIEventSubtype.remoteControlTogglePlayPause {
            if event?.subtype == UIEventSubtype.remoteControlPlay || event?.subtype == UIEventSubtype.remoteControlPause {
                self.actionPausePlay()
            } else if event?.subtype == UIEventSubtype.remoteControlNextTrack {
                self.songCardView.swipe(.left)
            } else if event?.subtype == UIEventSubtype.remoteControlPreviousTrack {
                self.songCardView.revertAction();
            } else if event?.subtype == UIEventSubtype.remoteControlBeginSeekingForward {
                //self.actionSeekForward()
                
                print("BEGIN SEEKING FORWARD")
            } else if event?.subtype == UIEventSubtype.remoteControlEndSeekingForward {
                //seekToTime()
                //self.actionSeekBackward()
                print("END SEEKING FORWARD")
            }
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
        /*
        songCardView.swipe(.right)
        
        updateCurrentGenresAndFeatures { (genres, trackFeatures) in
            self.trackFeatures = trackFeatures;
        }
        */
    }
    
    @IBAction func pausePlayClicked(_ sender: UIButton) {
        
        sender.animateClick();
        actionPausePlay();
        
    }
}




//TOUCH/TAP/SWIPE ACTIONS
/*
extension ShowSongViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        //location is relative to the current view
        // do something with the touched point
        /*
        if touch?.view == songListTableView {
            
            closePlayerMenu(animated: true);
            isPlayerMenuOpen = false;
        } else if touch?.view == showMore {
            closeMenu();
        } else {
            //closeMenu();
            closePlayerMenu(animated: true);
            isPlayerMenuOpen = false
        }
         s*/
    }
}
*/
extension ShowSongViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let count = (navigationController?.viewControllers.count)!
        return count > 1 ? true : false;
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true;
    }
    
    @objc func handleMenuScreenGesture(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: view);
        
        //recognizer.setTranslation(translation, in: view)
        let finalPoint = self.view.frame.width/6;
        var progress = (translation.x * -1)/finalPoint;
        progress = CGFloat(fminf(fmaxf(Float(progress), 0.0), 1.0))
        
        if recognizer.state == .began {
            //let point = CGPoint(x: translation.x + (initialSongListCenter?.x)!, y: (initialSongListCenter?.y)!)
            //songListTableView.center = point
            //print("point = \(point) and translation = \(translation)")
            
            print("pan began")
            print("leading constant = \(self.tableViewLeadingConstraint.constant)")
            print("trailing constant = \(self.tableViewTrailingConstraint.constant)")
            
        } else if recognizer.state == .changed {
            shouldCompleteTransition = progress > 0.5
            //songListTableView.center = CGPoint(x: translation.x + (initialSongListCenter?.x)!, y: (initialSongListCenter?.y)!)
            
            self.tableViewLeadingConstraint.constant = translation.x + self.view.frame.width;
            self.tableViewTrailingConstraint.constant = translation.x - (5 * self.view.frame.width)/6;
            self.view.layoutIfNeeded();
            //print("leading constant = \(self.tableViewLeadingConstraint.constant)")
            //print("trailing constant = \(self.tableViewTrailingConstraint.constant)")
            
        } else if recognizer.state == .ended {
            if shouldCompleteTransition {
                openMenu()
            } else {
                closeMenu()
            }
            
            print("edge pan ended")
        }
        
    }
}
