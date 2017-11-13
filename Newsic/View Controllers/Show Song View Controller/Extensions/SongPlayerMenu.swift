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
    }
    
    func openPlayerMenu() {
        UIView.animate(withDuration: 0.3) {
            let buttonWidth = self.pausePlay.frame.width
            //self.pausePlay.frame.size = CGSize(width: 30, height: 30)
            self.pausePlay.frame.origin.y = self.view.frame.height * 0.875 - buttonWidth
            self.pausePlay.alpha = 1
            self.pausePlay.isHidden = false
            self.pausePlay.transform = CGAffineTransform(scaleX: 1.5, y: 1.5);
            self.previousTrack.frame.origin.x = self.view.frame.width * 0.25 - buttonWidth;
            self.previousTrack.frame.origin.y = self.view.frame.height * 0.875 - buttonWidth
            self.previousTrack.alpha = 1
            self.previousTrack.isHidden = false
            self.previousTrack.transform = CGAffineTransform(scaleX: 1.5, y: 1.5);
            //self.previousTrack.frame.size = CGSize(width: 30, height: 30)
            self.nextTrack.frame.origin.x = self.view.frame.width * 0.75;
            self.nextTrack.frame.origin.y = self.view.frame.height * 0.875 - buttonWidth
            self.nextTrack.alpha = 1
            self.nextTrack.isHidden = false
            self.nextTrack.transform = CGAffineTransform(scaleX: 1.5, y: 1.5);
            self.previousSong.frame.origin.x = self.view.frame.width * 0.25 - buttonWidth;
            self.previousSong.transform = CGAffineTransform(scaleX: 1.5, y: 1.5);
            self.previousSong.isHidden = false
            self.nextSong.frame.origin.x = self.view.frame.width * 0.75
            self.nextSong.transform = CGAffineTransform(scaleX: 1.5, y: 1.5);
            self.nextSong.isHidden = false
            
            self.toggleLikeButtons();
            
            
            self.trackStackView.alpha = 0.9;
            //self.trackStackView.isUserInteractionEnabled = false
            self.view.layoutIfNeeded();
        }
        self.showMore.transform = CGAffineTransform.identity;
        UIView.animate(withDuration: 0.2, animations: {
            let rotateTransform = CGAffineTransform(rotationAngle: CGFloat.pi);
            self.showMore.transform = rotateTransform
        }, completion: nil)
        isPlayerMenuOpen = true
        
        //songCardView.layoutIfNeeded()
        
    }
    
    func closePlayerMenu(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                let buttonsInitFrame = self.showMore.frame
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
            }, completion: { (isCompleted) in
                let buttonsInitFrame = self.showMore.frame
                
                self.previousSong.isHidden = true
                self.pausePlay.isHidden = true
                self.nextSong.isHidden = true
                self.previousTrack.isHidden = true
                self.nextTrack.isHidden = true
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
