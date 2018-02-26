//
//  LikedSongListViewController.swift
//  Newsic
//
//  Created by Miguel Alcantara on 26/02/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import UIKit

class SongListTabBarViewController: UITabBarController {

    //Tab Bar variables
    var navbar: UINavigationBar = UINavigationBar()
    
    //Data Variables
    var showSongVC: ShowSongViewController?
    var moodObject: NusicMood?
    var isMoodSelected: Bool = false
    
    //Table View
    var sectionTitles: [String?] = Array()
    var sectionSongs: [[NusicTrack]] = Array(Array())
    var likedTrackList:[NusicTrack] = Array() {
        didSet {
            if let likedSongListVC = likedSongListVC {
                likedSongListVC.likedTrackList = likedTrackList
            }
        }
    }
    var suggestedTrackList:[NusicTrack] = Array() {
        didSet {
            if let suggestedSongListVC = suggestedSongListVC {
                suggestedSongListVC.suggestedSongList = suggestedTrackList
            }
        }
    }
    
    //Child View Controllers
    private var likedSongListVC: LikedSongListViewController?
    private var suggestedSongListVC: SuggestedSongListViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTabBarController()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setupNavigationBar(image: UIImage? = UIImage(named: "PreferredPlayer")) {
        navbar = UINavigationBar(frame: CGRect(x: 0, y: self.view.safeAreaLayoutGuide.layoutFrame.origin.y, width: self.view.frame.width, height: 44));
        
        navbar.barStyle = .default
        navbar.translatesAutoresizingMaskIntoConstraints = false
        
        let leftBarButton = UIBarButtonItem(image: image!, style: .plain, target: self, action: #selector(moveToShowSongVC));
        self.navigationItem.leftBarButtonItem = leftBarButton
        
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
            navbar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0),
            
            ])
        
        self.view.layoutIfNeeded()
        
    }
    
    func setupTabBarController() {
        self.view.backgroundColor = .clear
        
        if let parent = self.parent as? NusicPageViewController {
            if let showSongVC = parent.showSongVC as? ShowSongViewController {
                self.showSongVC = showSongVC
            }
        }
        
        if let viewControllers = self.viewControllers {
            for viewController in viewControllers {
                setupViewController(viewController: viewController)
            }
        }
    }
    
    func setupViewController(viewController: UIViewController) {
        switch viewController.className {
        case LikedSongListViewController.className:
            self.likedSongListVC = viewController as? LikedSongListViewController
            setupLikedSongListVC()
        case SuggestedSongListViewController.className:
            self.suggestedSongListVC = viewController as? SuggestedSongListViewController
            setupSuggestedSongListVC()
        default:
            print()
        }
    }
    
    func setupLikedSongListVC() {
        self.likedSongListVC?.isMoodSelected = isMoodSelected
        self.likedSongListVC?.likedTrackList = likedTrackList
        self.likedSongListVC?.moodObject = moodObject
    }
    
    func setupSuggestedSongListVC() {
        self.suggestedSongListVC?.suggestedSongList = suggestedTrackList
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func moveToShowSongVC() {
        (parent as! NusicPageViewController).scrollToPreviousViewController();
    }

    func playSelectedCard(track: NusicTrack) {
        showSongVC?.playSelectedCard(track: track);
        if let parent = parent as? NusicPageViewController {
            parent.scrollToPreviousViewController()
        }
    }
    
    func removeTrackFromLikedTracks(indexPath: IndexPath) {
        showSongVC?.removeTrackFromLikedTracks(indexPath: indexPath, removeTrackHandler: { (isRemoved) in
            DispatchQueue.main.async {
                self.likedSongListVC?.songListTableView.reloadData()
            }
        })
    }
}
