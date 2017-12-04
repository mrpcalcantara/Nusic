//
//  NewsicErrorSubCodeDescription.swift
//  Newsic
//
//  Created by Miguel Alcantara on 04/12/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation

enum NewsicErrorSubCodeDescription {
    enum SpotifyErrorSubCodeDescription : String {
        case getPlaylistTracks = "An error occurred when extracting all the tracks for the playlist."
        case getTrackInfo = "An error occured while fetching the track information."
        case getMusicInGenres = "An error occurred while fetching a new card."
        case getTrackIdFeaturesForMood = "An error occured while fetching the tracks information for the chosen mood."
        case removeTrack = "An error occured while removing the track from the Spotify playlist."
    }
}
