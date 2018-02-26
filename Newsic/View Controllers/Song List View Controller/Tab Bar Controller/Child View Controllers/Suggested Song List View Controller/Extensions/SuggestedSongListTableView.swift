//
//  SuggestedsuggestedsuggestedSongListTableView.swift
//  Nusic
//
//  Created by Miguel Alcantara on 26/02/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import UIKit

extension SuggestedSongListViewController {
    
    func setupTableView() {
        suggestedSongListTableView.delegate = self;
        suggestedSongListTableView.dataSource = self;
        
        suggestedSongListTableView.canCancelContentTouches = true
        let view = UINib(nibName: SongTableViewCell.className, bundle: nil);
        suggestedSongListTableView.register(view, forCellReuseIdentifier: SongTableViewCell.reuseIdentifier);
        
        let headerView = UINib(nibName: SongTableViewSectionHeader.className, bundle: nil);
        suggestedSongListTableView.register(headerView, forHeaderFooterViewReuseIdentifier: SongTableViewSectionHeader.reuseIdentifier)
        
        suggestedSongListTableHeader.setupView()
        suggestedSongListTableHeader.delegate = self
        
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeftFunc))
        swipeLeft.direction = .left
        swipeLeft.numberOfTouchesRequired = 2
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeRightFunc))
        swipeRight.direction = .right
        swipeRight.numberOfTouchesRequired = 2
        
        suggestedSongListTableView.addGestureRecognizer(swipeLeft)
        suggestedSongListTableView.addGestureRecognizer(swipeRight)
        setupView();
    }
    
    @objc func swipeLeftFunc() {
        print("swiped left")
    }
    
    @objc func swipeRightFunc() {
        print("swiped right")
    }
    
    fileprivate func setupView() {
        suggestedSongListTableView.isHidden = false
        suggestedSongListTableView.rowHeight = UITableViewAutomaticDimension
        suggestedSongListTableView.estimatedRowHeight = 90.0
        suggestedSongListTableView.tableFooterView = UIView();
        let image = UIImage(named: "SongMenuBackgroundPattern")
        if let image = image {
            //            suggestedSongListTableView.backgroundColor = UIColor(patternImage: image);
            suggestedSongListTableView.backgroundColor = .clear
        }
        
        
        suggestedSongListTableHeader.configure(isMoodSelected: false, emotion: nil)
        
    }
    
}

extension SuggestedSongListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90;
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let track = suggestedSongList[indexPath.section]
        tabBarVC?.playSelectedCard(track: track)
        tableView.deselectRow(at: indexPath, animated: true);
    }
    
}

extension SuggestedSongListViewController: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return suggestedSongList.count;
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let regCell = tableView.dequeueReusableCell(withIdentifier: SongTableViewCell.reuseIdentifier, for: indexPath) as? SongTableViewCell else {
            fatalError("Unexpected Index Path")
        }
        regCell.configure(for: suggestedSongList[indexPath.section])
        return regCell;
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return sectionTitles[section]
        return "sectionTitle"
    }
    
}

extension SuggestedSongListViewController : SongTableViewHeaderDelegate {
    func touchedHeader() {
        
    }
}



