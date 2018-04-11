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
    
    
    //View variables
    let sectionInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8);
    var sectionHeaderFrame: CGRect = CGRect(x: 16, y: 8, width: 0, height: 0)
    var navbar: UINavigationBar = UINavigationBar()
    var spinner: SwiftSpinner! = nil
    var listMenuView: ChoiceListView! = nil
    var viewRotated:Bool = false
    var cellsPerRow: CGFloat = 0
    var nusicControl: NusicSegmentedControl!
    var currentSection: Int = 0
    let itemsPerRow: CGFloat = 2;
    var selectedIndexPathForMood: IndexPath?
    var sectionGenreTitles: [String] = []
    var sectionMoodTitles: [String] = []
    var sectionMoods: [[EmotionDyad]] = Array(Array()) {
        didSet {
            moodCollectionView.reloadData()
        }
    }
    var nusicParent: NusicPageViewController?
    
    let collectionViewsPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panCollectionViews(_:)))
    let scrollToNusicWeeklyGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeToNusicWeekly))
    let scrollToShowSongGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeToShowSong))
    
    //Nusic data variables
    var nusicPlaylist: NusicPlaylist! = nil;
    var moodObject: NusicMood? = NusicMood();
    var nusicUser: NusicUser! = nil
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
    
    var loadingFinished: Bool = false {
        didSet {
            guard self.spotifyHandler.user != nil && self.spotifyHandler.user.canonicalUserName != nil, sectionMoods.count == 0 else { SwiftSpinner.show(duration: 2, title: "Done!", animated: true); return }
            FirebaseDatabaseHelper.fetchAllMoods(user: self.spotifyHandler.user.canonicalUserName) { (dyadList, error) in
                self.toggleCollectionViews(for: 0)
                self.sectionMoodTitles = dyadList.keys.map({ $0.rawValue })
                self.sectionMoods = dyadList.map({ $0.value })
            }
        }
    }
    
    //Spotify variabless
    var fullArtistList = [SpotifyArtist]();
    var fullPlaylistList = [SPTPartialPlaylist]()
    var genreList:[SpotifyGenres] = SpotifyGenres.allShownValues;
    var sectionGenres: [[SpotifyGenres]] = Array(Array())
    var spotifyHandler = Spotify()
    var user: SPTUser? = nil;
    var fetchedSongsForMood: [String: [SpotifyTrack]] = [:]
    var selectedSongsForMood: [String: [SpotifyTrack]] = [:]
    var fetchedSongsForGenre: [String: [SpotifyTrack]] = [:]
    var selectedSongsForGenre: [String: [SpotifyTrack]] = [:] {
        didSet {
            if selectedSongsForGenre.count == 0 {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.searchButton.setTitle(self.isMoodCellSelected ? "Get Songs!" : "Random it up!", for: .normal)
                    }, completion: nil)
                    self.view.layoutIfNeeded()
                }
            } else {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.searchButton.setTitle("Get Songs!", for: .normal)
                    }, completion: nil)
                    self.view.layoutIfNeeded()
                }
            }
            
        }
    }
    
    //Constraints
    @IBOutlet weak var moodCollectionTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var moodCollectionLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var moodCollectionBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var moodCollectionTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var genreCollectionLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var genreCollectionBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var genreCollectionTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var genreCollectionTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var listViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var listViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var listViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var listViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchButtonHeightConstraint: NSLayoutConstraint!
    //Outlets
    @IBOutlet weak var mainControlView: UIView!
    @IBOutlet weak var moodCollectionView: UICollectionView!
    @IBOutlet weak var genreCollectionView: UICollectionView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    
    //Actions
    
    @IBAction func getNewSong(_ sender: Any) {
        isMoodSelected = nusicControl.selectedIndex == 0 ? true : false
        if !isMoodSelected {
            let nusicMood = NusicMood()
            nusicMood.emotions = [Emotion(basicGroup: .unknown)]
            self.moodObject = nusicMood
        }
        
        if selectedIndexPathForMood != nil {
            invalidateCellsLayout(for: moodCollectionView)
        }

        self.moodObject?.userName = self.spotifyHandler.auth.session.canonicalUsername
        guard Connectivity.isConnectedToNetwork() == .connectedCellular && nusicUser.settingValues.useMobileData! == false else { passDataToShowSong(); return }
        showMobileDataPopup()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        invalidateCellsLayout(for: moodCollectionView)
        invalidateCellsLayout(for: genreCollectionView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if viewRotated {
            reloadCellsData(for: moodCollectionView)
            reloadCellsData(for: genreCollectionView)
            
            var newY:CGFloat = 0
            if !listMenuView.isShowing {
                newY = self.view.frame.height
            } else {
                newY = listMenuView.isOpen ? self.view.frame.height/2 : self.view.safeAreaLayoutGuide.layoutFrame.maxY - listMenuView.toggleViewHeight
            }
            listMenuView.maxY = self.view.safeAreaLayoutGuide.layoutFrame.maxY - listMenuView.toggleViewHeight
            listMenuView.frame = CGRect(x: listMenuView.frame.origin.x, y: newY, width: self.view.frame.width, height: listMenuView.frame.height)
            listMenuView.reloadView()
            searchButton.reloadBlurEffect()
            self.view.layoutIfNeeded()
            viewRotated = false
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.layoutIfNeeded()
        self.mainControlView.layoutIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated);
        if nusicControl.selectedIndex == 1 && listMenuView.chosenGenres.count > 0 {
            hideChoiceMenu()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        viewRotated = true
        if nusicControl.selectedIndex == 1 && listMenuView.chosenGenres.count > 0 {
            hideChoiceMenu()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard self.loadingFinished else { return; }
        moodCollectionView.collectionViewLayout.invalidateLayout()
        genreCollectionView.collectionViewLayout.invalidateLayout()
        reloadCellsData(for: moodCollectionView)
        reloadCellsData(for: genreCollectionView)
        reloadListMenu()
        reloadNavigationBar()
        self.view.addSafeAreaExterior()
//        self.view.layoutIfNeeded()
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionCellViews();
        setupView()
        setupListMenu()
        setupSegmentedControl()
        setupNavigationBar()
        loadingFinished = true
    }
    
    fileprivate func setupSegmentedControl() {
        nusicControl = NusicSegmentedControl(frame: navbar.frame)
        nusicControl.frame.size = CGSize(width: nusicControl.frame.width, height: 44)
        
        nusicControl.translatesAutoresizingMaskIntoConstraints = false
        nusicControl.layoutIfNeeded()
        nusicControl.sizeToFit()
        nusicControl.translatesAutoresizingMaskIntoConstraints = true
        nusicControl.delegate = self
        nusicControl.thumbColor = NusicDefaults.foregroundThemeColor
        nusicControl.borderColor = NusicDefaults.foregroundThemeColor
        nusicControl.selectedIndex = 0
    }
    
    fileprivate func setupNavigationBar(image: UIImage? = UIImage(named: "ButtonAppIcon")) {
        navigationBar.barStyle = .default
        
        let leftBarButton = UIBarButtonItem(image: image!, style: .plain, target: self, action: #selector(toggleMenu));
        
        self.navigationItem.leftBarButtonItem = leftBarButton
        let showSongImage = UIImage(named: "PreferredPlayer")?.withRenderingMode(.alwaysTemplate)
        let rightBarButton = UIBarButtonItem(image: showSongImage, style: .plain, target: self, action: #selector(goToShowSongVC));
        guard let pageViewController = parent as? NusicPageViewController else { return }
        if pageViewController.orderedViewControllers.contains(pageViewController.showSongVC!) {
            rightBarButton.tintColor = UIColor.white
            rightBarButton.isEnabled = true
            mainControlView.addGestureRecognizer(scrollToShowSongGestureRecognizer)
        } else {
            rightBarButton.tintColor = UIColor.gray
            rightBarButton.isEnabled = false
            mainControlView.removeGestureRecognizer(scrollToShowSongGestureRecognizer)
        }
        self.navigationItem.rightBarButtonItem = rightBarButton
        nusicControl.frame.size.height = self.navigationBar.bounds.height
        self.navigationItem.titleView = nusicControl
        
        let navItem = self.navigationItem
        navigationBar.items = [navItem]
        
        self.view.layoutIfNeeded()
        
    }
    
    fileprivate func reloadNavigationBar(image: UIImage? = UIImage(named: "SettingsIcon")) {
        guard let pageViewController = parent as? NusicPageViewController else { return }
        if pageViewController.orderedViewControllers.contains(pageViewController.showSongVC!) {
            navigationBar.topItem?.rightBarButtonItem?.tintColor = UIColor.white
            navigationBar.topItem?.rightBarButtonItem?.isEnabled = true
            mainControlView.addGestureRecognizer(scrollToShowSongGestureRecognizer)
        } else {
            navigationBar.topItem?.rightBarButtonItem?.tintColor = UIColor.gray
            navigationBar.topItem?.rightBarButtonItem?.isEnabled = false
            mainControlView.removeGestureRecognizer(scrollToShowSongGestureRecognizer)
        }
        self.view.layoutIfNeeded()
    }
    
    fileprivate func setupView() {
        self.mainControlView.backgroundColor = UIColor.clear
        self.genreCollectionView.backgroundColor = UIColor.clear
//        genreCollectionView.layer.zPosition = -1
//        genreCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        self.moodCollectionView.backgroundColor = UIColor.clear
//        moodCollectionView.layer.zPosition = -1
//        moodCollectionView.translatesAutoresizingMaskIntoConstraints = false
        self.searchButton.backgroundColor = UIColor.clear
        self.searchButton.setTitle("Random it up!", for: .normal)
        
        
        
        
        self.mainControlView.addGestureRecognizer(collectionViewsPanGestureRecognizer)
        
        guard let nusicParent = self.parent as? NusicPageViewController else { return }
        self.nusicParent = nusicParent
        
        scrollToNusicWeeklyGestureRecognizer.direction = .right
        self.mainControlView.addGestureRecognizer(scrollToNusicWeeklyGestureRecognizer)
        
        scrollToShowSongGestureRecognizer.direction = .left
    }
    
    @objc func swipeToNusicWeekly() {
        nusicParent?.scrollToPreviousViewController()
    }
    
    @objc func swipeToShowSong() {
        nusicParent?.scrollToNextViewController()
    }
    
    
    
    @objc fileprivate func toggleMenu() {
        let parent = self.parent as! NusicPageViewController
        parent.scrollToPreviousViewController()
    }
    
    @objc fileprivate func goToShowSongVC() {
        let parent = self.parent as! NusicPageViewController
        parent.scrollToNextViewController()
    }
    
    fileprivate func manageViewControllerShowSong() {
        let pageVC = (self.parent as! NusicPageViewController)
        if SPTAudioStreamingController.sharedInstance().initialized {
            pageVC.addViewControllerToPageVC(viewController: pageVC.showSongVC!)
        } else {
            pageVC.removeViewControllerFromPageVC(viewController: pageVC.showSongVC!)
        }
    }
    
    fileprivate func showMobileDataPopup(){
        let dialog = PopupDialog(title: "Warning!", message: "We detected that you are using mobile data and have set the app to not use this data. Please connect to a WiFi network or enable Mobile Data usage in the Settings.", transitionStyle: .zoomIn, gestureDismissal: false, completion: nil)
        
        dialog.addButton(DefaultButton(title: "Got it!", action: nil))
        
        self.present(dialog, animated: true, completion: nil)
    }
    
    

}


extension SongPickerViewController: UIGestureRecognizerDelegate {
    
    @objc final func panCollectionViews(_ gestureRecognizer: UIPanGestureRecognizer) {
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
                print(progress)
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


