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
        
        playerViewController.user = nusicUser;
        playerViewController.playlist = nusicPlaylist;
        playerViewController.spotifyHandler = spotifyHandler;
        playerViewController.moodObject = moodObject
        playerViewController.isMoodSelected = isMoodSelected
        
        var selectedTrackList: [SpotifyTrack] = Array()
        if isMoodSelected {
            selectedSongsForGenre.removeAll()
            playerViewController.selectedGenreList = nil
            for trackList in selectedSongsForMood.values {
                selectedTrackList.append(contentsOf: trackList.map({ $0 }))
            }
            
            for mood in selectedSongsForMood.keys {
                fetchedSongsForMood.removeValue(forKey: mood)
            }
            
        } else {
            
            var selectedGenres: [String: Int] = [:]
            for trackList in selectedSongsForGenre.values {
                selectedTrackList.append(contentsOf: trackList.map({ $0 }))
            }
            
            for genre in selectedSongsForGenre.keys {
                selectedGenres[genre.lowercased()] = 1
                fetchedSongsForGenre.removeValue(forKey: genre)
            }
            
            playerViewController.selectedGenreList = selectedGenres.filter({ $0.key != EmotionDyad.unknown.rawValue })
        }
        playerViewController.selectedSongs = selectedTrackList
        playerViewController.trackFeatures.removeAll()
        playerViewController.playedSongsHistory?.removeAll()
        playerViewController.playOnCellularData = nusicUser.settingValues.useMobileData
        
        playerViewController.newMoodOrGenre = true;
        parent.addViewControllerToPageVC(viewController: playerViewController)
        parent.scrollToNextViewController()

    }

    
}
