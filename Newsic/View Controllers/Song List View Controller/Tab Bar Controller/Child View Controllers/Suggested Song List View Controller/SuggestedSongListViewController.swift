//
//  SuggestedSongListViewController.swift
//  Newsic
//
//  Created by Miguel Alcantara on 26/02/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SuggestedSongListViewController: NusicDefaultViewController {

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
    
    final func setupTableViewData() {
        sectionTitles.removeAll()
        sectionSongs.removeAll()
        for track in suggestedSongList {
            guard let date = track.suggestionInfo?.suggestionDate else { break }
            let dateString = date.toString(dateFormat: "dd-MM-yyyy")
            //Check if array contains suggestion date ( only date, no time considered )
            if !sectionTitles.contains(dateString) {
                sectionTitles.append(dateString)
                sectionSongs.append([track])
            } else {
                guard let titleIndex = sectionTitles.index(of: dateString) else { break }
                sectionSongs[titleIndex].append(track);
            }
        }
    }

    final func reloadTable() {
        DispatchQueue.main.async {
            guard self.suggestedSongListTableView != nil else { return }
            self.setupTableViewData()
            self.updateBadgeCount()
            self.suggestedSongListTableView.reloadData()
        }
    }

    final func updateBadgeCount() {
        self.tabBarItem.badgeValue = String(suggestedSongList.filter({ ($0.suggestionInfo?.isNewSuggestion)! }).count)
        if self.tabBarItem.badgeValue == "0" {
            self.tabBarItem.badgeValue = nil
        }
        
        guard let badgeValue = self.tabBarItem.badgeValue, let intValue = Int(badgeValue) else { UIApplication.shared.applicationIconBadgeNumber = 0; return }
        UIApplication.shared.applicationIconBadgeNumber = intValue
    }

}
