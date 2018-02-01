//
//  ShowSongDataTransfer.swift
//  Nusic
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
        
        let parent = self.parent as! NusicPageViewController
        let playerViewController = parent.showSongVC as! ShowSongViewController
        parent.removeViewControllerFromPageVC(viewController: playerViewController)
        parent.addViewControllerToPageVC(viewController: playerViewController)
        playerViewController.user = nusicUser;
        playerViewController.playlist = nusicPlaylist;
        playerViewController.spotifyHandler = spotifyHandler;
        playerViewController.moodObject = moodObject
        playerViewController.isMoodSelected = isMoodSelected
        if isMoodSelected {
            selectedGenres.removeAll()
            playerViewController.selectedGenreList = nil
        } else {
            var selectedTrackList: [SpotifyTrack] = Array()
            for trackList in selectedSongsForGenre.values {
                selectedTrackList.append(contentsOf: trackList.map({ $0 }))
            }
            
            playerViewController.selectedSongs = selectedTrackList
            playerViewController.selectedGenreList = selectedGenres;
        }
        
        playerViewController.playOnCellularData = nusicUser.settingValues.useMobileData
        
        playerViewController.newMoodOrGenre = true;
        parent.scrollToNextViewController()

    }

    
}
