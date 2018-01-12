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
    
    func setupPlayerMenuPortrait() {
        
        playerMenuMaxWidth = self.view.frame.width
        let buttonsInitFrame = self.showMore.frame
        initialPlayerMenuIconCenter = self.showMore.frame
        
        showMore.setImage(UIImage(named: "ShowMore"), for: .normal)
        showMore.frame = buttonsInitFrame;
        showMore.alpha = 1
        showMore.layer.zPosition = -1
        showMore.translatesAutoresizingMaskIntoConstraints = true;
        
        previousSong.setImage(UIImage(named: "ThumbsDown"), for: .normal)
        previousSong.frame = buttonsInitFrame;
        previousSong.isHidden = true
        previousSong.layer.zPosition = 1;
        previousSong.translatesAutoresizingMaskIntoConstraints = true;
        previousSong.transform = CGAffineTransform(scaleX: 0.75, y: 0.75);
        
        pausePlay.setImage(UIImage(named: "PlayTrack"), for: .normal)
        pausePlay.frame = buttonsInitFrame;
        pausePlay.isHidden = true
        pausePlay.layer.zPosition = -1;
        pausePlay.translatesAutoresizingMaskIntoConstraints = true;
        pausePlay.transform = CGAffineTransform(scaleX: 1.25, y: 1.25);
        
        nextSong.setImage(UIImage(named: "ThumbsUp"), for: .normal)
        nextSong.frame = buttonsInitFrame;
        nextSong.isHidden = true
        nextSong.layer.zPosition = 1;
        nextSong.translatesAutoresizingMaskIntoConstraints = true;
        nextSong.transform = CGAffineTransform(scaleX: 0.75, y: 0.75);
        
        previousTrack.setImage(UIImage(named: "Rewind"), for: .normal)
        previousTrack.frame = buttonsInitFrame;
        previousTrack.isHidden = true
        previousTrack.layer.zPosition = -1;
        previousTrack.translatesAutoresizingMaskIntoConstraints = true;
        previousTrack.transform = CGAffineTransform(scaleX: 1.25, y: 1.25);
        
        nextTrack.setImage(UIImage(named: "FastForward"), for: .normal)
        nextTrack.frame = buttonsInitFrame;
        nextTrack.isHidden = true
        nextTrack.layer.zPosition = -1;
        nextTrack.translatesAutoresizingMaskIntoConstraints = true;
        nextTrack.transform = CGAffineTransform(scaleX: 1.25, y: 1.25);
        
        if preferredPlayer == NusicPreferredPlayer.spotify {
            songProgressSlider.isHidden = false
            
            songProgressView.frame = buttonsInitFrame;
            songProgressView.isHidden = true
            songProgressView.layer.zPosition = 1;
            songProgressView.translatesAutoresizingMaskIntoConstraints = true;
            songProgressView.backgroundColor = UIColor.clear
            
            songProgressSlider.layer.zPosition = 1;
            songProgressSlider.tintColor = UIColor.green
            
            songDurationLabel.layer.zPosition = 1;
            songDurationLabel.textColor = UIColor.lightText
            songDurationLabel.text = convertElapsedSecondsToTime(interval: 0)
            
            songElapsedTime.layer.zPosition = 1;
            songElapsedTime.textColor = UIColor.lightText
            songElapsedTime.text = convertElapsedSecondsToTime(interval: 0)
        }
        
        self.view.layoutIfNeeded()
        
    }
    
    func setupPlayerMenuLandscape() {
        
        playerMenuMaxWidth = self.view.frame.width*(2/3)
        let buttonsInitFrame = self.showMore.frame
        initialPlayerMenuIconCenter = self.showMore.frame
        
        showMore.setImage(UIImage(named: "ShowMore"), for: .normal)
        showMore.frame = buttonsInitFrame;
        showMore.alpha = 1
        showMore.layer.zPosition = -1
        showMore.translatesAutoresizingMaskIntoConstraints = true;
        
        previousSong.setImage(UIImage(named: "ThumbsDown"), for: .normal)
        previousSong.frame = buttonsInitFrame;
        previousSong.isHidden = true
        previousSong.layer.zPosition = 1;
        previousSong.translatesAutoresizingMaskIntoConstraints = true;
        previousSong.transform = CGAffineTransform(scaleX: 0.75, y: 0.75);
        
        pausePlay.setImage(UIImage(named: "PlayTrack"), for: .normal)
        pausePlay.frame = buttonsInitFrame;
        pausePlay.isHidden = true
        pausePlay.layer.zPosition = -1;
        pausePlay.translatesAutoresizingMaskIntoConstraints = true;
        pausePlay.transform = CGAffineTransform(scaleX: 1.25, y: 1.25);
        
        nextSong.setImage(UIImage(named: "ThumbsUp"), for: .normal)
        nextSong.frame = buttonsInitFrame;
        nextSong.isHidden = true
        nextSong.layer.zPosition = 1;
        nextSong.translatesAutoresizingMaskIntoConstraints = true;
        nextSong.transform = CGAffineTransform(scaleX: 0.75, y: 0.75);
        
        previousTrack.setImage(UIImage(named: "Rewind"), for: .normal)
        previousTrack.frame = buttonsInitFrame;
        previousTrack.isHidden = true
        previousTrack.layer.zPosition = -1;
        previousTrack.translatesAutoresizingMaskIntoConstraints = true;
        previousTrack.transform = CGAffineTransform(scaleX: 1.25, y: 1.25);
        
        nextTrack.setImage(UIImage(named: "FastForward"), for: .normal)
        nextTrack.frame = buttonsInitFrame;
        nextTrack.isHidden = true
        nextTrack.layer.zPosition = -1;
        nextTrack.translatesAutoresizingMaskIntoConstraints = true;
        nextTrack.transform = CGAffineTransform(scaleX: 1.25, y: 1.25);
        
        if preferredPlayer == NusicPreferredPlayer.spotify {
            songProgressSlider.isHidden = false
            
            songProgressView.frame = buttonsInitFrame;
            songProgressView.isHidden = true
            songProgressView.layer.zPosition = 1;
            songProgressView.translatesAutoresizingMaskIntoConstraints = true;
            songProgressView.backgroundColor = UIColor.clear
            
            songProgressSlider.layer.zPosition = 1;
            songProgressSlider.tintColor = UIColor.green
            
            songDurationLabel.layer.zPosition = 1;
            songDurationLabel.textColor = UIColor.lightText
            songDurationLabel.text = convertElapsedSecondsToTime(interval: 0)
            
            songElapsedTime.layer.zPosition = 1;
            songElapsedTime.textColor = UIColor.lightText
            songElapsedTime.text = convertElapsedSecondsToTime(interval: 0)
        }
        
        self.view.layoutIfNeeded()
        
    }
    
    func setupPlayerMenu() {
        setupConstraints(for: self.view.safeAreaLayoutGuide.layoutFrame.size)
        if UIApplication.shared.statusBarOrientation.isPortrait {
            setupPlayerMenuPortrait()
        } else {
            setupPlayerMenuLandscape()
        }
    }
    
//    func reloadPlayerMenu() {
//        showMore.translatesAutoresizingMaskIntoConstraints = false;
//        previousSong.translatesAutoresizingMaskIntoConstraints = false;
//        pausePlay.translatesAutoresizingMaskIntoConstraints = false;
//        nextSong.translatesAutoresizingMaskIntoConstraints = false;
//        previousTrack.translatesAutoresizingMaskIntoConstraints = false;
//        nextTrack.translatesAutoresizingMaskIntoConstraints = false;
//        if preferredPlayer == NusicPreferredPlayer.spotify {
//            songProgressView.translatesAutoresizingMaskIntoConstraints = false;
//        }
//    }
    
    func setupSongProgress(duration: Float) {
        let currentDuration = Int(duration)
        setupSlider(duration: duration)
        updateElapsedTime(elapsedTime: 0)
        songDurationLabel.text = convertElapsedSecondsToTime(interval: currentDuration);
    }
    
    func updateElapsedTime(elapsedTime: Float) {
        songElapsedTime.text = convertElapsedSecondsToTime(interval: Int(elapsedTime))
    }
    
    func setupSlider(duration: Float) {
        songProgressSlider.maximumValue = duration
        songProgressSlider.minimumValue = 0
        songProgressSlider.setValue(0, animated: true)
    }
    
    func openPlayerMenu() {
        UIView.animate(withDuration: 0.3) {
            if let buttonsInitFrame = self.initialPlayerMenuIconCenter {
                self.previousSong.frame = buttonsInitFrame;
                self.pausePlay.frame = buttonsInitFrame;
                self.nextSong.frame = buttonsInitFrame;
                self.previousTrack.frame = buttonsInitFrame;
                self.nextTrack.frame = buttonsInitFrame;
                self.songProgressView.frame = buttonsInitFrame
                self.showMore.frame = buttonsInitFrame
            }
            
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
        if UIApplication.shared.statusBarOrientation.isPortrait {
            openPlayerMenuPortrait()
        } else {
            openPlayerMenuLandscape()
        }
    }
    
    func openPlayerMenuPortrait() {
        UIView.animate(withDuration: 0.3) {
            let buttonWidth = self.pausePlay.frame.width
            self.pausePlay.frame.origin.x = self.playerMenuMaxWidth * 0.5 - buttonWidth/2
            self.previousTrack.frame.origin.x = self.playerMenuMaxWidth * 0.25 - buttonWidth/2
            self.nextTrack.frame.origin.x = self.playerMenuMaxWidth * 0.75 - buttonWidth/2
            self.previousSong.frame.origin.x = 0;
            self.nextSong.frame.origin.x = self.playerMenuMaxWidth - buttonWidth
            if self.preferredPlayer == NusicPreferredPlayer.spotify {
                self.songProgressView.frame.origin.x = self.trackStackView.frame.origin.x
                self.songProgressView.frame.origin.y = self.view.frame.height * 0.9 - buttonWidth
                self.songProgressView.frame.size = CGSize(width: self.trackStackView.frame.width, height: self.songProgressView.frame.height)
            }
             self.showMore.frame.origin.y = self.preferredPlayer == NusicPreferredPlayer.spotify ? self.view.frame.height * 0.84 - buttonWidth : self.view.frame.height * 0.9 - buttonWidth
             if !self.isPlayerMenuOpen {
                self.songCardBottomConstraint.constant += self.view.safeAreaLayoutGuide.layoutFrame.height * 0.84
            }
            self.view.layoutIfNeeded();
        }
        self.showMore.transform = CGAffineTransform.identity;
        UIView.animate(withDuration: 0.2, animations: {
            let rotateTransform = CGAffineTransform(rotationAngle: CGFloat.pi*4.5);
            self.showMore.transform = rotateTransform
        }, completion: nil)
        isPlayerMenuOpen = true
        
    }
    
    func openPlayerMenuLandscape() {
        UIView.animate(withDuration: 0.3) {
            let buttonWidth = self.pausePlay.frame.width
            self.pausePlay.frame.origin.x = self.playerMenuMaxWidth * 0.5 - buttonWidth/2
            self.previousTrack.frame.origin.x = self.playerMenuMaxWidth * 0.25 - buttonWidth/2
            self.nextTrack.frame.origin.x = self.playerMenuMaxWidth * 0.75 - buttonWidth/2
            self.previousSong.frame.origin.x = 0;
            self.nextSong.frame.origin.x = self.playerMenuMaxWidth - buttonWidth
            if self.preferredPlayer == NusicPreferredPlayer.spotify {
                self.songProgressView.frame.origin.x = self.trackStackView.frame.origin.x
                self.songProgressView.frame.origin.y = self.view.frame.height * 0.9 - buttonWidth
                self.songProgressView.frame.size = CGSize(width: self.trackStackView.frame.width, height: self.songProgressView.frame.height)
            }
            self.showMore.frame.origin.y = self.preferredPlayer == NusicPreferredPlayer.spotify ? self.view.frame.height * 0.84 - buttonWidth : self.view.frame.height * 0.9 - buttonWidth
            if !self.isPlayerMenuOpen {
                self.songCardBottomConstraint.constant += self.view.safeAreaLayoutGuide.layoutFrame.height * 0.84
            }
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
                if let buttonsInitFrame = self.initialPlayerMenuIconCenter {
                    self.previousSong.alpha = 0
                    self.pausePlay.alpha = 0
                    self.nextSong.alpha = 0
                    self.previousTrack.alpha = 0
                    self.nextTrack.alpha = 0
                    
                    if self.preferredPlayer == NusicPreferredPlayer.spotify {
                        self.songProgressView.alpha = 0
                    }
                    
                    self.showMore.frame = buttonsInitFrame
                    
                    if let cardView = self.songCardView.viewForCard(at: self.songCardView.currentCardIndex) as? SongOverlayView {
                        cardView.genreLabel.alpha = 1
                        cardView.songArtist.alpha = 1
                    }
                    
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
                
                //self.hideButtons()
                let buttonsInitFrame = self.showMore.frame
                self.previousSong.frame = buttonsInitFrame;
                self.pausePlay.frame = buttonsInitFrame;
                self.nextSong.frame = buttonsInitFrame;
                self.previousTrack.frame = buttonsInitFrame;
                self.nextTrack.frame = buttonsInitFrame;
                if self.preferredPlayer == NusicPreferredPlayer.spotify {
                    self.songProgressView.frame = buttonsInitFrame
                }
                if self.isPlayerMenuOpen {
                    self.songCardBottomConstraint.constant -= self.view.safeAreaLayoutGuide.layoutFrame.height * 0.84
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
        if UIApplication.shared.statusBarOrientation.isPortrait {
            closePlayerMenuPortrait(animated: animated)
        } else {
            closePlayerMenuLandscape(animated: animated)
        }
    }
    
    func closePlayerMenuPortrait(animated: Bool) {
        
    }
    
    func closePlayerMenuLandscape(animated: Bool) {
        
    }
    
    func togglePlayerMenu() {
        if isPlayerMenuOpen {
            closePlayerMenu(animated: true)
        } else {
            openPlayerMenu()
        }
        
    }
    
    func hideButtons() {
        let buttonsInitFrame = self.showMore.frame
        self.previousSong.frame = buttonsInitFrame;
        self.previousSong.isHidden = true
        self.pausePlay.frame = buttonsInitFrame;
        self.pausePlay.isHidden = true
        self.nextSong.frame = buttonsInitFrame;
        self.nextSong.isHidden = true
        self.previousTrack.frame = buttonsInitFrame;
        self.previousTrack.isHidden = true
        self.nextTrack.frame = buttonsInitFrame;
        self.nextTrack.isHidden = true
        if preferredPlayer == NusicPreferredPlayer.spotify {
            self.songProgressView.frame = buttonsInitFrame;
            self.songProgressView.isHidden = true
        }
        //self.trackStackView.alpha = 1
        //self.trackStackView.isUserInteractionEnabled = true
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
    
}



