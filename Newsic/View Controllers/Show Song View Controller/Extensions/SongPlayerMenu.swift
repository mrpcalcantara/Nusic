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
        showMore.layer.zPosition = -1
        showMore.translatesAutoresizingMaskIntoConstraints = true;
        
        previousSong.setImage(UIImage(named: "ThumbsDown"), for: .normal)
        previousSong.frame = buttonsInitFrame;
        previousSong.isHidden = true
        previousSong.layer.zPosition = 1;
        previousSong.translatesAutoresizingMaskIntoConstraints = true;
        pausePlay.setImage(UIImage(named: "PlayTrack"), for: .normal)
        pausePlay.frame = buttonsInitFrame;
        pausePlay.isHidden = true
        pausePlay.layer.zPosition = 1;
        pausePlay.translatesAutoresizingMaskIntoConstraints = true;
        nextSong.setImage(UIImage(named: "ThumbsUp"), for: .normal)
        nextSong.frame = buttonsInitFrame;
        nextSong.isHidden = true
        nextSong.layer.zPosition = 1;
        nextSong.translatesAutoresizingMaskIntoConstraints = true;
        previousTrack.setImage(UIImage(named: "Rewind"), for: .normal)
        previousTrack.frame = buttonsInitFrame;
        previousTrack.isHidden = true
        previousTrack.layer.zPosition = 1;
        previousTrack.translatesAutoresizingMaskIntoConstraints = true;
        nextTrack.setImage(UIImage(named: "FastForward"), for: .normal)
        nextTrack.frame = buttonsInitFrame;
        nextTrack.isHidden = true
        nextTrack.layer.zPosition = 1;
        nextTrack.translatesAutoresizingMaskIntoConstraints = true;
        
//        songProgressSlider.frame = buttonsInitFrame;
//        songProgressSlider.setThumbImage(UIImage(named: "SongProgressThumb"), for: .normal)
//        songProgressSlider.isHidden = true
//        songProgressSlider.layer.zPosition = 1;
//        songProgressSlider.translatesAutoresizingMaskIntoConstraints = true;
        
        songProgressView.frame = buttonsInitFrame;
        songProgressView.isHidden = true
        songProgressView.layer.zPosition = 1;
        songProgressView.translatesAutoresizingMaskIntoConstraints = true;
        songProgressView.backgroundColor = UIColor.clear
        
        songProgressSlider.setThumbImage(UIImage(named: "SongProgressThumb"), for: .normal)
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
        songProgressSlider.value = 0
    }
    
    
    
    func openPlayerMenu() {
        UIView.animate(withDuration: 0.3) {
            let buttonWidth = self.pausePlay.frame.width
            //self.pausePlay.frame.size = CGSize(width: 30, height: 30)
            self.pausePlay.frame.origin.y = self.view.frame.height * 0.85 - buttonWidth
            self.pausePlay.alpha = 1
            self.pausePlay.isHidden = false
            self.pausePlay.transform = CGAffineTransform(scaleX: 1.5, y: 1.5);
            self.previousTrack.frame.origin.x = self.view.frame.width * 0.25 - buttonWidth;
            self.previousTrack.frame.origin.y = self.view.frame.height * 0.85 - buttonWidth
            self.previousTrack.alpha = 1
            self.previousTrack.isHidden = false
            self.previousTrack.transform = CGAffineTransform(scaleX: 1.5, y: 1.5);
            //self.previousTrack.frame.size = CGSize(width: 30, height: 30)
            self.nextTrack.frame.origin.x = self.view.frame.width * 0.75;
            self.nextTrack.frame.origin.y = self.view.frame.height * 0.85 - buttonWidth
            self.nextTrack.alpha = 1
            self.nextTrack.isHidden = false
            self.nextTrack.transform = CGAffineTransform(scaleX: 1.5, y: 1.5);
            self.previousSong.frame.origin.x = self.view.frame.width * 0.25 - buttonWidth;
            //self.previousSong.transform = CGAffineTransform(scaleX: 1.5, y: 1.5);
            self.previousSong.isHidden = false
            self.nextSong.frame.origin.x = self.view.frame.width * 0.75
            //self.nextSong.transform = CGAffineTransform(scaleX: 1.5, y: 1.5);
            self.nextSong.isHidden = false

            self.songProgressView.bounds.origin.x = -4
            self.songProgressView.frame.origin.y = self.view.frame.height * 0.7 - buttonWidth
//            self.songProgressView.bounds.origin.y = self.view.frame.height * 0.95 - buttonWidth
            //self.songProgressView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5);
            self.songProgressView.isHidden = false
            self.songProgressView.alpha = 1
            self.songProgressView.bounds.size = CGSize(width: self.songCardView.frame.width - buttonWidth/4, height: self.songProgressView.frame.height)

            self.toggleLikeButtons();


            self.trackStackView.alpha = 0.9;
            //self.trackStackView.isUserInteractionEnabled = false
            self.view.layoutIfNeeded();
        }
        self.showMore.transform = CGAffineTransform.identity;
        UIView.animate(withDuration: 0.2, animations: {
            let rotateTransform = CGAffineTransform(rotationAngle: CGFloat.pi*1.5);
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
                    self.songProgressView.frame = buttonsInitFrame
                    self.songProgressView.alpha = 0
                    
                    self.showMore.frame = buttonsInitFrame
                }
                
                
            }, completion: { (isCompleted) in
                let buttonsInitFrame = self.showMore.frame
                
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
                self.songProgressView.frame = buttonsInitFrame
                
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
            self.previousSong.alpha = 1
            self.previousSong.isUserInteractionEnabled = true
            self.nextSong.alpha = 1
            self.nextSong.isUserInteractionEnabled = true
        } else {
            self.previousSong.alpha = 0.25
            self.previousSong.isUserInteractionEnabled = false
            self.nextSong.alpha = 0.25
            self.nextSong.isUserInteractionEnabled = false
        }
    }
    
}
