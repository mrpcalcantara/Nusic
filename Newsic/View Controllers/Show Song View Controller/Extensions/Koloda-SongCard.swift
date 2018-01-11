//
//  Koloda-SongCard.swift
//  Nusic
//
//  Created by Miguel Alcantara on 29/08/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit
import Koloda
import SwiftSpinner

//class CardOperation: Operation {
//    
//    let songCardView: SongKolodaView
//    init(songCardView: SongKolodaView) {
//        self.songCardView = songCardView
//    }
//    
//    override func main() {
//        DispatchQueue.main.async {
//            self.songCardView.reloadData();
//        }
//    }
//}
//
//class CardOperationQueue: OperationQueue {
//    
//    lazy var reloadsInProgress = [String:Operation]()
//    lazy var reloadQueue:OperationQueue = {
//        var queue = OperationQueue()
//        queue.name = "Card reload queue"
//        queue.maxConcurrentOperationCount = 1
//        return queue
//    }()
//
//}

extension ShowSongViewController: KolodaViewDelegate {
    
    func setupCards() {
        songCardView.delegate = self;
        songCardView.dataSource = self;
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(likeTrack(in:)));
        doubleTapRecognizer.numberOfTapsRequired = 2
        songCardView.addGestureRecognizer(doubleTapRecognizer);
        
        
    }
    
    func addSongToPosition(at index: Int, position: Int) {
        let nusicTrack = likedTrackList[index]
        cardList.insert(nusicTrack, at: position);
        
        songCardView.insertCardAtIndexRange(position..<position+1, animated: false);
        songCardView.delegate?.koloda(songCardView, didShowCardAt: position)
    }
    
    func kolodaShouldMoveBackgroundCard(_ koloda: Koloda.KolodaView) -> Bool {
        return false;
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        let alertController = NusicAlertController(title: "More tracks based on:", message: nil, style: YBAlertControllerStyle.ActionSheet)
        
        let actionArtist: () -> Void = {
            self.musicSearchType = .artist
            self.showSwiftSpinner(text: "Fetching tracks..")
            self.showSwiftSpinner(delay: 20, text: "Unable to fetch!", duration: nil)
            self.showMore.transform = CGAffineTransform.identity;
            self.handleFetchNewTracks(numberOfSongs: 9, completionHandler: nil)
            
        }
        
        let actionTrack: () -> Void = {
            self.musicSearchType = .track
            self.showSwiftSpinner(text: "Fetching tracks..")
            self.showSwiftSpinner(delay: 20, text: "Unable to fetch!", duration: nil)
            self.handleFetchNewTracks(numberOfSongs: 9, completionHandler: nil)
        }
        
        let actionGenre: () -> Void = {
            let dict = self.currentPlayingTrack?.artist.listDictionary()
            let count: Int? = dict?.count
            if let count = count, count > 0 {
                self.selectedGenreList = dict!
            }
            
            self.showSwiftSpinner(text: "Fetching tracks..")
            self.showSwiftSpinner(delay: 20, text: "Unable to fetch!", duration: nil)
            self.musicSearchType = .genre
            self.handleFetchNewTracks(numberOfSongs: 9, completionHandler: nil)
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
//        player?.playbackDelegate.audioStreaming!(player, didStopPlayingTrack: currentPlayingTrack?.trackUri)
        getNextSong()

    }
    
    func koloda(_ koloda: KolodaView, didShowCardAt index: Int) {
//        print("showing card at: \(index)")
        DispatchQueue.main.async {
            self.songListTableView.reloadData()
        }
        presentedCardIndex = index
        let cardView = koloda.viewForCard(at: index) as! SongOverlayView
        if isPlayerMenuOpen {
            cardView.genreLabel.alpha = 0
            cardView.songArtist.alpha = 0
        }
        isSongLiked = containsTrack(trackId: cardList[index].trackInfo.trackId);
        toggleLikeButtons();
        
        if currentPlayingTrack?.trackId != cardList[index].trackInfo.trackId {
            if preferredPlayer == NusicPreferredPlayer.spotify {
                playCard(at: index)
            } else {
                if let youtubeTrackId = cardList[index].youtubeInfo?.trackId {
                    setupYTPlayer(for: cardView, with: youtubeTrackId)
                    ytPlayTrack()
                }
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
        //WORKAROUND: Because of concurrent reloading, we need to validate the indexes are valid.
        if index < cardList.count {
            return configure(index: index)
        }
        return UIView()
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
        if preferredPlayer == NusicPreferredPlayer.spotify {
            view.setupViewForSpotify()
        } else {
            view.setupViewForYoutube()
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
    
    func handleFetchNewTracks(numberOfSongs: Int, completionHandler: ((Bool) -> ())?) {
        fetchNewCardsFromSpotify(numberOfSongs: numberOfSongs) { (tracks) in
            DispatchQueue.main.async {
                self.cardList.removeSubrange(self.songCardView.currentCardIndex+1..<self.cardList.count)
                self.addSongsToCardList(for: nil, tracks: tracks)
                self.songCardView.reloadCardsInIndexRange(self.songCardView.currentCardIndex+1..<self.cardList.count)
                SwiftSpinner.hide()
                completionHandler?(true)
            }
        }
    }
    
}



