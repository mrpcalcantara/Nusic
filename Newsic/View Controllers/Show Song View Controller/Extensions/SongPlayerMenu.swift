//
//  SongPlayerMenu.swift
//  Newsic
//
//  Created by Miguel Alcantara on 09/10/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation
import UIKit

extension ShowSongViewController {
    
    func setupPlayerMenu() {
        let buttonsInitFrame = self.showMore.frame
        initialPlayerMenuIconCenter = self.showMore.frame
        showMore.setImage(UIImage(named: "ShowMore"), for: .normal)
        showMore.frame = buttonsInitFrame;
        showMore.alpha = 1
        showMore.layer.zPosition = 1
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
        
//        songProgressSlider.frame = buttonsInitFrame;
//        songProgressSlider.setThumbImage(UIImage(named: "SongProgressThumb"), for: .normal)
//        songProgressSlider.isHidden = true
//        songProgressSlider.layer.zPosition = 1;
//        songProgressSlider.translatesAutoresizingMaskIntoConstraints = true;
        if user.preferredPlayer == NewsicPreferredPlayer.spotify {
            songProgressSlider.isHidden = false
            
            songProgressView.frame = buttonsInitFrame;
            songProgressView.isHidden = true
            songProgressView.layer.zPosition = 1;
            songProgressView.translatesAutoresizingMaskIntoConstraints = true;
            songProgressView.backgroundColor = UIColor.clear
            
            songProgressSlider.setThumbImage(UIImage(named: "SongProgressThumb"), for: .normal)
            //songProgressSlider.thumbTintColor = UIColor.white
            songProgressSlider.layer.zPosition = 1;
            songProgressSlider.tintColor = UIColor.green
            songProgressSlider.translatesAutoresizingMaskIntoConstraints = true;
            
            songDurationLabel.layer.zPosition = 1;
            songDurationLabel.textColor = UIColor.lightText
            songDurationLabel.text = convertElapsedSecondsToTime(interval: 0)
            songDurationLabel.translatesAutoresizingMaskIntoConstraints = true;
            
            songElapsedTime.layer.zPosition = 1;
            songElapsedTime.textColor = UIColor.lightText
            songElapsedTime.text = convertElapsedSecondsToTime(interval: 0)
            songElapsedTime.translatesAutoresizingMaskIntoConstraints = true;
        } else {
            
        }
        
        
        self.view.layoutIfNeeded()
        
    }
    
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
        //songProgressSlider.value = 0
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
            let buttonWidth = self.pausePlay.frame.width
            self.pausePlay.alpha = 1
            self.pausePlay.isHidden = false
            self.pausePlay.frame.origin.x = self.view.frame.width * 0.5 - buttonWidth/2
            
            self.previousTrack.frame.origin.x = self.view.frame.width * 0.25 - buttonWidth/2
            self.previousTrack.alpha = 1
            self.previousTrack.isHidden = false
            
            self.nextTrack.frame.origin.x = self.view.frame.width * 0.75 - buttonWidth/2
            self.nextTrack.alpha = 1
            self.nextTrack.isHidden = false
            self.previousSong.frame.origin.x = 0;
            self.previousSong.alpha = 1
            self.previousSong.isHidden = false
            self.nextSong.frame.origin.x = self.view.frame.width - buttonWidth
            self.nextSong.alpha = 1
            self.nextSong.isHidden = false
            if self.user.preferredPlayer == NewsicPreferredPlayer.spotify {
                self.songProgressView.frame.origin.x = self.trackStackView.frame.origin.x - 8
                self.songProgressView.frame.origin.y = self.view.frame.height * 0.9 - buttonWidth
                self.songProgressView.isHidden = false
                self.songProgressView.alpha = 1
                self.songProgressView.frame.size = CGSize(width: self.trackStackView.frame.width-self.trackStackView.frame.origin.x, height: self.songProgressView.frame.height)
            }
            self.showMore.frame.origin.y = self.view.frame.height * 0.84 - buttonWidth

            self.toggleLikeButtons();
            self.trackStackView.alpha = 0.9;
            
            let cardView = self.songCardView.viewForCard(at: self.songCardView.currentCardIndex) as! SongOverlayView
            cardView.genreLabel.alpha = 0
            cardView.songArtist.alpha = 0
            
            self.view.layoutIfNeeded();
        }
        self.showMore.transform = CGAffineTransform.identity;
        UIView.animate(withDuration: 0.2, animations: {
            let rotateTransform = CGAffineTransform(rotationAngle: CGFloat.pi*4.5);
            self.showMore.transform = rotateTransform
        }, completion: nil)
        isPlayerMenuOpen = true

        //songCardView.layoutIfNeeded()

    }
    
    func closePlayerMenu(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                if let buttonsInitFrame = self.initialPlayerMenuIconCenter {
                    self.previousSong.frame = buttonsInitFrame;
                    self.previousSong.alpha = 0
                    self.pausePlay.frame = buttonsInitFrame;
                    self.pausePlay.alpha = 0
                    self.nextSong.frame = buttonsInitFrame;
                    self.nextSong.alpha = 0
                    self.previousTrack.frame = buttonsInitFrame;
                    self.previousTrack.alpha = 0
                    self.nextTrack.frame = buttonsInitFrame;
                    self.nextTrack.alpha = 0
                    if self.user.preferredPlayer == NewsicPreferredPlayer.spotify {
                        self.songProgressView.frame = buttonsInitFrame
                        self.songProgressView.alpha = 0
                    }
                    
                    
                    self.showMore.frame = buttonsInitFrame
                    
                    let cardView = self.songCardView.viewForCard(at: self.songCardView.currentCardIndex) as! SongOverlayView
                    cardView.genreLabel.alpha = 1
                    cardView.songArtist.alpha = 1
                }
                
                
                
                
            }, completion: { (isCompleted) in
                self.previousSong.isHidden = true
                self.pausePlay.isHidden = true
                self.nextSong.isHidden = true
                self.previousTrack.isHidden = true
                self.nextTrack.isHidden = true
                self.songProgressView.isHidden = true
                
            })
            
            UIView.animate(withDuration: 0.3) {
                
                //self.hideButtons()
                let buttonsInitFrame = self.showMore.frame
                self.previousSong.frame = buttonsInitFrame;
                //self.previousSong.isHidden = true
                self.pausePlay.frame = buttonsInitFrame;
                //self.pausePlay.isHidden = true
                self.nextSong.frame = buttonsInitFrame;
                //self.nextSong.isHidden = true
                self.previousTrack.frame = buttonsInitFrame;
                //self.previousTrack.isHidden = true
                self.nextTrack.frame = buttonsInitFrame;
                //self.nextTrack.isHidden = true
                if self.user.preferredPlayer == NewsicPreferredPlayer.spotify {
                    self.songProgressView.frame = buttonsInitFrame
                }
                
                self.view.layoutIfNeeded();
                //self.trackStackView.alpha = 1
                //self.trackStackView.isUserInteractionEnabled = true
                
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
        //songCardView.layoutIfNeeded()
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
        self.songProgressView.frame = buttonsInitFrame;
        self.songProgressView.isHidden = true
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
        self.previousSong.alpha = 1
        self.previousSong.isUserInteractionEnabled = true
        self.nextSong.alpha = 1
        self.nextSong.isUserInteractionEnabled = true
    }
    
    func hideLikeButtons() {
        self.previousSong.alpha = 0.25
        self.previousSong.isUserInteractionEnabled = false
        self.nextSong.alpha = 0.25
        self.nextSong.isUserInteractionEnabled = false
    }
    
}
