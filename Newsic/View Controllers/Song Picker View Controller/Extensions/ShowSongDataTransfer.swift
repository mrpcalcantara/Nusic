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
        
        if SPTAudioStreamingController.sharedInstance().loggedIn {
            SPTAudioStreamingController.sharedInstance().logout()
        }
        
        let parent = self.parent as! NewsicPageViewController
        let playerViewController = parent.showSongVC as! ShowSongViewController
        parent.removeViewControllerFromPageVC(viewController: playerViewController)
        parent.addViewControllerToPageVC(viewController: playerViewController)
        playerViewController.user = newsicUser;
        playerViewController.playlist = newsicPlaylist;
        playerViewController.spotifyHandler = spotifyHandler;
        playerViewController.moodObject = moodObject
        playerViewController.isMoodSelected = isMoodSelected
        if isMoodSelected {
            selectedGenres.removeAll()
            playerViewController.selectedGenreList = nil
        } else {
            playerViewController.selectedGenreList = selectedGenres;
        }
        
        playerViewController.playOnCellularData = newsicUser.settingValues.useMobileData
        
        playerViewController.newMoodOrGenre = true;
        parent.scrollToNextViewController()

    }

    
}
