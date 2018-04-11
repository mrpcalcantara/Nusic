//
//  NusicWeeklyViewController.swift
//  Newsic
//
//  Created by Miguel Alcantara on 21/03/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import UIKit
import Firebase
import SwiftSpinner

class NusicWeeklyViewController: NusicDefaultViewController {
    
    @IBOutlet weak var artistImageView: UIImageView!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var artistBioLabel: UILabel!
    @IBOutlet weak var artistSimilarLabel: UILabel!
    @IBOutlet weak var artistBioScrollView: UIScrollView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var playSongsButton: UIButton!
    
    //Constraints
    @IBOutlet weak var navigationBarLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var navigationBarTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var navigationBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var playSongsButtonTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var playSongsButtonLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var playSongsButtonBottomConstraint: NSLayoutConstraint!
    
    //Scroll View Elements Constraints
    @IBOutlet weak var artistNameTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var artistNameTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var artistNameLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var artistBioLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var artistBioWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var artistBioTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var artistBioTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var artistSImilarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var artistSimilarTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var artistSimilarLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var artistSimilarTopConstraint: NSLayoutConstraint!
    
    
    
    
    var loadingFinished: Bool? = false {
        didSet {
            
            updateValuesUI()
            handleNotificationSong()
        }
    }
    var lastFM: LastFM? = nil
    var currentArtist: SpotifyArtist? = nil {
        didSet {
            updateArtistInfo()
        }
    }
    var artistTopTracks: [SpotifyTrack] = [SpotifyTrack]()
    var spotify: Spotify = Spotify() {
        didSet {
            setupFirebaseListeners()
        }
    }
    
    //Firebase
    let reference: DatabaseReference = Database.database().reference()
    
    //Actions
    @IBAction func playSongs(_ sender: Any) {
        guard let loadingFinished = loadingFinished, loadingFinished else { return }
        let parent = self.parent as! NusicPageViewController
        let playerViewController = parent.showSongVC as! ShowSongViewController
        let songPickerViewController = parent.songPickerVC as! SongPickerViewController
        let likedTrackListVC = parent.songListVC as! SongListTabBarViewController
        parent.removeViewControllerFromPageVC(viewController: playerViewController)
        parent.removeViewControllerFromPageVC(viewController: likedTrackListVC)
        playerViewController.user = songPickerViewController.nusicUser;
        playerViewController.playlist = songPickerViewController.nusicPlaylist;
        playerViewController.spotifyHandler = songPickerViewController.spotifyHandler;
        let moodObject = NusicMood(emotions: [.init(basicGroup: .unknown)], date: Date())
        moodObject.userName = spotify.user.canonicalUserName
        playerViewController.moodObject = moodObject
        playerViewController.musicSearchType = .artist
        playerViewController.searchBasedOnArtist = [currentArtist!]
        playerViewController.isMoodSelected = false
        playerViewController.selectedSongs = artistTopTracks
        playerViewController.trackFeatures.removeAll()
        playerViewController.playedSongsHistory?.removeAll()
        playerViewController.playOnCellularData = songPickerViewController.nusicUser.settingValues.useMobileData
        playerViewController.newMoodOrGenre = true;
        parent.addViewControllerToPageVC(viewController: playerViewController)
        parent.scrollToViewController(viewController: parent.showSongVC!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotificationHandlers()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let loadingFinished = loadingFinished, !loadingFinished {
            DispatchQueue.main.async {
                SwiftSpinner.show("Loading...")
            }
        }
        super.viewWillAppear(animated)
        
       
        self.artistBioLabel.layoutIfNeeded()
        artistBioScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        
        
        
        self.view.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupArtistNameLabel()
    }
    
    fileprivate func setupUI() {
        setupArtistImageView()
        setupArtistBioLabel()
        setupArtistNameLabel()
        setupArtistSimilarLabel()
        setupArtistScrollView()
        setupNavigationBar()
        view.addSafeAreaExterior()
        
    }
    
    fileprivate func setupNavigationBar() {
        navigationBar.prefersLargeTitles = true
        navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: NusicDefaults.whiteColor]
        navigationBar.tintColor = NusicDefaults.whiteColor
        
        navigationItem.title = "Nusic Weekly"
        
        let leftBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "SettingsIcon"), style: .plain, target: self, action: #selector(toggleMenu));
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        let rightBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "MoodIcon"), style: .plain, target: self, action: #selector(goToSongPickerVC));
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        navigationBar.items = [navigationItem]
    }
    
    @objc fileprivate func toggleMenu() {
        let parent = self.parent as! NusicPageViewController
        parent.scrollToPreviousViewController()
    }
    
    @objc fileprivate func goToSongPickerVC() {
        let parent = self.parent as! NusicPageViewController
        parent.scrollToNextViewController()
    }
    
    fileprivate func setupNotificationHandlers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotificationSong), name: NSNotification.Name(rawValue: "nusicADayNotificationPushed"), object: nil)
    }
    
    @objc fileprivate func handleNotificationSong() {
        guard let suggestedTrackId = UserDefaults.standard.string(forKey: "suggestedSpotifyTrackId"), let parent = UIApplication.shared.keyWindow?.rootViewController as? NusicPageViewController, let songPickerVC = parent.songPickerVC as? SongPickerViewController else { return; }
        parent.scrollToViewController(viewController: songPickerVC)
        
        songPickerVC.isMoodSelected = false
        songPickerVC.moodObject = NusicMood(emotions: [.init(basicGroup: .unknown)], date: Date(), associatedGenres: [])
        spotify.getTrackInfo(for: [suggestedTrackId], offset: 0, currentExtractedTrackList: [], trackInfoListHandler: { (tracks, error) in
            guard let track = tracks else { error?.presentPopup(for: self); return; }
            UserDefaults.standard.removeObject(forKey: "suggestedSpotifyTrackId")
            UserDefaults.standard.synchronize()
            track.first?.suggestedSong = true
            songPickerVC.selectedSongsForGenre[EmotionDyad.unknown.rawValue] = track
            DispatchQueue.main.async {
                songPickerVC.passDataToShowSong()
            }
            
        })
    }
    
    fileprivate func setupArtistNameLabel() {
        artistNameLabel.addShadow()
        artistNameLabel.font = UIFont(name: "Synthetic Sharps", size: 80)
        artistNameLabel.textColor = NusicDefaults.foregroundThemeColor
        artistNameLabel.backgroundColor = NusicDefaults.clearColor
        artistNameTopConstraint.constant = self.view.bounds.height - self.navigationBar.bounds.height - self.artistNameLabel.bounds.height - self.artistBioTopConstraint.constant - self.playSongsButton.bounds.height - self.view.safeAreaInsets.bottom - self.view.safeAreaInsets.top - 40
        self.view.layoutIfNeeded()
    }
    
    fileprivate func setupArtistBioLabel() {
        artistBioLabel.textColor = NusicDefaults.whiteColor
        artistBioLabel.backgroundColor = NusicDefaults.clearColor
    }
    
    fileprivate func setupArtistSimilarLabel() {
        artistSimilarLabel.textColor = NusicDefaults.whiteColor
        artistSimilarLabel.backgroundColor = NusicDefaults.clearColor
    }
    
    fileprivate func setupArtistImageView() {
        artistImageView.contentMode = .scaleAspectFill
    }
    
    fileprivate func setupArtistScrollView() {
        artistBioScrollView.bounces = true
        artistBioScrollView.delaysContentTouches = false
        artistBioScrollView.canCancelContentTouches = true
        artistBioScrollView.scrollsToTop = true
        artistBioScrollView.delegate = self
    }
    
    fileprivate func updateValuesUI(){
        guard let lastFM = self.lastFM, let imageURL = URL(string: lastFM.imageUrl) else { return }
        DispatchQueue.main.async {
            let image = UIImage()
            image.downloadImage(from: imageURL, downloadImageHandler: { (downloadedImage) in
                UIView.transition(with: self.artistImageView, duration: 0.5, options: [.transitionCrossDissolve], animations: {
                    DispatchQueue.main.async {
                        self.artistImageView.image = downloadedImage
                        SwiftSpinner.show(duration: 1, title: "Done!")
                    }
                    
                }, completion: nil)
            })
            self.artistBioLabel.text = lastFM.bio
            let attributedArtistName = NSAttributedString(string: lastFM.name, attributes: [
                NSAttributedStringKey.foregroundColor : NusicDefaults.foregroundThemeColor,
                NSAttributedStringKey.strokeColor : UIColor.black,
                NSAttributedStringKey.strokeWidth : -1,
                NSAttributedStringKey.font : UIFont.systemFont(ofSize: 60, weight: UIFont.Weight.heavy)
                ])
            self.artistNameLabel.attributedText = attributedArtistName
            self.artistSimilarLabel.text = "Also look for: \(lastFM.listSimilarArtists())"
        }
        
    }
    
    fileprivate func fetchArtistInfo(artistID: String) {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        spotify.getArtistInfo(for: artistID) { (artist, error) in
            guard let artistName = artist?.artistName else { error?.presentPopup(for: self); return }
            self.currentArtist = artist
            LastFMAPI.getArtistInfo(for: artistName, completionHandler: { (lastFMObj, error) in
                guard let lastFM = lastFMObj else { return }
                self.lastFM = lastFM
                self.lastFM?.imageUrl = self.currentArtist?.imageUrl != "" ? (self.currentArtist?.imageUrl)! : lastFM.imageUrl
                dispatchGroup.leave()
            })
        }
        dispatchGroup.enter()
        spotify.getArtistTopTracks(for: artistID) { (tracks, error) in
            guard let tracks = tracks, error == nil else { return; }
            self.artistTopTracks = tracks
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            self.loadingFinished = true
        }
    }

    fileprivate func reloadViews(alpha: CGFloat) {
        
        artistImageView.removeBlurEffect()
        artistImageView.addBlurEffect(style: .dark, alpha: alpha)
        navigationBar.removeBlurEffect()
        navigationBar.addBlurEffect(style: .dark, alpha: alpha)
    }

    fileprivate func setupFirebaseListeners() {
        removeFirebaseListeners();
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        var artistID = ""
        guard let currentTimestamp = Int(dateFormatter.string(from: Date())) else { return }
        reference.child("weeklyArtist").queryOrdered(byChild: "isActive").queryEqual(toValue: true).observe(.value) { (dataSnapshot) in
            guard dataSnapshot.exists() else { self.fetchLastWeeklyArtist(); return }
            if let element = dataSnapshot.children.nextObject() as? DataSnapshot {
                artistID = element.childSnapshot(forPath: "id").value as! String
            }
            guard artistID != "" else { self.fetchLastWeeklyArtist(); return }
            self.fetchArtistInfo(artistID: artistID)
            
            
        }
        
    }
    
    fileprivate func fetchLastWeeklyArtist() {
        reference.child("weeklyArtist").queryOrdered(byChild: "startDate").queryLimited(toLast: 1).observe(.value) { (dataSnapshot) in
            guard dataSnapshot.exists() else { return }
            var artistID = ""
            if let element = dataSnapshot.children.nextObject() as? DataSnapshot {
                artistID = element.childSnapshot(forPath: "id").value as! String
            }
            self.fetchArtistInfo(artistID: artistID)
        }
    }
    
    fileprivate func removeFirebaseListeners() {
        reference.child("weeklyArtist/id").removeAllObservers()
    }

    fileprivate func updateArtistInfo() {
        for index in 0..<artistTopTracks.count {
            if let currentArtist = self.currentArtist, let artistIndex = artistTopTracks[index].artist.index(where: { $0.id == currentArtist.id }) {
                artistTopTracks[index].artist[artistIndex] = currentArtist
            }
        }
    }
}

extension NusicWeeklyViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var alpha: CGFloat = 0
        if scrollView.contentOffset.y < 0 {
            alpha = 0
        } else if scrollView.contentOffset.y > self.view.bounds.height/2-self.view.safeAreaInsets.top {
            alpha = 1
        } else {
            alpha = scrollView.contentOffset.y/(self.view.bounds.height/2-self.view.safeAreaInsets.top)
        }
        
        UIView.animate(withDuration: 0.2) {
            self.navigationBar.alpha = 1-alpha
        }
        
        reloadViews(alpha: alpha)

    }
}
