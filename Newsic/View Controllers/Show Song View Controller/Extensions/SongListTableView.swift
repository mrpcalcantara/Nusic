//
//  SongListTableView.swift
//  Newsic
//
//  Created by Miguel Alcantara on 15/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

extension ShowSongViewController {
    
    func setupTableView() {
        songListTableView.delegate = self;
        songListTableView.dataSource = self;
        setupView();
    }
    
    func updateTableView() {
        DispatchQueue.main.async {
            self.songListTableView.reloadData()
        }
    }
    
    func setupView() {
        /*
        songListTableView.layer.borderColor = UIColor.gray.cgColor
        songListTableView.layer.borderWidth = 3;
        songListTableView.layer.shadowColor = UIColor.black.cgColor
        songListTableView.layer.shadowOffset = CGSize(width: -5, height: -5);
        songListTableView.layer.shadowOpacity = 2;
        songListTableView.layer.shadowRadius = 3
        songListTableView.layer.cornerRadius = 10
        */
        
        //setBackButton(image: UIImage(named: "MoodIcon")!)
        //songCardView.addShadow();
        closeMenu()
        
        //songListTableView.addShadow(shadowOffset: CGSize(width: -7, height: 1));
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
        
        
        //songListTableView.translatesAutoresizingMaskIntoConstraints = true;
        
        let screenEdgeRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleMenuScreenGesture(_:)))
        screenEdgeRecognizer.edges = .right
        self.view.addGestureRecognizer(screenEdgeRecognizer);
        
        /*
        let songListPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleMenuScreenGesture(_:)))
        songListPanRecognizer.delegate = self
        songListTableView.addGestureRecognizer(songListPanRecognizer);
        //songListTableView.addGestureRecognizer(screenEdgeRecognizer);
        */
        //self.view.sendSubview(toBack: songListTableView);
        //songListTableView.layer.zPosition = -1
        initialSongListCenter = songListTableView.center;
    }
    
    func containsTrack(trackId: String) -> Bool {
        for track in likedTrackList {
            if track.trackId == trackId {
                return true;
            }
        }
        return false;
    }
    
    
}

extension ShowSongViewController: UITableViewDelegate {

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90;
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100;
    }
 
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UINib(nibName: "SongTableViewHeader", bundle: nil);
        
        tableView.register(view, forHeaderFooterViewReuseIdentifier: "SongTableViewHeader")
        let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SongTableViewHeader") as! SongTableViewHeader
        
        print("headerCell frame = \(headerCell.frame)");
        if isMoodSelected {
            let emotion = moodObject?.emotions.first?.basicGroup.rawValue
            headerCell.displayName.text = "Mood: \(emotion!)"
        } else {
            headerCell.displayName.text = "Liked in Newsic"
        }
        
        /*
        if let profileImage = user.profileImage {
            headerCell.profileImage.image = profileImage
        } else {
            headerCell.profileImage.image = UIImage();
            headerCell.profileImage.backgroundColor = UIColor.black;
        }
        */
        //headerCell.profileImage.roundImage();
        
        headerCell.layer.shadowColor = UIColor.black.cgColor;
        headerCell.layer.shadowOffset = CGSize(width: 1, height: -1);
        headerCell.layer.shadowRadius = 3.0;
        headerCell.layer.shadowOpacity = 1;
        
        let gradient = CAGradientLayer()
        gradient.frame.size = CGSize(width: headerCell.bounds.width, height: 10)
        let stopColor = UIColor.white.cgColor
        let startColor = UIColor.white.cgColor
        
        gradient.colors = [stopColor,startColor]
        gradient.locations = [0.0,0.4]
        headerCell.layer.addSublayer(gradient)
        
        return headerCell;
        /*
        guard let regCell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as? SongTableViewCell else {
            fatalError("Unexpected Index Path")
        }
        */
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let track = cardList[index]
        let frontPosition = songCardView.currentCardIndex;
        
        isSongLiked = true; toggleLikeButtons();
        addSongToPosition(at: indexPath.row, position: frontPosition);
        closeMenu();
        print("trackInfo = \(cardList[frontPosition].trackInfo.artist)");
        actionPlaySpotifyTrack(spotifyTrackId: cardList[frontPosition].trackInfo.trackUri);
        tableView.deselectRow(at: indexPath, animated: true);
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "\u{267A}") { (action, indexPath) in
            // delete item at indexPath
            self.removeTrackFromList(indexPath: indexPath, removeTrackHandler: { (didRemove) in
                self.isSongLiked = false; self.toggleLikeButtons();
                self.updateTableView();
            })
            
            
        }
        
        return [delete]
    }
}

extension ShowSongViewController: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return likedTrackList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let view = UINib(nibName: "SongTableViewCell", bundle: nil);
        
        tableView.register(view, forCellReuseIdentifier: "songCell");
        guard let regCell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as? SongTableViewCell else {
            fatalError("Unexpected Index Path")
        }
        
        configure(cell: regCell, at: indexPath)
        return regCell;
    }
    
    func configure(cell: SongTableViewCell, at indexPath: IndexPath) {
        
        let element = likedTrackList[indexPath.row];
        //cell.albumImage.bounds = CGRect(x: 0, y: 0, width: cell.bounds.height, height: cell.bounds.height);
        cell.albumImage.contentMode = .scaleAspectFit
        cell.albumImage.image = element.thumbNail;
        cell.artistLabel.text = element.artist.artistName;
        cell.trackLabel.text = element.songName;
        //cell.addShadow(shadowOffset: CGSize(width: -5, height: 0))
        cell.setNeedsLayout();
    }
    
}



