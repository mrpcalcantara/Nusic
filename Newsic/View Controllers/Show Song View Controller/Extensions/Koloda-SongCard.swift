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
        let alertController = NewsicAlertController(title: "More tracks based on:", message: nil, style: YBAlertControllerStyle.ActionSheet)
        
        let actionArtist: () -> Void = {
            DispatchQueue.main.async {
                self.showSwiftSpinner(text: "Fetching tracks..", duration: nil)
            }
            print("getting new songs for artist")
            self.musicSearchType = .artist
            self.handleFetchNewCard(numberOfSongs: 9)
        }
        
        let actionTrack: () -> Void = {
            DispatchQueue.main.async {
                self.showSwiftSpinner(text: "Fetching tracks..", duration: nil)
            }
            self.musicSearchType = .track
            self.handleFetchNewCard(numberOfSongs: 9)
        }
        
        let actionGenre: () -> Void = {
            DispatchQueue.main.async {
                self.showSwiftSpinner(text: "Fetching tracks..", duration: nil)
            }
            let dict = self.currentPlayingTrack?.artist.listDictionary()
            let count: Int? = dict?.count
            if let count = count, count > 0 {
                self.selectedGenreList = dict!
            }
            
            self.musicSearchType = .genre
            self.handleFetchNewCard(numberOfSongs: 9)
        }
        
        alertController.addButton(icon: UIImage(named: "GenreIcon"), title: "Current Genre", action: actionGenre)
        alertController.addButton(icon: UIImage(named: "ArtistIcon"), title: "Current Artist", action: actionArtist)
        alertController.addButton(icon: UIImage(named: "TrackIcon"), title: "Current Track", action: actionTrack)
        
        alertController.show()
        
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        self.hideLikeButtons()
        didUserSwipe = true;
        pausePlay.setImage(UIImage(named: "PlayTrack"), for: .normal)
        if direction == .right {
            likeTrack(in: index);
        }
        didUserSwipe = false;
        
        let handler: (Bool) -> Void = { didHandle in
            if self.songCardView.countOfVisibleCards < 3 || !didHandle {
//                fetchNewCard(cardFetchingHandler: handler)
                self.fetchNewCard(cardFetchingHandler: nil)
            }
            else {
                DispatchQueue.main.async {
                    self.songCardView.reloadData()
                }
            }
        }
        
        fetchNewCard { (isFetched) in
            handler(isFetched);
        }
    }
    
    func koloda(_ koloda: KolodaView, didShowCardAt index: Int) {
        print("showing card at: \(index)")
        self.songListTableView.reloadData()
        presentedCardIndex = index
        let cardView = koloda.viewForCard(at: index) as! SongOverlayView
        if isPlayerMenuOpen {
            cardView.genreLabel.alpha = 0
            cardView.songArtist.alpha = 0
        }
        isSongLiked = containsTrack(trackId: cardList[index].trackInfo.trackId);
        toggleLikeButtons();
        
        
        if preferredPlayer == NewsicPreferredPlayer.spotify {
            print("attempting to start track = \(cardList[index].trackInfo.trackUri)")
            actionPlaySpotifyTrack(spotifyTrackId: cardList[index].trackInfo.trackUri);
        } else {
            if let youtubeTrackId = cardList[index].youtubeInfo?.trackId {
                setupYTPlayer(for: cardView, with: youtubeTrackId)
                ytPlayTrack()
            }
            
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
        
        //TODO: Swiping for Spotify shows YT view regardless, and as such, the album image is hidden.
        if preferredPlayer == NewsicPreferredPlayer.spotify {
            view.setupViewForSpotify()
        }
        
        view.layer.borderWidth = 0.5;
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 15
        view.clipsToBounds = true;
        
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
                        } else {
                            DispatchQueue.main.async {
                                SwiftSpinner.show(duration: 2, title: "Liked!");
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
    
    func handleFetchNewCard(numberOfSongs: Int) {
        self.cardList.removeSubrange(self.songCardView.currentCardIndex+1..<self.cardList.count)
        self.fetchNewCard(numberOfSongs: numberOfSongs, cardFetchingHandler: { (isFetched) in
            DispatchQueue.main.async {
                self.songCardView.reloadCardsInIndexRange(self.songCardView.currentCardIndex+1..<self.cardList.count)
                SwiftSpinner.hide()
            }
        })
        
    }
}

