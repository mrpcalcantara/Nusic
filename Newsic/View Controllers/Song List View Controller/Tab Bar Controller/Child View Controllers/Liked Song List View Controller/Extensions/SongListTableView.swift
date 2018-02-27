//
//  SongListTableView.swift
//  Nusic
//
//  Created by Miguel Alcantara on 15/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

extension LikedSongListViewController {
    
    func setupTableView() {
        songListTableView.delegate = self;
        songListTableView.dataSource = self;
        
        songListTableView.canCancelContentTouches = true
        let view = UINib(nibName: SongTableViewCell.className, bundle: nil);
        songListTableView.register(view, forCellReuseIdentifier: SongTableViewCell.reuseIdentifier);
        
        let headerView = UINib(nibName: SongTableViewSectionHeader.className, bundle: nil);
        songListTableView.register(headerView, forHeaderFooterViewReuseIdentifier: SongTableViewSectionHeader.reuseIdentifier)
        
        songListTableViewHeader.setupView()
        songListTableViewHeader.delegate = self
        
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeftFunc))
        swipeLeft.direction = .left
        swipeLeft.numberOfTouchesRequired = 2
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeRightFunc))
        swipeRight.direction = .right
        swipeRight.numberOfTouchesRequired = 2
        
        songListTableView.addGestureRecognizer(swipeLeft)
        songListTableView.addGestureRecognizer(swipeRight)
        setupView();
    }
    
    @objc func swipeLeftFunc() {
        print("swiped left")
    }
    
    @objc func swipeRightFunc() {
        print("swiped right")
    }
    
    fileprivate func setupView() {
        songListTableView.isHidden = false
        songListTableView.rowHeight = UITableViewAutomaticDimension
        songListTableView.estimatedRowHeight = 90.0
        songListTableView.estimatedSectionHeaderHeight = 60
        songListTableView.tableFooterView = UIView();
        let image = UIImage(named: "SongMenuBackgroundPattern")
        if let image = image {
//            songListTableView.backgroundColor = UIColor(patternImage: image);
            songListTableView.backgroundColor = .clear
        }
        
        let emotion = moodObject?.emotions.first?.basicGroup.rawValue
        songListTableViewHeader.configureLikedList(isMoodSelected: isMoodSelected, emotion: emotion)
        
    }
    
}

extension LikedSongListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90;
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let track = sectionSongs[indexPath.section][indexPath.row]
        tabBarVC?.playSelectedCard(track: track)
        tableView.deselectRow(at: indexPath, animated: true);
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: SongTableViewSectionHeader.reuseIdentifier) as? SongTableViewSectionHeader else { return UIView(); }
        
        if let text = sectionTitles[section] {
            cell.configure(text: text)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "\u{267A}") { (action, indexPath) in
            // delete item at indexPath
            let track = self.sectionSongs[indexPath.section][indexPath.row]
            self.tabBarVC?.removeTrackFromLikedTracks(track: track, indexPath: indexPath)
            self.sectionSongs[indexPath.section].remove(at: indexPath.row)
        }
        return [delete]
    }

}

extension LikedSongListViewController: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count;
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionSongs[section].count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let regCell = tableView.dequeueReusableCell(withIdentifier: SongTableViewCell.reuseIdentifier, for: indexPath) as? SongTableViewCell else {
            fatalError("Unexpected Index Path")
        }
        regCell.configure(for: sectionSongs[indexPath.section][indexPath.row])
        return regCell;
    }
    
    func sortTableView(by type: SpotifyType) {
        switch type {
        case .artist:
            sectionTitles = likedTrackList.map { String($0.trackInfo.artist.artistName.capitalizingFirstLetter().first!) }.getFirstLetterArray(removeDuplicates: true).sorted()
            sectionSongs = sectionTitles.map({ (firstLetter) in
                return likedTrackList.filter({ (track) -> Bool in
                    return track.trackInfo.artist.artistName.first?.description == firstLetter
                })
            })
        case .track:
            sectionTitles = likedTrackList.map { String($0.trackInfo.songName.capitalizingFirstLetter().first!) }.getFirstLetterArray(removeDuplicates: true).sorted()
            sectionSongs = sectionTitles.map({ (firstLetter) in
                return likedTrackList.filter({ (track) -> Bool in
                    return track.trackInfo.songName.first?.description == firstLetter
                })
            })
        case .genre:
            let list = likedTrackList.map({ (track) -> String in
                if let subGenres = track.trackInfo.artist.subGenres {
                    return subGenres.first!.capitalizingFirstLetter()
                }
                return ""
            })
            
            let sortedList = list.filter({ (str) -> Bool in
                return str != "" || !list.contains(str)
            }).removeDuplicates().sorted()
            sectionTitles = sortedList
            
            sectionSongs = sortedList.map({ (genre) in
                return likedTrackList.filter({ (track) -> Bool in
                    if let subGenres = track.trackInfo.artist.subGenres {
                        return subGenres.contains(genre.lowercased())
                    }
                    return false
                })
            })
        default:
            break;
        }
        
    }
    
}

extension LikedSongListViewController : SongTableViewHeaderDelegate {
    func touchedHeader() {
        sortTableView(by: songListTableViewHeader.currentSortElement)
        DispatchQueue.main.async {
            self.songListTableView.reloadData()
        }
    }
}


