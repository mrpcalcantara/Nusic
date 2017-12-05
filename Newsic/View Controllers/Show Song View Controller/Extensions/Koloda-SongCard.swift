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

/*
extension SongPickerViewController: KolodaViewDelegate {
    
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        let position = songCardView.currentCardIndex
        for i in 1...4 {
            dataSource.append(UIImage(named: "Test")!)
        }
        songCardView.insertCardAtIndexRange(position..<position + 4, animated: true)
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        UIApplication.shared.open(URL(string: "https://yalantis.com/")!, options: [:]) { (bool) in
            
        }
    }
    
}


extension SongPickerViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return dataSource.count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .default
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        return UIImageView(image: dataSource[Int(index)])
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("SongOverlayView", owner: self, options: nil)?[0] as? OverlayView
    }
    
}
 */

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
        let newsicTrack = NewsicTrack(trackInfo: likedTrackList[index], moodInfo: moodObject, userName: auth.session.canonicalUsername!);
        cardList.insert(newsicTrack, at: position);
        songCardView.insertCardAtIndexRange(position..<position+1, animated: true);
    }
    
    func kolodaShouldMoveBackgroundCard(_ koloda: Koloda.KolodaView) -> Bool {
        return false;
    }
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
//        print("Swiped \(direction)")
        DispatchQueue.main.async {
            self.hideLikeButtons()
        }
        didUserSwipe = true;
        pausePlay.setImage(UIImage(named: "PlayTrack"), for: .normal)
        if direction == .right {
            likeTrack(in: index);
        }
        didUserSwipe = false;
        fetchNewCard { (isFetched) in
            print("COUNT OF CARDS = \(self.songCardView.countOfVisibleCards)")
            
            if self.songCardView.countOfVisibleCards < 3 || !isFetched {
//                self.fetchNewCard(cardFetchingHandler: nil);
                self.fetchNewCard(cardFetchingHandler: { (isFetched) in
                    
                })
                
            }
        }
    }
    
    func koloda(_ koloda: KolodaView, didShowCardAt index: Int) {
        //isPlaying = false
        presentedCardIndex = index
        if isPlayerMenuOpen {
            let cardView = koloda.viewForCard(at: index) as! SongOverlayView
            cardView.genreLabel.alpha = 0
            cardView.songArtist.alpha = 0
        }
        isSongLiked = containsTrack(trackId: cardList[index].trackInfo.trackId);
        toggleLikeButtons();
        actionPlaySpotifyTrack(spotifyTrackId: cardList[index].trackInfo.trackUri);
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
        view.layer.borderWidth = 0.5;
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 15
        view.clipsToBounds = true;
        //view.translatesAutoresizingMaskIntoConstraints = true;
        
        
        //view.spotifyIcon.image = UIImage(named: "SpotifyHighlighted")
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
        DispatchQueue.main.async {
            SwiftSpinner.show(duration: 2, title: "Liked!");
            //SwiftSpinner.show(delay: 1.9, title: "Updating playlist..", animated: true);
        }
        let track = cardList[likedCardIndex];
        isSongLiked = didUserSwipe == true ? false : true ; toggleLikeButtons()
        spotifyHandler.addTracksToPlaylist(playlistId: playlist.id!, trackId: track.trackInfo.trackUri, addTrackHandler: { (isAdded, error) in
//            print("ADDED TRACK");
            if let error = error {
//                self.present(error.popupDialog!, animated: true, completion: nil)
                error.presentPopup(for: self)
            }
        })
        spotifyHandler.getTrackDetails(trackId: track.trackInfo.trackId!, fetchedTrackDetailsHandler: { (trackFeatures, error) in
            if let error = error {
//                self.present(error.popupDialog!, animated: true, completion: nil)
                error.presentPopup(for: self)
            } else {
                if let trackFeatures = trackFeatures {
                    self.updateCurrentGenresAndFeatures { (genres, trackFeatures) in
                        self.trackFeatures = trackFeatures;
                    }
                    
                    track.trackInfo.audioFeatures = trackFeatures;
                    track.saveData(saveCompleteHandler: { (reference, error) in
                        self.likedTrackList.insert(track.trackInfo, at: 0);
                        DispatchQueue.main.async {
                            self.songListTableView.reloadData();
                            
                            //SwiftSpinner.show(duration: 2, title: "Done!", animated: true)
                        }
                        
                    });
                }
            }
            
        })
    }
}

