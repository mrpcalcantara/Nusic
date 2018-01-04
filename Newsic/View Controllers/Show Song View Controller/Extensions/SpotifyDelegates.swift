//
//  SpotifyDelegates.swift
//  Newsic
//
//  Created by Miguel Alcantara on 31/08/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation
import MediaPlayer
import PopupDialog


extension ShowSongViewController: SPTAudioStreamingDelegate {
    
    func setupStreamingDelegate() {
        player?.delegate = self;
    }
    
    func resetStreamingDelegate() {
        player?.delegate = nil
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePosition position: TimeInterval) {
        
        let currentTrack = audioStreaming.metadata.currentTrack;
        if let currentTrack = currentTrack, let currentPlayingTrack = currentPlayingTrack {
            let currentPosition = Float(position)
            songProgressSlider.value = currentPosition
            updateElapsedTime(elapsedTime: currentPosition)
            let thumbNail = currentPlayingTrack.thumbNail != nil ? currentPlayingTrack.thumbNail : nil
            self.updateNowPlayingCenter(title: currentPlayingTrack.songName, artist: currentPlayingTrack.artist.artistName, albumArt: thumbNail, currentTime: currentPosition as NSNumber, songLength: currentTrack.duration as NSNumber, playbackRate: 1)
        }
        
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didSeekToPosition position: TimeInterval) {
//        print("seeked")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: String!) {
        if Connectivity.isConnectedToNetwork() == .connectedCellular && !playOnCellularData! {
            let dialog = PopupDialog(title: "Warning!", message: "We detected that you are using cellular data and you have disabled this. Do you wish to continue listening to music on cellular data?", transitionStyle: .zoomIn, gestureDismissal: false, completion: nil)
            
            dialog.addButton(DefaultButton(title: "Yes, keep playing!", action: {
                self.playOnCellularData = true
                self.audioStreaming(audioStreaming, didStartPlayingTrack: trackUri)
            }))
            dialog.addButton(CancelButton(title: "No", action: {
                let parent = self.parent as! NewsicPageViewController
                parent.scrollToPreviousViewController();
                parent.removeViewControllerFromPageVC(viewController: self)
                self.actionStopPlayer()
            }))
            
            self.present(dialog, animated: true, completion: nil)
        } else {
            // WORKAROUND : Reload data to correctly show Album Images in Table View. Otherwise, they're downloaded but not correctly loaded in the image view.
            self.songListTableView.reloadData()
            let currentTrack = audioStreaming.metadata.currentTrack;
            
            print("track started");
            if let currentTrack = currentTrack {
                let songTitle = "\(currentTrack.artistName) - \(currentTrack.name)"
                let currentPlayingTrack = SpotifyTrack(title: songTitle, thumbNail: nil, trackUri: currentTrack.uri, trackId: Spotify.transformToID(trackUri: currentTrack.uri), songName: currentTrack.name ,artist: SpotifyArtist(artistName: currentTrack.artistName, subGenres: nil, popularity: nil, uri: currentTrack.artistUri), audioFeatures: nil)
                self.currentPlayingTrack = currentPlayingTrack;
                
                if let imageURL = currentTrack.albumCoverArtURL {
                    let imageURL = URL(string: imageURL)!
                    let image = UIImage(); image.downloadImage(from: imageURL) { (image) in
                        currentPlayingTrack.thumbNail = image
                        self.activateAudioSession()
                        self.updateNowPlayingCenter(title: currentPlayingTrack.songName, artist: currentPlayingTrack.artist.artistName, albumArt: image as AnyObject, currentTime: 0, songLength: currentTrack.duration as NSNumber, playbackRate: 1)
                        DispatchQueue.main.async {
                            self.toggleLikeButtons()
                        }
                        
                    }
                } else {
                    activateAudioSession()
                    updateNowPlayingCenter(title: currentTrack.name, artist: currentTrack.artistName, albumArt: nil, currentTime: 0, songLength: currentTrack.duration as NSNumber, playbackRate: 1)
                }
                setupSongProgress(duration: Float(currentTrack.duration))
            } else {
                print("problem starting track");
            }
        }
    }
    

    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: String!) {
        DispatchQueue.main.async {
            self.hideLikeButtons()
        }
        songCardView.swipe(.left);
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
    func setupPlaybackDelegate() {
        player?.playbackDelegate = self
    }
    
    func resetPlaybackDelegate() {
        player?.playbackDelegate = nil
    }
}


extension ShowSongViewController {
    
    func setupSpotify() {
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
    
    func convertElapsedSecondsToTime(interval: Int) -> String {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        
        let formattedString = formatter.string(from: TimeInterval(interval))!
        //print(formattedString)
        return formattedString
    }
    
    func togglePausePlayIcon() {
        if isPlaying {
            pausePlay.setImage(UIImage(named: "PauseTrack"), for: .normal)
        } else {
            pausePlay.setImage(UIImage(named: "PlayTrack"), for: .normal)
        }
    }
    
    func spotifyPausePlay() {
        
        
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
    
    @objc func actionPreviousSong() {
        songCardView.revertAction()
    }
    
    @objc func actionNextSong() {
        songCardView.swipe(.left)
    }
    
    @objc func seekSong(interval: Float) {
        player?.seek(to: TimeInterval(interval), callback: { (error) in
            if let error = error {
                print("Error seeking track! error: \(error.localizedDescription)")
            }
        })
    }
    
    @objc func remoteControlSeekSong(event: MPRemoteCommandEvent) {
        if event is MPChangePlaybackPositionCommandEvent {
            let command = event as! MPChangePlaybackPositionCommandEvent
            seekSong(interval: Float(command.positionTime))
        }
    }
    
    @objc func remoteControlPlaySong(event: MPRemoteCommandEvent) {
        let nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
        
        if var nowPlayingInfo = nowPlayingInfo {
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player?.playbackState.position
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            spotifyPausePlay()
        }
    }
    
    @objc func remoteControlPauseSong(event: MPRemoteCommandEvent) {
        let nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
        
        if var nowPlayingInfo = nowPlayingInfo {
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player?.playbackState.position
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            spotifyPausePlay()
        }
    }
    
    @objc func actionPlaySpotifyTrack(spotifyTrackId: String) {
        self.isPlaying = false
        self.activateAudioSession()
        player?.playSpotifyURI(spotifyTrackId, startingWith: 0, startingWithPosition: 0, callback: { (error) in
            self.isPlaying = true;
            self.togglePausePlayIcon()
            if (error != nil) {
                print("error playing!, error : \(String(describing: error?.localizedDescription))")
                self.actionPlaySpotifyTrack(spotifyTrackId: spotifyTrackId)
            }
        })
    }
    
    @objc func actionStopPlayer() {
        self.isPlaying = false
        self.player?.logout()
        self.deactivateAudioSession()
        UIApplication.shared.endReceivingRemoteControlEvents();
    }
    
    @objc func actionSeekForward() {
        let nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
        if var nowPlayingInfo = nowPlayingInfo {
            nowPlayingInfo.updateValue(3, forKey: MPNowPlayingInfoPropertyPlaybackRate);
            (MPNowPlayingInfoCenter.default().nowPlayingInfo)!.updateValue(3, forKey: MPNowPlayingInfoPropertyPlaybackRate);
        }
        
    }
    
    @objc func seekToTime() {
        let nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
        if var nowPlayingInfo = nowPlayingInfo {
            let seekTime = nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] as! Double
            
            player?.seek(to: seekTime, callback: { (error) in
                if error != nil {
                    print("error seeking forward. Error: \(error?.localizedDescription)")
                }
                nowPlayingInfo.updateValue(seekTime, forKey: MPNowPlayingInfoPropertyElapsedPlaybackTime);
                nowPlayingInfo.updateValue(1, forKey: MPNowPlayingInfoPropertyPlaybackRate);
            })
        }
        
    }
    
    
    @objc func actionSeekBackward() {
        let nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
        if let nowPlayingInfo = nowPlayingInfo {
            let duration = nowPlayingInfo[MPMediaItemPropertyPlaybackDuration]! as! Double
            let elapsedTime = nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] as! Double
            let seekTime = elapsedTime - (duration / 20)
            if seekTime >= 0 {
                player?.seek(to: seekTime, callback: { (error) in
                    if error != nil {
                        print("error seeking forward. Error: \(error?.localizedDescription)")
                    }
                })
            }
        }
    }
    
    func updateNowPlayingCenter(title: String, artist: String, albumArt: AnyObject? = nil, currentTime: NSNumber, songLength: NSNumber, playbackRate: Double){
        
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
       
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = trackInfo as [String : AnyObject]
        }
        
        
    }
    
    
    // MARK: Activate audio session
    
    func activateAudioSession() {
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try? AVAudioSession.sharedInstance().setActive(true)
        
    }
    
    // MARK: Deactivate audio session
    
    func deactivateAudioSession() {
        try? AVAudioSession.sharedInstance().setActive(false)
    }


}

