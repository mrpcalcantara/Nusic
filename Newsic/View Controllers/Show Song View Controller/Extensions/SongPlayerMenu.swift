//
//  SongPlayerMenu.swift
//  Nusic
//
//  Created by Miguel Alcantara on 09/10/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//
import Foundation
import UIKit

extension ShowSongViewController {
        
    func setupPlayerMenu() {
        setupConstraints(for: self.view.frame.size)
        
        showMore.setImage(UIImage(named: "ShowMore"), for: .normal)
        showMore.alpha = 1
        showMore.layer.zPosition = -1
        showMore.translatesAutoresizingMaskIntoConstraints = false;
        
        previousSong.setImage(UIImage(named: "ThumbsDown"), for: .normal)
        previousSong.isHidden = true
        previousSong.layer.zPosition = 1;
        previousSong.translatesAutoresizingMaskIntoConstraints = false;
        previousSong.transform = CGAffineTransform(scaleX: 0.75, y: 0.75);
        
        if pausePlay.image(for: .normal) == nil {
            pausePlay.setImage(UIImage(named: "PlayTrack"), for: .normal)
        }
        
        pausePlay.isHidden = true
        pausePlay.layer.zPosition = -1;
        pausePlay.transform = CGAffineTransform(scaleX: 1.25, y: 1.25);
        
        nextSong.setImage(UIImage(named: "ThumbsUp"), for: .normal)
        nextSong.isHidden = true
        nextSong.layer.zPosition = 1;
        nextSong.transform = CGAffineTransform(scaleX: 0.75, y: 0.75);
        
        previousTrack.setImage(UIImage(named: "Rewind"), for: .normal)
        previousTrack.isHidden = true
        previousTrack.layer.zPosition = -1;
        previousTrack.transform = CGAffineTransform(scaleX: 1.25, y: 1.25);
        
        nextTrack.setImage(UIImage(named: "FastForward"), for: .normal)
        nextTrack.isHidden = true
        nextTrack.layer.zPosition = -1;
        nextTrack.transform = CGAffineTransform(scaleX: 1.25, y: 1.25);
        
        if preferredPlayer == NusicPreferredPlayer.spotify {
            songProgressSlider.isHidden = false
            
            songProgressView.isHidden = true
            songProgressView.layer.zPosition = 1;
            songProgressView.backgroundColor = UIColor.clear
            
            songProgressSlider.layer.zPosition = 1;
            songProgressSlider.tintColor = UIColor.green
            songProgressSlider.thumbTintColor = UIColor.lightGray
//            let image = UIImage(named: "SongProgressThumb")?.withRenderingMode(.alwaysTemplate)
//            songProgressSlider.setThumbImage(image, for: .normal)
//            songProgressSlider.setThumbImage(image, for: .focused)
//            songProgressSlider.setThumbImage(image, for: .highlighted)
            
            songDurationLabel.layer.zPosition = 1;
            songDurationLabel.textColor = UIColor.lightText
            songDurationLabel.text = songDurationLabel.text == "" ? convertElapsedSecondsToTime(interval: 0) : songDurationLabel.text
            
            songElapsedTime.layer.zPosition = 1;
            songElapsedTime.textColor = UIColor.lightText
            songElapsedTime.text = songElapsedTime.text == "" ? convertElapsedSecondsToTime(interval: 0) : songElapsedTime.text
        }
        
        self.view.layoutIfNeeded()
    }
    
    func reloadPlayerMenu(for size: CGSize) {
        setupConstraints(for: size)
        self.view.layoutIfNeeded()
    }
    
    func openPlayerMenu() {
        UIView.animate(withDuration: 0.3) {
            self.pausePlay.alpha = 1
            self.pausePlay.isHidden = false
            self.previousTrack.alpha = 1
            self.previousTrack.isHidden = false
            self.nextTrack.alpha = 1
            self.nextTrack.isHidden = false
            self.previousSong.alpha = 1
            self.previousSong.isHidden = false
            self.nextSong.alpha = 1
            self.nextSong.isHidden = false
            if self.preferredPlayer == NusicPreferredPlayer.spotify {
                self.songProgressView.isHidden = false
                self.songProgressView.alpha = 1
            }
            self.toggleLikeButtons();
            self.trackStackView.alpha = 0.9;
            if let cardView = self.songCardView.viewForCard(at: self.songCardView.currentCardIndex) as? SongOverlayView {
                cardView.genreLabel.alpha = 0
                cardView.songArtist.alpha = 0
            }
            
        }
        
        UIView.animate(withDuration: 0.3) {
            
            
//            self.pausePlayCenterXConstraint.constant = 0
            self.songProgressBottomConstraint.constant += self.view.frame.height * 0.10
            self.songProgressTopConstraint.constant += self.view.frame.height * 0.10
            if self.preferredPlayer == NusicPreferredPlayer.spotify {
                
                self.songCardBottomConstraint.constant += self.view.frame.height * 0.20
                self.showMoreBottomConstraint.constant += self.view.frame.height * 0.15
            } else {
                self.songCardBottomConstraint.constant += self.view.frame.height * 0.15
                self.showMoreBottomConstraint.constant += self.view.frame.height * 0.10
            }
            self.pausePlayTopConstraint.constant += self.view.frame.height * 0.20
            self.previousTrackCenterXConstraint.constant += -self.trackStackView.bounds.width/4
            self.previousTrackTopConstraint.constant += self.view.frame.height * 0.20
            self.nextTrackCenterXConstraint.constant += self.trackStackView.bounds.width/4
            self.nextTrackTopConstraint.constant += self.view.frame.height * 0.20
            self.dislikeSongCenterXConstraint.constant += -self.trackStackView.bounds.width/2
            self.dislikeSongTopConstraint.constant += self.view.frame.height * 0.20
            self.likeSongCenterXConstraint.constant += self.trackStackView.bounds.width/2
            self.likeSongTopConstraint.constant += self.view.frame.height * 0.20
            self.view.layoutIfNeeded();
        }
        self.showMore.transform = CGAffineTransform.identity;
        UIView.animate(withDuration: 0.2, animations: {
            let rotateTransform = CGAffineTransform(rotationAngle: CGFloat.pi*4.5);
            self.showMore.transform = rotateTransform
        }, completion: nil)
        isPlayerMenuOpen = true
        
    }
    
    func closePlayerMenu(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.previousSong.alpha = 0
                self.pausePlay.alpha = 0
                self.nextSong.alpha = 0
                self.previousTrack.alpha = 0
                self.nextTrack.alpha = 0
                
                if self.preferredPlayer == NusicPreferredPlayer.spotify {
                    self.songProgressView.alpha = 0
                }
                if let cardView = self.songCardView.viewForCard(at: self.songCardView.currentCardIndex) as? SongOverlayView {
                    cardView.genreLabel.alpha = 1
                    cardView.songArtist.alpha = 1
                }
            }, completion: { (isCompleted) in
                self.previousSong.isHidden = true
                self.pausePlay.isHidden = true
                self.nextSong.isHidden = true
                self.previousTrack.isHidden = true
                self.nextTrack.isHidden = true
                if self.preferredPlayer == NusicPreferredPlayer.spotify {
                    self.songProgressView.isHidden = true
                }
                
            })
            
            UIView.animate(withDuration: 0.3) {
                
//                self.showMoreBottomConstraint.constant -= self.view.frame.height * 0.15
//                self.songCardBottomConstraint.constant -= self.view.frame.height * 0.20
                self.pausePlayTopConstraint.constant -= self.view.frame.height * 0.20
                self.previousTrackCenterXConstraint.constant -= -self.trackStackView.bounds.width/4
                self.previousTrackTopConstraint.constant -= self.view.frame.height * 0.20
                self.nextTrackCenterXConstraint.constant -= self.trackStackView.bounds.width/4
                self.nextTrackTopConstraint.constant -= self.view.frame.height * 0.20
                self.dislikeSongCenterXConstraint.constant -= -self.trackStackView.bounds.width/2
                self.dislikeSongTopConstraint.constant -= self.view.frame.height * 0.20
                self.likeSongCenterXConstraint.constant -= self.trackStackView.bounds.width/2
                self.likeSongTopConstraint.constant -= self.view.frame.height * 0.20
                self.songProgressBottomConstraint.constant -= self.view.frame.height * 0.10
                self.songProgressTopConstraint.constant -= self.view.frame.height * 0.10
                if self.preferredPlayer == NusicPreferredPlayer.spotify {
                    
                    self.songCardBottomConstraint.constant -= self.view.frame.height * 0.20
                    self.showMoreBottomConstraint.constant -= self.view.frame.height * 0.15
                } else {
                    self.songCardBottomConstraint.constant -= self.view.frame.height * 0.15
                    self.showMoreBottomConstraint.constant -= self.view.frame.height * 0.10
                }
                self.view.layoutIfNeeded();
                
            }
            self.showMore.transform = CGAffineTransform.identity;
            UIView.animate(withDuration: 0.2, animations: {
                let rotateTransform = CGAffineTransform(rotationAngle: -CGFloat.pi);
                self.showMore.transform = rotateTransform
            }, completion: nil);
        } else {
            hideButtons();
        }
        isPlayerMenuOpen = false
    }
    
    func togglePlayerMenu() {
        if isPlayerMenuOpen {
            closePlayerMenu(animated: true)
        } else {
            openPlayerMenu()
        }
        
    }
    
    func hideButtons() {
        
        self.previousSong.isHidden = true
        self.pausePlay.isHidden = true
        self.nextSong.isHidden = true
        self.previousTrack.isHidden = true
        self.nextTrack.isHidden = true
        if self.preferredPlayer == NusicPreferredPlayer.spotify {
            self.songProgressView.isHidden = true
        }
        
        self.showMoreBottomConstraint.constant -= self.view.frame.height * 0.15
        self.songCardBottomConstraint.constant -= self.view.frame.height * 0.20
        self.pausePlayTopConstraint.constant -= self.view.frame.height * 0.20
        self.previousTrackTopConstraint.constant -= self.view.frame.height * 0.20
        self.previousTrackCenterXConstraint.constant = 0
        self.nextTrackTopConstraint.constant -= self.view.frame.height * 0.20
        self.nextTrackCenterXConstraint.constant = 0
        self.dislikeSongTopConstraint.constant -= self.view.frame.height * 0.20
        self.dislikeSongCenterXConstraint.constant = 0
        self.likeSongTopConstraint.constant -= self.view.frame.height * 0.20
        self.likeSongCenterXConstraint.constant = 0
        
        if self.preferredPlayer == NusicPreferredPlayer.spotify {
            self.songProgressBottomConstraint.constant -= self.view.frame.height * 0.10
            self.songProgressTopConstraint.constant -= self.view.frame.height * 0.10
        }
        
        self.view.layoutIfNeeded();
    }
    
    func toggleLikeButtons() {
        if !self.isSongLiked {
            showLikeButtons()
        } else {
            hideLikeButtons()
        }
    }
    
    func showLikeButtons() {
        DispatchQueue.main.async {
            self.previousSong.alpha = 1
            self.previousSong.isUserInteractionEnabled = true
            self.nextSong.alpha = 1
            self.nextSong.isUserInteractionEnabled = true
        }
        
    }
    
    func hideLikeButtons() {
        DispatchQueue.main.async {
            self.previousSong.alpha = 0.25
            self.previousSong.isUserInteractionEnabled = false
            self.nextSong.alpha = 0.25
            self.nextSong.isUserInteractionEnabled = false
        }
    }
    
    func setupSongProgress(duration: Float) {
        let currentDuration = Int(duration)
        setupSlider(duration: duration)
        updateElapsedTime(elapsedTime: 0, duration: duration)
        songDurationLabel.text = convertElapsedSecondsToTime(interval: currentDuration);
    }
    
    func updateElapsedTime(elapsedTime: Float, duration: Float ) {
        songElapsedTime.text = convertElapsedSecondsToTime(interval: Int(elapsedTime))
        let durationLeft = convertElapsedSecondsToTime(interval: Int(elapsedTime-duration))
        songDurationLabel.text = !durationLeft.contains("-") ? "-\(durationLeft)" : durationLeft
    }
    
    func setupSlider(duration: Float) {
        songProgressSlider.maximumValue = duration
        songProgressSlider.minimumValue = 0
        songProgressSlider.setValue(0, animated: true)
    }
    
}



