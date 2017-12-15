//
//  Koloda-SongCard.swift
//  Newsic
//
//  Created by Miguel Alcantara on 29/08/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit
import Koloda
import SwiftSpinner

extension ShowSongViewController: KolodaViewDelegate {
    
    override func viewWillLayoutSubviews() {
        if isPlayerMenuOpen {
            
        }
    }
    
    func setupCards() {
        songCardView.delegate = self;
        songCardView.dataSource = self;
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(likeTrack(in:)));
        doubleTapRecognizer.numberOfTapsRequired = 2
        songCardView.addGestureRecognizer(doubleTapRecognizer);
        
      
    }
    
    func addSongToPosition(at index: Int, position: Int) {
        let newsicTrack = likedTrackList[index]
        cardList.insert(newsicTrack, at: position);
        
        songCardView.insertCardAtIndexRange(position..<position+1, animated: false);
        songCardView.delegate?.koloda(songCardView, didShowCardAt: position)
    }
    
    func kolodaShouldMoveBackgroundCard(_ koloda: Koloda.KolodaView) -> Bool {
        return false;
    }
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        self.hideLikeButtons()
        didUserSwipe = true;
        pausePlay.setImage(UIImage(named: "PlayTrack"), for: .normal)
        if direction == .right {
            likeTrack(in: index);
        }
        didUserSwipe = false;
        
        fetchNewCard { (isFetched) in
            if self.songCardView.countOfVisibleCards < 3 || !isFetched {
                self.fetchNewCard(cardFetchingHandler: nil)
            }
        }
    }
    
    func koloda(_ koloda: KolodaView, didShowCardAt index: Int) {
        //isPlaying = false
        print("showing card at: \(index)")
        self.songListTableView.reloadData()
        presentedCardIndex = index
        let cardView = koloda.viewForCard(at: index) as! SongOverlayView
        if isPlayerMenuOpen {
//            let cardView = koloda.viewForCard(at: index) as! SongOverlayView
            cardView.genreLabel.alpha = 0
            cardView.songArtist.alpha = 0
        }
        isSongLiked = containsTrack(trackId: cardList[index].trackInfo.trackId);
        toggleLikeButtons();
        
        
        if preferredPlayer == NewsicPreferredPlayer.spotify {
            print("attempting to start track = \(cardList[index].trackInfo.trackUri)")
            actionPlaySpotifyTrack(spotifyTrackId: cardList[index].trackInfo.trackUri);
        } else {
            setupYTPlayer(for: cardView, with: (cardList[index].youtubeInfo?.trackId)!)
            ytPlayTrack()
        }
        
    }
    
    func kolodaShouldApplyAppearAnimation(_ koloda: KolodaView) -> Bool {
        return true;
    }
    
    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool {
        return false
    }
}


extension ShowSongViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        //print("card list count = \(cardList.count)")
        return cardList.count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .fast
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        return configure(index: index)
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        //print("viewForCardOverlayAt index \(index)")
        return Bundle.main.loadNibNamed("OverlayView", owner: self, options: nil)?[0] as? SongOverlayView
    }
    
    func configure(index: Int) -> UIView {
        let view = UINib(nibName: "OverlayView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SongOverlayView
        
        //print("index = \(index) -> artist = \(self.cardList[index].trackInfo.artist!) and songName = \(self.cardList[index].trackInfo.songName!)");
        
        view.songArtist.text = self.cardList[index].trackInfo.artist.artistName
        view.songTitle.text = self.cardList[index].trackInfo.songName;
        view.genreLabel.text = self.cardList[index].trackInfo.artist.listGenres()
        view.albumImage.downloadedFrom(link: self.cardList[index].trackInfo.thumbNailUrl);
        if preferredPlayer == NewsicPreferredPlayer.spotify {
            view.albumImage.downloadedFrom(link: self.cardList[index].trackInfo.thumbNailUrl);
//            view.youtubePlayer.backgroundColor = UIColor.clear
            view.youtubePlayer.isHidden = true
        } else {
//            view.albumImage.alpha = 0
            if let youtubeTrackId = self.cardList[index].youtubeInfo?.trackId {
//                setupYTPlayer(for: view, with: youtubeTrackId)
            }
            
        }
        
//        view.albumImage.alpha = 0
//        if let youtubeTrackId = self.cardList[index].youtubeInfo?.trackId {
//            let playerVars: [String : Any] = [
//                "playsinline" : 1,
//                "showinfo" : 0,
//                "rel" : 0,
//                "modestbranding" : 1,
//                "controls" : 1,
//                "origin" : "https://www.example.com"
//                ] as [String : Any]
//            view.youtubePlayer.load(withVideoId: youtubeTrackId, playerVars: playerVars)
//        }
        
        view.layer.borderWidth = 0.5;
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 15
        view.clipsToBounds = true;
        
        if index == 0 {
            //view.addShadow(shadowOffset: CGSize(width: 1, height: 3));
        }
        
        return view;
    }
    
}

extension ShowSongViewController {
    
    @objc func likeTrack(in index: Int) {
        guard cardList.count > 0, containsTrack(trackId: cardList[presentedCardIndex].trackInfo.trackId) == false else { return; }
        let likedCardIndex = presentedCardIndex
        SwiftSpinner.show("Adding track to playlist..").addTapHandler({
            SwiftSpinner.hide()
        }, subtitle: "Tap on the screen to go back to the cards. We'll add the song on the background!")
        
        let track = cardList[likedCardIndex];
        isSongLiked = didUserSwipe == true ? false : true ; toggleLikeButtons()
        spotifyHandler.isTrackInPlaylist(trackId: track.trackInfo.trackId, playlistId: playlist.id!) { (isInPlaylist) in
            if !isInPlaylist {
                self.spotifyHandler.addTracksToPlaylist(playlistId: self.playlist.id!, trackId: track.trackInfo.trackUri, addTrackHandler: { (isAdded, error) in
                    
                    if let error = error {
                        SwiftSpinner.hide()
                        error.presentPopup(for: self, description: SpotifyErrorCodeDescription.addTrack.rawValue)
                    } else {
                        if let genres = track.trackInfo.artist.subGenres {
                            for genre in genres {
                                self.user.updateGenreCount(for: genre, updateGenreHandler: { (isUpdated, error) in
                                    if let error = error {
                                        SwiftSpinner.hide()
                                        error.presentPopup(for: self)
                                    } else {
                                        SwiftSpinner.show(duration: 2, title: "Liked!");
                                    }
                                    
                                })
                            }
                            
                        }
                        
                    }
                    
                })
            }
        }
        
        spotifyHandler.getTrackDetails(trackId: track.trackInfo.trackId!, fetchedTrackDetailsHandler: { (trackFeatures, error) in
            if let error = error {
                SwiftSpinner.hide()
                error.presentPopup(for: self, description: SpotifyErrorCodeDescription.getTrackInfo.rawValue)
            } else {
                if var trackFeatures = trackFeatures {
                    trackFeatures.youtubeId = track.youtubeInfo?.trackId;
                    self.updateCurrentGenresAndFeatures { (genres, trackFeatures) in
                        self.trackFeatures = trackFeatures;
                    }
                    
                    track.trackInfo.audioFeatures = trackFeatures;
                    track.saveData(saveCompleteHandler: { (reference, error) in
                        if let error = error {
                            SwiftSpinner.hide()
                            error.presentPopup(for: self)
                        }
                        self.likedTrackList.insert(track, at: 0);
                        DispatchQueue.main.async {
                            self.songListTableView.reloadData();
                        }
                        
                    });
                }
            }
            
        })
    }
    
    func getCurrentCardView() -> SongOverlayView {
        return songCardView.viewForCard(at: songCardView.currentCardIndex) as! SongOverlayView
    }
}

