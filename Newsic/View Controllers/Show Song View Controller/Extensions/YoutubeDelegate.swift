//
//  YoutubeDelegate.swift
//  Newsic
//
//  Created by Miguel Alcantara on 31/08/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import youtube_ios_player_helper
import PopupDialog

extension ShowSongViewController: YTPlayerViewDelegate {
    
    func setupYTPlayer(for view: SongOverlayView, with videoId: String) {
        view.youtubePlayer.delegate = self;
        UIView.animate(withDuration: 0.3) {
            view.albumImage.alpha = 0
        }
        loadVideo(for: view, with: videoId)
    }
    
    func loadVideo(for view: SongOverlayView, with videoId: String) {
        let playerVars: [String : Any] = [
            "playsinline" : 1,
            "showinfo" : 0,
            "rel" : 0,
            "modestbranding" : 0,
            "controls" : 1,
            "origin" : "https://www.youtube.com"
            ]
        view.youtubePlayer.load(withVideoId: videoId, playerVars: playerVars)
    }
    
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        if Connectivity.isConnectedToNetwork() == .connectedCellular && !playOnCellularData! {
            let dialog = PopupDialog(title: "Warning!", message: "We detected that you are using cellular data and you have disabled this. Do you wish to continue listening to music on cellular data?", transitionStyle: .zoomIn, gestureDismissal: false, completion: nil)
            
            dialog.addButton(DefaultButton(title: "Yes, keep playing!", action: {
                self.playOnCellularData = true
                self.playerViewDidBecomeReady(playerView)
            }))
            dialog.addButton(CancelButton(title: "No", action: {
                let parent = self.parent as! NewsicPageViewController
                parent.scrollToPreviousViewController();
                parent.removeViewControllerFromPageVC(viewController: self)
                playerView.stopVideo()
            }))
            
            self.present(dialog, animated: true, completion: nil)
        } else {
        
        }
        playerView.playVideo();
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        if state == .playing {
            self.isPlaying = true
            self.togglePausePlayIcon()
        } else if state == .paused {
            self.isPlaying = false
            self.togglePausePlayIcon()
        } else if state == .ended {
            songCardView.swipe(.left)
        } 
    }
    
    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
        
    }
    
    func ytSeekTo(seconds: Float) {
        let card = getCurrentCardView()
        card.youtubePlayer.seek(toSeconds: seconds, allowSeekAhead: true);
    }
    
    func ytPauseTrack() {
        let card = getCurrentCardView()
        card.youtubePlayer.pauseVideo()
    }
    
    func ytPlayTrack() {
        let card = getCurrentCardView()
        card.youtubePlayer.playVideo()
    }
    
    func ytPausePlay() {
        self.isPlaying = !self.isPlaying
        
        if isPlaying {
            ytPlayTrack()
        } else {
            ytPauseTrack()
        }
        self.togglePausePlayIcon()
    }
    
}
