//
//  SuggestedSongListViewController.swift
//  Newsic
//
//  Created by Miguel Alcantara on 26/02/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SuggestedSongListViewController: UIViewController {

    //Outlets
    @IBOutlet weak var suggestedSongListTableView: UITableView!
    @IBOutlet weak var suggestedSongListTableHeader: SongTableViewHeader!
    
    //Constraints
    @IBOutlet weak var suggestedSongListTableViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var suggestedSongListTableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var suggestedSongListTableViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var suggestedSongListTableViewTopConstraint: NSLayoutConstraint!
    
    //Data variables
    var suggestedSongList:[NusicTrack] = Array() {
        didSet {
            reloadTable()
        }
    }
    
    //Table view data
    var sectionTitles:[String] = Array() {
        didSet {
            setupBackgroundView()
        }
    }
    var sectionSongs:[[NusicTrack]] = Array(Array())
    
    //Parent reference
    var tabBarVC: SongListTabBarViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if let parent = parent as? SongListTabBarViewController {
            self.tabBarVC = parent
        }
        self.view.backgroundColor = .clear
        updateBadgeCount()
        setupTableViewData()
        setupTableView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadTable()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupTableViewData() {
        sectionTitles.removeAll()
        sectionSongs.removeAll()
        for track in suggestedSongList {
            if let date = track.suggestionInfo?.suggestionDate {
                let dateString = date.toString(dateFormat: "dd-MM-yyyy")
                //Check if array contains suggestion date ( only date, no time considered )
                if !sectionTitles.contains(dateString) {
                    sectionTitles.append(dateString)
                    sectionSongs.append([track])
                } else {
                    if let titleIndex = sectionTitles.index(of: dateString) {
                        sectionSongs[titleIndex].append(track);
                    }
                }
            }
        }
    }

    func reloadTable() {
        DispatchQueue.main.async {
            if self.suggestedSongListTableView != nil {
                self.setupTableViewData()
                self.updateBadgeCount()
                self.suggestedSongListTableView.reloadData()
            }
        }
    }

    func updateBadgeCount() {
        self.tabBarItem.badgeValue = String(suggestedSongList.filter({ ($0.suggestionInfo?.isNewSuggestion)! }).count)
        if self.tabBarItem.badgeValue == "0" {
            self.tabBarItem.badgeValue = nil
        }
        
        if let badgeValue = self.tabBarItem.badgeValue, let intValue = Int(badgeValue) {
            UIApplication.shared.applicationIconBadgeNumber = intValue
        } else {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        
    }

}
