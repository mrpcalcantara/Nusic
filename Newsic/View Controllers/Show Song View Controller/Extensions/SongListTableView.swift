//
//  SongListTableView.swift
//  Nusic
//
//  Created by Miguel Alcantara on 15/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

extension ShowSongViewController {
    
    func setupTableView() {
        songListTableView.delegate = self;
        songListTableView.dataSource = self;
        
        let view = UINib(nibName: SongTableViewCell.className, bundle: nil);
        songListTableView.register(view, forCellReuseIdentifier: SongTableViewCell.reuseIdentifier);
        
        let headerView = UINib(nibName: SongTableViewSectionHeader.className, bundle: nil);
        songListTableView.register(headerView, forHeaderFooterViewReuseIdentifier: SongTableViewSectionHeader.reuseIdentifier)
        
        songListTableViewHeader.setupView()
        songListTableViewHeader.delegate = self
//        songListTableViewHeader.displayName.text = "TEST"
        setupView();
    }
    
    fileprivate func setupView() {
        closeMenu()
        
        songListTableView.isHidden = false
        songListTableView.rowHeight = UITableViewAutomaticDimension
        songListTableView.estimatedRowHeight = 90.0
        songListTableView.tableFooterView = UIView();
        let image = UIImage(named: "SongMenuBackgroundPattern")
        if let image = image {
            songListTableView.backgroundColor = UIColor(patternImage: image);
        }
        
        pausePlay.contentMode = .center
        pausePlay.setImage(UIImage(named: "PlayTrack"), for: .normal)
        previousSong.contentMode = .center
        previousSong.setImage(UIImage(named: "ThumbsDown"), for: .normal)
        nextSong.contentMode = .center
        nextSong.setImage(UIImage(named: "ThumbsUp"), for: .normal)
        
        initialSongListCenter = songListTableView.center;
        
        let emotion = moodObject?.emotions.first?.basicGroup.rawValue
        songListTableViewHeader.configure(isMoodSelected: isMoodSelected, emotion: emotion)
        
        if UIApplication.shared.statusBarOrientation.isLandscape {
            removeHeaderGestureRecognizer(for: songListTableViewHeader)
            removeMenuSwipeGestureRecognizer()
        } else {
            addHeaderGestureRecognizer(for: songListTableViewHeader)
            addMenuSwipeGestureRecognizer()
        }
    }
    
    func containsTrack(trackId: String) -> Bool {
        for track in likedTrackList {
            if track.trackInfo.trackId == trackId {
                return true;
            }
        }
        return false;
    }
    
    func openMenu() {
        isMenuOpen = true
        self.songListTableView.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: .curveLinear, animations: {
            self.trackStackView.layer.zPosition = -1
            self.songListTableView.isUserInteractionEnabled = true
            self.songCardView.isUserInteractionEnabled = false
            self.previousSong.isUserInteractionEnabled = false
            self.pausePlay.isUserInteractionEnabled = false
            self.nextSong.isUserInteractionEnabled = false
            self.previousTrack.isUserInteractionEnabled = false
            self.nextTrack.isUserInteractionEnabled = false
            self.showMore.isUserInteractionEnabled = false
            self.songProgressSlider.isUserInteractionEnabled = false
            self.tableViewLeadingConstraint.constant = self.view.frame.width/6;
            self.tableViewTrailingConstraint.constant = 0
            self.trackStackView.alpha = 0.1
            
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func closeMenu() {

        isMenuOpen = false
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: .curveLinear, animations: {
            self.trackStackView.layer.zPosition = 1
            self.songListTableView.isUserInteractionEnabled = false
            self.songCardView.isUserInteractionEnabled = true
            self.previousSong.isUserInteractionEnabled = true
            self.pausePlay.isUserInteractionEnabled = true
            self.nextSong.isUserInteractionEnabled = true
            self.previousTrack.isUserInteractionEnabled = true
            self.nextTrack.isUserInteractionEnabled = true
            self.showMore.isUserInteractionEnabled = true
            self.songProgressSlider.isUserInteractionEnabled = true
            self.tableViewLeadingConstraint.constant = self.view.frame.width
            self.tableViewTrailingConstraint.constant -= (5*self.view.frame.width)/6
            self.trackStackView.alpha = 1
            //self.trackStackView.removeBlurEffect()
            //            print(self.songListTableView.center)
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    func addHeaderGestureRecognizer(for headerCell: UIView) {
        if let gestureRecognizers = headerCell.gestureRecognizers {
            if !gestureRecognizers.contains(where: { (gestureRecognizer) -> Bool in
                return gestureRecognizer.name == "panHeader"
            }) {
                let screenEdgeRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleMenuScreenGesture(_:)))
                screenEdgeRecognizer.cancelsTouchesInView = false
                screenEdgeRecognizer.delegate = self
                screenEdgeRecognizer.name = "panHeader"
                headerCell.addGestureRecognizer(screenEdgeRecognizer);
            }
        } else {
            let screenEdgeRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleMenuScreenGesture(_:)))
            screenEdgeRecognizer.cancelsTouchesInView = false
            screenEdgeRecognizer.delegate = self
            screenEdgeRecognizer.name = "panHeader"
            headerCell.addGestureRecognizer(screenEdgeRecognizer);
        }
    }
    
    func removeHeaderGestureRecognizer(for headerCell: UIView) {
        if let index = headerCell.gestureRecognizers?.index(where: { (gestureRecognizer) -> Bool in
            return gestureRecognizer.name == "panHeader"
        }) {
            headerCell.gestureRecognizers?.remove(at: index)
        }
    }
    
    func disableHeaderGestureRecognizer(for headerCell: UIView) {
        if let index = headerCell.gestureRecognizers?.index(where: { (gestureRecognizer) -> Bool in
            return gestureRecognizer.name == "panHeader"
        }) {
            let gestureRecognizer = headerCell.gestureRecognizers![index]
            gestureRecognizer.isEnabled = false
        }
    }
    
    func enableHeaderGestureRecognizer(for headerCell: UIView) {
        if let index = headerCell.gestureRecognizers?.index(where: { (gestureRecognizer) -> Bool in
            return gestureRecognizer.name == "panHeader"
        }) {
            let gestureRecognizer = headerCell.gestureRecognizers![index]
            gestureRecognizer.isEnabled = true
        }
    }
    
    func addMenuSwipeGestureRecognizer() {
        menuEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleMenuScreenGesture(_:)))
        menuEdgePanGestureRecognizer.edges = .right
        self.view.addGestureRecognizer(menuEdgePanGestureRecognizer);
    }
    
    func removeMenuSwipeGestureRecognizer() {
        if let index = self.view.gestureRecognizers?.index(where: { (gestureRecognizer) -> Bool in
            return gestureRecognizer == menuEdgePanGestureRecognizer
        }) {
            self.view.gestureRecognizers?.remove(at: index)
        }
    }
    
}

extension ShowSongViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90;
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50;
    }
 
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SongTableViewHeader") as! SongTableViewHeader
//        configure(headerCell: headerCell, at: section);
//        return headerCell;
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let frontPosition = songCardView.currentCardIndex;
        
        isSongLiked = true; toggleLikeButtons();
        addSongToPosition(at: indexPath, position: frontPosition);
        if UIApplication.shared.statusBarOrientation.isPortrait {
            closeMenu();
        }
        
        if preferredPlayer == NusicPreferredPlayer.spotify {
            actionPlaySpotifyTrack(spotifyTrackId: cardList[frontPosition].trackInfo.trackUri);
        }
        
        tableView.deselectRow(at: indexPath, animated: true);
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "\u{267A}") { (action, indexPath) in
            // delete item at indexPath
            self.removeTrackFromLikedTracks(indexPath: indexPath, removeTrackHandler: { (didRemove) in
                self.isSongLiked = false;
                self.toggleLikeButtons();
                DispatchQueue.main.async {
                    var indexSet = IndexSet()
                    indexSet.insert(indexPath.section)
                    tableView.performBatchUpdates({
                        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                        tableView.reloadSections(indexSet, with: UITableViewRowAnimation.fade)
                    }, completion: nil)
                }
            })
            
            
        }
        
        return [delete]
    }

}

extension ShowSongViewController: UITableViewDataSource {
    
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    fileprivate func configure(headerCell: SongTableViewHeader) {
        
        
        
        
    }
    
//    func configure(cell: SongTableViewCell, at indexPath: IndexPath) {
//
//        let element = sectionSongs[indexPath.section][indexPath.row]
//
//
//    }
    
//    func configure(sectionHeaderCell: SongTableViewSectionHeader, at section: Int) {
//
//        sectionHeaderCell.displayName.text = sectionTitles[section]
//
//        if UIApplication.shared.statusBarOrientation.isLandscape {
//            removeHeaderGestureRecognizer(for: sectionHeaderCell)
//            removeMenuSwipeGestureRecognizer()
//        } else {
//            addHeaderGestureRecognizer(for: sectionHeaderCell)
//            addMenuSwipeGestureRecognizer()
//        }
//
//    }
    
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

extension ShowSongViewController : SongTableViewHeaderDelegate {
    func touchedHeader() {
        sortTableView(by: songListTableViewHeader.currentSortElement)
        DispatchQueue.main.async {
            self.songListTableView.reloadData()
        }
    }
}


