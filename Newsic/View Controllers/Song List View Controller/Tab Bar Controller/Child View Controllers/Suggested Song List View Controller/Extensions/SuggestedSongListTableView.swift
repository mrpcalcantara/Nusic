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
        suggestedSongListTableHeader.isUserInteractionEnabled = false
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
        suggestedSongListTableView.sectionHeaderHeight = UITableViewAutomaticDimension
        suggestedSongListTableView.tableFooterView = UIView();
        suggestedSongListTableView.backgroundColor = .clear
        
        suggestedSongListTableHeader.configureSuggestedList()
        
    }
    
    func getHeaderString(date: Date) -> String {
        let timeInterval = date.timeIntervalSinceNow*(-1)
        let oneDay:Double = 60*60*24 // 1 day to seconds
        let twoDays:Double = oneDay*2
        if timeInterval < oneDay {
            return "Today"
        } else if timeInterval > oneDay && timeInterval < twoDays {
            return "Yesterday"
        } else {
            return date.toString(dateFormat: "dd MMMM yyyy")
        }
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
        if let cell = tableView.cellForRow(at: indexPath) as? SongTableViewCell {
            cell.setColor(color: .clear)
            print(cell)
        }
        var track = suggestedSongList[indexPath.section]
        track.setSuggestedValue(value: false, suggestedHandler: nil);
        suggestedSongList[indexPath.section] = track
        updateBadgeCount()
        tabBarVC?.playSelectedCard(track: track)
        tableView.deselectRow(at: indexPath, animated: true);
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: SongTableViewSectionHeader.reuseIdentifier) as? SongTableViewSectionHeader else { return UIView(); }
        
        var text = ""
        if let suggestionDate = suggestedSongList[section].suggestionInfo?.suggestionDate {
            text = getHeaderString(date: suggestionDate)
        }
        cell.configure(text: text)
        
        return cell
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
    
}

extension SuggestedSongListViewController : SongTableViewHeaderDelegate {
    func touchedHeader() {
        
    }
    
}



