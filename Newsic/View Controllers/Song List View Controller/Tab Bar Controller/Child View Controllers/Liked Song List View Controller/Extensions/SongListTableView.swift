//
//  SongListTableView.swift
//  Nusic
//
//  Created by Miguel Alcantara on 15/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

extension LikedSongListViewController {
    
    final func setupTableView() {
        songListTableView.delegate = self;
        songListTableView.dataSource = self;
        
        songListTableView.canCancelContentTouches = true
        let view = UINib(nibName: SongTableViewCell.className, bundle: nil);
        songListTableView.register(view, forCellReuseIdentifier: SongTableViewCell.reuseIdentifier);
        
        let headerView = UINib(nibName: SongTableViewSectionHeader.className, bundle: nil);
        songListTableView.register(headerView, forHeaderFooterViewReuseIdentifier: SongTableViewSectionHeader.reuseIdentifier)
        
        songListTableViewHeader.setupView()
        songListTableViewHeader.delegate = self
        
        setupView();
    }
    
    fileprivate func setupView() {
        songListTableView.isHidden = false
        songListTableView.rowHeight = UITableViewAutomaticDimension
        songListTableView.estimatedRowHeight = 90.0
        songListTableView.estimatedSectionHeaderHeight = 60
        songListTableView.tableFooterView = UIView();
        songListTableView.backgroundColor = .clear
    }
    
    final func setupBackgroundView() {
        if sectionTitles.count == 0 {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: songListTableView.bounds.width, height: songListTableView.bounds.height))
            label.text = "No tracks have been liked so far. Like a song to add to your list!"
            label.numberOfLines = 3
            label.textColor = UIColor.lightText
            label.textAlignment = .center
            songListTableView.backgroundView = label
            songListTableView.separatorStyle = .none
        } else {
            songListTableView.backgroundView = nil
            songListTableView.separatorStyle = .singleLine
        }
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
        guard let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: SongTableViewSectionHeader.reuseIdentifier) as? SongTableViewSectionHeader, let text = sectionTitles[section] else { return UIView(); }
        cell.configure(text: text)
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "\u{267A}") { (action, indexPath) in
            DispatchQueue.main.async {
                // delete item at indexPath
                let track = self.sectionSongs[indexPath.section][indexPath.row]
                self.sectionSongs[indexPath.section].remove(at: indexPath.row)
                self.tabBarVC?.removeTrackFromLikedTracks(track: track, indexPath: indexPath)
            }
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
    
    final func sortTableView(by type: SpotifyType) {
        switch type {
        case .artist:
            artistTableViewSort()
        case .track:
            trackTableViewSort()
        case .genre:
            genreTableViewSort()
        default:
            break;
        }
        
    }
    
    fileprivate func artistTableViewSort() {
        sectionTitles = likedTrackList.map { String($0.trackInfo.artist.namesToString().capitalizingFirstLetter().first!) }.getFirstLetterArray(removeDuplicates: true).sorted()
        
        sectionSongs = sectionTitles.map({ (firstLetter) in
            return likedTrackList.filter({ (track) -> Bool in
                return track.trackInfo.artist.namesToString().first?.description == firstLetter
            })
        })
    }
    
    fileprivate func trackTableViewSort() {
        sectionTitles = likedTrackList.map { String($0.trackInfo.songName.capitalizingFirstLetter().first!) }.getFirstLetterArray(removeDuplicates: true).sorted()
        sectionSongs = sectionTitles.map({ (firstLetter) in
            return likedTrackList.filter({ (track) -> Bool in
                return track.trackInfo.songName.first?.description == firstLetter
            })
        })
    }
    
    fileprivate func genreTableViewSort() {
        let list = likedTrackList.map({ (track) -> String in
            if let firstLetter = track.trackInfo.artist.listArtistsGenres().first?.capitalizingFirstLetter() {
                return firstLetter
            }
            return ""
        })
        
        let sortedList = list.filter({ (str) -> Bool in
            return str != "" || !list.contains(str)
        }).removeDuplicates().sorted()
        sectionTitles = sortedList
        sectionSongs = sortedList.map({ (genre) in
            return likedTrackList.filter({ (track) -> Bool in
                return track.trackInfo.artist.listArtistsGenres().contains(genre.lowercased())
            })
        })
    }
}

extension LikedSongListViewController : SongTableViewHeaderDelegate {
    func touchedHeader() {
        DispatchQueue.main.async {
            self.sortTableView(by: self.songListTableViewHeader.currentSortElement)
            self.songListTableView.reloadData()
        }
    }
}


