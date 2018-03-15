//
//  SpotifyDelegates.swift
//  Nusic
//
//  Created by Miguel Alcantara on 31/08/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation
import MediaPlayer
import PopupDialog


extension ShowSongViewController: SPTAudioStreamingDelegate {
    
    final func setupStreamingDelegate() {
        player?.delegate = self;
    }
    
    final func resetStreamingDelegate() {
        player?.delegate = nil
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePosition position: TimeInterval) {
        
        let currentTrack = audioStreaming.metadata.currentTrack;
        if let currentTrack = currentTrack, let currentPlayingTrack = currentPlayingTrack {
            let currentPosition = Float(position)
            songProgressSlider.value = currentPosition
            updateElapsedTime(elapsedTime: currentPosition, duration: Float(currentTrack.duration))
            let thumbNail = currentPlayingTrack.thumbNail != nil ? currentPlayingTrack.thumbNail : nil
            self.updateNowPlayingCenter(title: currentPlayingTrack.songName, artist: currentPlayingTrack.artist.namesToString(), albumArt: thumbNail, currentTime: currentPosition as NSNumber, songLength: currentTrack.duration as NSNumber, playbackRate: 1)
        }
        
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didSeekToPosition position: TimeInterval) {
//        print("seeked")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: String!) {
        self.isPlaying = true
        guard detectConnectivity() else { return; }
        let currentTrack = audioStreaming.metadata.currentTrack;
        
        print("track started");
        
        if let currentTrack = currentTrack {
            let currentNusicTrack = self.cardList[songCardView.currentCardIndex]
            if let isNewSuggestion = currentNusicTrack.suggestionInfo?.isNewSuggestion, isNewSuggestion == true {
                currentNusicTrack.setSuggestedValue(value: false, suggestedHandler: nil)
            }
            
            if currentNusicTrack.trackInfo.audioFeatures == nil {
                currentNusicTrack.trackInfo.audioFeatures = SpotifyTrackFeature()
            }
            currentNusicTrack.trackInfo.audioFeatures?.durationMs = currentTrack.duration
            currentNusicTrack.trackInfo.audioFeatures?.youtubeId = currentNusicTrack.youtubeInfo?.trackId
            self.currentPlayingTrack = currentNusicTrack.trackInfo;
            self.activateAudioSession()
            if let imageURL = currentTrack.albumCoverArtURL {
                let imageURL = URL(string: imageURL)!
                let image = UIImage(); image.downloadImage(from: imageURL) { (image) in
                    self.currentPlayingTrack?.thumbNail = image
                    if let songName = self.currentPlayingTrack?.songName, let artistName = self.currentPlayingTrack?.artist.namesToString() {
                        self.updateNowPlayingCenter(title: songName, artist: artistName, albumArt: image as AnyObject, currentTime: 0, songLength: currentTrack.duration as NSNumber, playbackRate: 1)
                        DispatchQueue.main.async {
                            self.toggleLikeButtons()
                        }
                    }
                }
            } else {
                updateNowPlayingCenter(title: currentTrack.name, artist: currentTrack.artistName, albumArt: nil, currentTime: 0, songLength: currentTrack.duration as NSNumber, playbackRate: 1)
            }
            setupSongProgress(duration: Float(currentTrack.duration))
        } else {
            print("problem starting track");
        }
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: String!) {
        DispatchQueue.main.async {
            self.hideLikeButtons()
        }
        self.isPlaying = false
        songCardView.swipe(.left, force: true)
        if UIApplication.shared.applicationState == .background {
            presentedCardIndex += 1
            playCard(at: presentedCardIndex)
            getNextSong()
        }
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        if isPlaying {
            self.activateAudioSession()
        } else {
            self.deactivateAudioSession()
        }
    }
}

extension ShowSongViewController: SPTAudioStreamingPlaybackDelegate {
    
    final func setupPlaybackDelegate() {
        player?.playbackDelegate = self
    }
    
    final func resetPlaybackDelegate() {
        player?.playbackDelegate = nil
    }

}


extension ShowSongViewController {
    
    final func setupSpotify() {
        auth = SPTAuth.defaultInstance();
        player = SPTAudioStreamingController.sharedInstance();
        
        
        setupStreamingDelegate();
        setupPlaybackDelegate();
        
        if !(self.player?.initialized)! {
            do {
                try self.player?.start(withClientId: self.auth.clientID);
            } catch { print("error starting") }
        }
        if let bitrate = self.user.settingValues.spotifySettings?.bitrate {
            self.player?.setTargetBitrate(bitrate, callback: { (error) in
                
            })
        }
        
        self.player?.login(withAccessToken: self.auth.session.accessToken);
        
    }
    
    final func convertElapsedSecondsToTime(interval: Int) -> String {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        
        let formattedString = formatter.string(from: TimeInterval(interval))!
        return formattedString
    }
    
    final func togglePausePlayIcon() {
        if isPlaying {
            pausePlay.setImage(UIImage(named: "PauseTrack"), for: .normal)
        } else {
            pausePlay.setImage(UIImage(named: "PlayTrack"), for: .normal)
        }
    }
    
    final func spotifyPausePlay() {
        
        
        self.isPlaying = !self.isPlaying;
        
        if self.isPlaying {
            if currentPlayingTrack == nil {
                actionPlaySpotifyTrack(spotifyTrackId: cardList[songCardView.currentCardIndex].trackInfo.trackUri)
            }
        }
        player?.setIsPlaying(isPlaying, callback: { (error) in
            self.togglePausePlayIcon()
            if error != nil {
                print("ERROR PAUSING TRACK");
            }
        })
        
        
    }
    
    // MARK: Activate audio session
    final func activateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("activateAudioSession() - error starting")
        }
        
        
    }
    
    // MARK: Deactivate audio session
    final func deactivateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("deactivateAudioSession() - error stopping")
        }
        
    }

    @objc final func actionPreviousSong() {
        songCardView.revertAction()
    }
    
    @objc final func actionNextSong() {
        player?.playbackDelegate.audioStreaming!(player, didStopPlayingTrack: currentPlayingTrack?.trackUri)
        songCardView.swipe(.left, force: true)
    }
    
    @objc final func seekSong(interval: Float) {
        player?.seek(to: TimeInterval(interval), callback: { (error) in
            if let error = error {
                print("Error seeking track! error: \(error.localizedDescription)")
            }
        })
    }
    
    @objc final func remoteControlSeekSong(event: MPRemoteCommandEvent) {
        if event is MPChangePlaybackPositionCommandEvent {
            let command = event as! MPChangePlaybackPositionCommandEvent
            seekSong(interval: Float(command.positionTime))
        }
    }
    
    @objc final func remoteControlPlaySong(event: MPRemoteCommandEvent) {
        remoteControlPausePlay(playSong: true)
    }
    
    @objc final func remoteControlPauseSong(event: MPRemoteCommandEvent) {
        remoteControlPausePlay(playSong: false)
    }
    
    @objc private func remoteControlPausePlay(playSong: Bool) {
        let nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
        
        if var nowPlayingInfo = nowPlayingInfo {
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = playSong ? 1 : 0
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player?.playbackState.position
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            self.isPlaying = playSong
            spotifyPausePlay()
        }
    }
    
    @objc final func actionPlaySpotifyTrack(spotifyTrackId: String) {
        self.isPlaying = false
        self.activateAudioSession()
        player?.playSpotifyURI(spotifyTrackId, startingWith: 0, startingWithPosition: 0, callback: { (error) in
            self.isPlaying = true;
            self.togglePausePlayIcon()
            if (error != nil) {
                self.actionPlaySpotifyTrack(spotifyTrackId: spotifyTrackId)
            }
        })
    }
    
    @objc final func actionStopPlayer() {
        self.isPlaying = false
        self.player?.logout()
        self.deactivateAudioSession()
        UIApplication.shared.endReceivingRemoteControlEvents();
    }
    
    final func updateNowPlayingCenter(title: String, artist: String, albumArt: AnyObject? = nil, currentTime: NSNumber, songLength: NSNumber, playbackRate: Double){
        
        var trackInfo: [String: AnyObject] = [
            
            MPMediaItemPropertyTitle: title as AnyObject,
            MPMediaItemPropertyArtist: artist as AnyObject,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime as AnyObject,
            MPMediaItemPropertyPlaybackDuration: songLength as AnyObject,
            MPNowPlayingInfoPropertyPlaybackRate: playbackRate as AnyObject
        ]
        
        var albumImage: MPMediaItemArtwork
        if albumArt != nil {
            albumImage = MPMediaItemArtwork(image: albumArt as! UIImage)
            trackInfo[MPMediaItemPropertyArtwork] = albumImage as AnyObject
        } else {
            albumImage = MPMediaItemArtwork(boundsSize: CGSize.zero, requestHandler: { (size) -> UIImage in
                return UIImage()
            })
        }
        
        DispatchQueue.main.async {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = trackInfo as [String : AnyObject]
        }
        
    }
  
    func detectConnectivity() -> Bool {
        if Connectivity.isConnectedToNetwork() == .connectedCellular && !playOnCellularData! {
            let dialog = PopupDialog(title: "Warning!", message: "We detected that you are using cellular data and you have disabled this. Do you wish to continue listening to music on cellular data?", transitionStyle: .zoomIn, gestureDismissal: false, completion: nil)
            
            dialog.addButton(DefaultButton(title: "Yes, keep playing!", action: {
                self.playOnCellularData = true
                self.audioStreaming(self.player!, didStartPlayingTrack: self.player?.metadata.currentTrack?.uri)
            }))
            dialog.addButton(CancelButton(title: "No", action: {
                let parent = self.parent as! NusicPageViewController
                parent.scrollToPreviousViewController();
                parent.removeViewControllerFromPageVC(viewController: self)
                self.actionStopPlayer()
            }))
            
            self.present(dialog, animated: true, completion: nil)
            return false
        } else {
            return true
        }
    }
}

