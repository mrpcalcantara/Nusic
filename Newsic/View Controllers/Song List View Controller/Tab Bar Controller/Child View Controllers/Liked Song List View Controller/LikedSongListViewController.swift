//
//  LikedSongListViewController.swift
//  Newsic
//
//  Created by Miguel Alcantara on 26/02/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import UIKit

class LikedSongListViewController: UIViewController {

    //Outlets
    @IBOutlet weak var songListTableView: UITableView!
    @IBOutlet weak var songListTableViewHeader: SongTableViewHeader!
    
    //Constraints
    @IBOutlet weak var songListTableViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var songListTableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var songListTableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var songListTableViewLeadingConstraint: NSLayoutConstraint!
    
    //Data Variables
    var moodObject: NusicMood?
    var isMoodSelected: Bool = false
    
    //Table View
    var sectionTitles: [String?] = Array()
    var sectionSongs: [[NusicTrack]] = Array(Array())
    var likedTrackList:[NusicTrack] = [] {
        didSet {
            print("likedTrackList count = \(likedTrackList.count)")
            DispatchQueue.main.async {
                if self.songListTableView != nil {
                    self.songListTableView.reloadData()
                    self.songListTableView.layoutIfNeeded()
                    self.sortTableView(by: self.songListTableViewHeader.currentSortElement)
                }
            }
        }
    }
    
    var tabBarVC: SongListTabBarViewController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let parent = parent as? SongListTabBarViewController {
            self.tabBarVC = parent
        }
        setupLikedSongListVC()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if songListTableViewTopConstraint != nil {
            songListTableViewTopConstraint.isActive = false
            songListTableView.topAnchor.constraint(equalTo: (tabBarVC?.navbar.bottomAnchor)!).isActive = true
        }
        
        sortTableView(by: songListTableViewHeader.currentSortElement)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupLikedSongListVC() {
        self.view.backgroundColor = .clear
        setupTableView()
    }
}
