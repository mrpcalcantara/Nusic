//
//  ShowSongDataTransfer.swift
//  Newsic
//
//  Created by Miguel Alcantara on 28/11/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

extension SongPickerViewController {
    
    func passDataToShowSong() {
//        let parent = self.parent as! NewsicPageViewController
//        let playerViewController = parent.showSongVC as! ShowSongViewController
//        
//        playerViewController.user = newsicUser;
//        playerViewController.playlist = newsicPlaylist;
//        playerViewController.spotifyHandler = spotifyHandler;
//        playerViewController.moodObject = moodObject
//        playerViewController.selectedGenreList = !selectedGenres.isEmpty ? selectedGenres : nil;
//        playerViewController.isMoodSelected = isMoodSelected
//        
//        parent.scrollToViewController(index: 2)
        let parent = self.parent as! NewsicPageViewController
        let playerViewController = parent.showSongVC as! ShowSongViewController
        parent.removeViewControllerFromPageVC(viewController: playerViewController)
        parent.addViewControllerToPageVC(viewController: playerViewController)
        //            playerViewController.transitioningDelegate = self
        playerViewController.user = newsicUser;
        playerViewController.playlist = newsicPlaylist;
        playerViewController.spotifyHandler = spotifyHandler;
        playerViewController.moodObject = moodObject
        playerViewController.selectedGenreList = !selectedGenres.isEmpty ? selectedGenres : nil;
        playerViewController.isMoodSelected = isMoodSelected
        playerViewController.newMoodOrGenre = true;
        parent.scrollToNextViewController()
//        self.performSegue(withIdentifier: showVideoSegue, sender: self);
    }

    
}
