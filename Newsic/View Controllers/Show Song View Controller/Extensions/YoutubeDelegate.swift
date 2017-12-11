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
//        var card = self.songCardView.viewForCard(at: self.songCardView.currentCardIndex) as! SongOverlayView
        view.youtubePlayer.delegate = self;
        loadVideo(for: view, with: videoId)
    }
    
    func loadVideo(for view: SongOverlayView, with videoId: String) {
//        var card = self.songCardView.viewForCard(at: self.songCardView.currentCardIndex) as! SongOverlayView
        let playerVars: [String : Any] = [
            "playsinline" : 1,
            "showinfo" : 0,
            "rel" : 0,
            "modestbranding" : 1,
            "controls" : 1,
            "origin" : "https://www.youtube.com"
            ]
        view.youtubePlayer.load(withVideoId: videoId, playerVars: playerVars)
    }
    
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
//        playerView.playVideo();
    }
}
