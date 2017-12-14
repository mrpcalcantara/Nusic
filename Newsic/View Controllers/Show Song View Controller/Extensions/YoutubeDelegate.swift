//
//  YoutubeDelegate.swift
//  Newsic
//
//  Created by Miguel Alcantara on 31/08/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import youtube_ios_player_helper

extension ShowSongViewController: YTPlayerViewDelegate {
    
    func setupYTPlayer(for view: SongOverlayView, with videoId: String) {
        view.youtubePlayer.delegate = self;
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
//        playerView.playVideo();
        //WORKAROUND: For playing the first card.
//        if songCardView.currentCardIndex == 0 {
//            playerView.playVideo();
//        }
        
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
//        ytPausePlay()
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
