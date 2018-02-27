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
    
    var tabBarVC: SongListTabBarViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let parent = parent as? SongListTabBarViewController {
            self.tabBarVC = parent
        }
        self.view.backgroundColor = .clear
        updateBadgeCount()
        setupTableView()
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

    func reloadTable() {
        DispatchQueue.main.async {
            if self.suggestedSongListTableView != nil {
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
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
