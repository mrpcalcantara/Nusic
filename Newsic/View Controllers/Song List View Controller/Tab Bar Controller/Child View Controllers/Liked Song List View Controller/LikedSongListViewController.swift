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
    var moodObject: NusicMood? {
        didSet {
            let emotion = moodObject?.emotions.first?.basicGroup.rawValue
            songListTableViewHeader.configureLikedList(isMoodSelected: isMoodSelected, emotion: emotion)
        }
    }
    var isMoodSelected: Bool = false
    var likedTrackList:[NusicTrack] = [] {
        didSet {
            reloadTable()
        }
    }
    
    //Table view data
    var sectionTitles: [String?] = Array() {
        didSet {
            setupBackgroundView()
        }
    }
    var sectionSongs: [[NusicTrack]] = Array(Array())
    
    
    //Parent reference
    var tabBarVC: SongListTabBarViewController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let parent = parent as? SongListTabBarViewController {
            self.tabBarVC = parent
        }
        setupLikedSongListVC()
        reloadTable()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadTable()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupLikedSongListVC() {
        self.view.backgroundColor = .clear
        setupTableView()
    }
    
    func reloadTable() {
        DispatchQueue.main.async {
            if self.songListTableView != nil {
                self.songListTableView.reloadData()
                self.sortTableView(by: self.songListTableViewHeader.currentSortElement)
            }
        }
    }
}
