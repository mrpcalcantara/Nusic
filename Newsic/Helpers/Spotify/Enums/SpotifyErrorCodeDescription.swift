//
//  SpotifyErrorCodeDescription.swift
//  Newsic
//
//  Created by Miguel Alcantara on 04/12/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation

enum SpotifyErrorCodeDescription : String {
    case getPlaylistTracks = "An error occurred when extracting all the tracks for the playlist."
    case getTrackInfo = "An error occured while fetching the track information."
    case getMusicInGenres = "An error occurred while fetching a new card."
    case getTrackIdFeaturesForMood = "An error occured while fetching the tracks information for the chosen mood."
    case removeTrack = "An error occured while removing the track from the Spotify playlist."
    case addTrack = "An error occured while adding the track to the Spotify playlist."
    case createPlaylist = "An error occured while creating the playlist on Spotify."
    case checkPlaylist = "An error occured while checking if the Newsic playlist exists on Spotify."
    case getUser = "An error occured while extracting the user information from Spotify."
    case getGenresForTrackList = "An error occurred extracting the genres for the track list."
    case extractGenresFromUser = "An error occured extracting your preferred genres."
}
