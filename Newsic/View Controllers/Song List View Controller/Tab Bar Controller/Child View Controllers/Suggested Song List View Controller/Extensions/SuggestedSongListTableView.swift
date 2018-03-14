//
//  SuggestedsuggestedsuggestedSongListTableView.swift
//  Nusic
//
//  Created by Miguel Alcantara on 26/02/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import UIKit

extension SuggestedSongListViewController {
    
    final func setupTableView() {
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
        
        setupView();
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
    
    private func getHeaderString(date: Date) -> String {
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
    
    final func setupBackgroundView() {
        if sectionTitles.count == 0 {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: suggestedSongListTableView.bounds.width, height: suggestedSongListTableView.bounds.height))
            label.text = "No Nusic suggestions so far. One new suggestion will appear daily!"
            label.numberOfLines = 3
            label.textColor = UIColor.lightText
            label.textAlignment = .center
            suggestedSongListTableView.backgroundView = label
            suggestedSongListTableView.separatorStyle = .none
        } else {
            suggestedSongListTableView.backgroundView = nil
            suggestedSongListTableView.separatorStyle = .singleLine
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
        let track = sectionSongs[indexPath.section][indexPath.row]
        track.setSuggestedValue(value: false, suggestedHandler: nil);
        sectionSongs[indexPath.section][indexPath.row] = track
        updateBadgeCount()
        tabBarVC?.playSelectedCard(track: track)
        tableView.deselectRow(at: indexPath, animated: true);
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: SongTableViewSectionHeader.reuseIdentifier) as? SongTableViewSectionHeader else { return UIView(); }
        
        let date = Date();
        let formattedDate = date.fromString(dateString: sectionTitles[section], dateFormat: "dd-MM-yyyy")
        cell.configure(text: getHeaderString(date: formattedDate))
        
        return cell
    }
}

extension SuggestedSongListViewController: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count;
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionSongs[section].count;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let regCell = tableView.dequeueReusableCell(withIdentifier: SongTableViewCell.reuseIdentifier, for: indexPath) as? SongTableViewCell else {
            fatalError("Unexpected Index Path")
        }
        regCell.configure(for: sectionSongs[indexPath.section][indexPath.row])
        return regCell;
    }
    
}

extension SuggestedSongListViewController : SongTableViewHeaderDelegate {
    func touchedHeader() {
        
    }
    
}



