//
//  ShowSongViewController-Logic.swift
//  Newsic
//
//  Created by Miguel Alcantara on 15/12/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation
import PopupDialog

extension ShowSongViewController {
    
    @objc func toggleSongMenu() {
        if !isMenuOpen {
            openMenu();
            closePlayerMenu(animated: true)
        } else {
            closeMenu();
        }
        songListMenuProgress = 0
    }
    
    @objc func backToSongPicker() {
        goToPreviousViewController()
    }
    
    @objc func updateAuthObject() {
        self.auth = (UIApplication.shared.delegate as! AppDelegate).auth
    }
    
    func fetchLikedTracks() {
        if moodObject?.emotions.first?.basicGroup == EmotionDyad.unknown {
            spotifyHandler.getAllTracksForPlaylist(playlistId: playlist.id!) { (spotifyTracks, error) in
                if let error = error {
                    error.presentPopup(for: self, description: SpotifyErrorCodeDescription.getPlaylistTracks.rawValue)
                    
                } else {
                    if let spotifyTracks = spotifyTracks {
                        
                        self.getYouTubeResults(tracks: spotifyTracks, youtubeSearchHandler: { (newsicTracks) in
                            self.likedTrackList = newsicTracks;
                        })
                    }
                }
            }
        } else {
            moodObject?.getTrackIdListForEmotionGenre(getAssociatedTrackHandler: { (trackList, error) in
                if let error = error {
                    error.presentPopup(for: self)
                }
                if let trackList = trackList {
                    self.spotifyHandler.getTrackInfo(for: trackList, offset: 0, currentExtractedTrackList: [], trackInfoListHandler: { (spotifyTracks, error) in
                        if let error = error {
                            error.presentPopup(for: self, description: SpotifyErrorCodeDescription.getTrackInfo.rawValue)
                        } else {
                            if let spotifyTracks = spotifyTracks {
                                self.getYouTubeResults(tracks: spotifyTracks, youtubeSearchHandler: { (newsicTracks) in
                                    self.likedTrackList = newsicTracks
                                })
                            }
                        }
                    })
                }
            })
        }
    }
    
    func getSongsForSelectedMood() {
        updateCurrentGenresAndFeatures { (genres, trackFeatures) in
            self.fetchSongsAndSetup(moodObject: self.moodObject)
        }
    }
    
    func getSongsForSelectedGenres() {
        fetchSongsAndSetup(moodObject: self.moodObject)
    }
    
    func fetchSongsAndSetup(numberOfSongs: Int? = nil, moodObject: NewsicMood?) {
        let songCountToSearch = numberOfSongs == nil ? self.cardCount : numberOfSongs
        self.spotifyHandler.searchMusicInGenres(numberOfSongs: songCountToSearch!, moodObject: moodObject, preferredTrackFeatures: trackFeatures, selectedGenreList: self.selectedGenreList) { (results, error) in
            if let error = error {
                //                self.present(error.popupDialog!, animated: true, completion: nil);
                error.presentPopup(for: self, description: SpotifyErrorCodeDescription.getMusicInGenres.rawValue)
            }
            DispatchQueue.main.async {
                self.showSwiftSpinner(text: "Fetching tracks..")
            }
            var newsicTracks:[SpotifyTrack] = [];
            for track in results {
                newsicTracks.append(track);
                self.playedSongsHistory?.append(track)
            }
            if newsicTracks.count == 0 {
                self.setupSongs();
            } else {
                self.getYouTubeResults(tracks: newsicTracks, youtubeSearchHandler: { (tracks) in
                    self.cardList = tracks
                    DispatchQueue.main.async {
                        self.songCardView.reloadData()
                        self.showSwiftSpinner(text: "Done!", duration: 2)
                    }
                    
                    
                })
            }
        }
    }
    
    func getYouTubeResults(tracks: [SpotifyTrack], youtubeSearchHandler: @escaping ([NewsicTrack]) -> ()) {
        var index = 0
        var ytTracks: [NewsicTrack] = []
        for track in tracks {
            YouTubeSearch.getSongInfo(artist: track.artist.artistName, songName: track.songName, completionHandler: { (youtubeInfo) in
                index += 1
                if let currentIndex = tracks.index(where: { (currentTrack) -> Bool in
                    return currentTrack.trackId == track.trackId
                }) {
                    
                    let newsicTrack = NewsicTrack(trackInfo: tracks[currentIndex], moodInfo: self.moodObject, userName: self.auth.session.canonicalUsername, youtubeInfo: youtubeInfo);
                    
                    ytTracks.append(newsicTrack);
                }
                //                print("index: \(index) ==== \(track.title) -> trackId = \(youtubeInfo?.trackId)")
                
                if index == tracks.count {
                    youtubeSearchHandler(ytTracks)
                }
            })
        }
        
    }
    
    func updateCurrentGenresAndFeatures(updateGenresFeaturesHandler: @escaping ([String]?, [SpotifyTrackFeature]?) -> ()) {
        getGenresAndFeaturesForMoods(genresFeaturesHandler: { (genres, trackFeatures) in
            if let genres = genres {
                self.moodObject?.associatedGenres = genres
            }
            self.trackFeatures = trackFeatures;
            updateGenresFeaturesHandler(genres, trackFeatures);
        });
    }
    
    func getGenresAndFeaturesForMoods(genresFeaturesHandler: @escaping([String]?, [SpotifyTrackFeature]?) -> ()) {
        moodObject?.getTrackIdAndFeaturesForEmotion(trackIdAndFeaturesHandler: { (trackIdList, trackFeatures, error) in
            if let error = error {
                error.presentPopup(for: self)
            }
            if let trackIdList = trackIdList {
                self.spotifyHandler.getGenresForTrackList(trackIdList: trackIdList, trackGenreHandler: { (genres, error) in
                    if let error = error {
                        error.presentPopup(for: self, description: SpotifyErrorCodeDescription.getGenresForTrackList.rawValue)
                    } else {
                        if let genres = genres {
                            //print("GENRES EXTRACTED = \(genres)");
                            genresFeaturesHandler(genres, trackFeatures)
                            
                        } else {
                            genresFeaturesHandler(nil, trackFeatures);
                        }
                    }
                })
            } else {
                self.moodObject?.getDefaultTrackFeatures(getDefaultTrackFeaturesHandler: { (defaultTrackFeatures, error) in
                    if let error = error {
                        error.presentPopup(for: self)
                    }
                    if let defaultTrackFeatures = defaultTrackFeatures {
                        genresFeaturesHandler(nil, defaultTrackFeatures)
                    } else {
                        genresFeaturesHandler(nil, nil)
                    }
                })
                
            }
            
        })
    }
    
    func fetchNewCard(cardFetchingHandler: ((Bool) -> ())?){
        //        print("fetching new card...")
        let moodObject = self.moodObject
        
        spotifyHandler.searchMusicInGenres(numberOfSongs: 1, moodObject: moodObject, preferredTrackFeatures: trackFeatures, selectedGenreList: selectedGenreList) { (results, error)  in
            if let error = error {
                error.presentPopup(for: self, description: SpotifyErrorCodeDescription.getMusicInGenres.rawValue)
            }
            
            if let track = results.first {
                let containsCheck = self.playedSongsHistory?.contains(where: { (trackInHistory) -> Bool in
                    return trackInHistory.trackId == track.trackId
                })
                if containsCheck! {
                    //                    print("REFETCHING NEW CARD.. \(track.trackId) already in list")
                    self.spotifyHandler.searchMusicInGenres(numberOfSongs: 1, moodObject: moodObject, completionHandler: { (results, error) in
                        
                        if let cardFetchingHandler = cardFetchingHandler {
                            cardFetchingHandler(false)
                        }
                        
                    })
                } else {
                    if let track = results.first {
                        self.getYouTubeResults(tracks: [track], youtubeSearchHandler: { (tracks) in
                            for track in tracks {
                                self.addSongToCardPlaylist(track: track)
                            }
                            DispatchQueue.main.async {
                                self.songCardView.reloadData();
                            }
                        })
                        
                    }
                    
                    if let cardFetchingHandler = cardFetchingHandler {
                        cardFetchingHandler(true);
                    }
                    
                }
            }
            
        }
    }
    
    func removeTrackFromLikedTracks(indexPath: IndexPath, removeTrackHandler: @escaping (Bool) -> ()) {
        
        let index = likedTrackList.count - indexPath.row-1
        let strIndex = String(index)
        let track = likedTrackList[indexPath.row]
        
        let trackDict: [String: String] = [ strIndex : track.trackInfo.trackUri ]
        spotifyHandler.removeTrackFromPlaylist(playlistId: playlist.id!, tracks: trackDict) { (didRemove, error) in
            if let error = error {
                error.presentPopup(for: self, description: SpotifyErrorCodeDescription.removeTrack.rawValue)
            } else {
                track.deleteData(deleteCompleteHandler: { (ref, error) in
                    if error != nil {
                        removeTrackHandler(false)
                        print("ERROR DELETING TRACK");
                    } else {
                        self.likedTrackList.remove(at: indexPath.row)
                        removeTrackHandler(true);
                    }
                })
            }
        }
    }
    
    func addSongToCardPlaylist(track: NewsicTrack) {
        self.cardList.append(track)
        self.playedSongsHistory?.append(track.trackInfo)
    }
    
    func checkConnectivity() -> Bool {
        let title = "Error!"
        var message = ""
        if Connectivity.isConnectedToNetwork() == .notConnected {
            message = "No connectivity to the network. Please try again when you're connected to a network."
            let popup = PopupDialog(title: title, message: message, transitionStyle: .zoomIn, gestureDismissal: false, completion: nil);
            
            let backButton = DefaultButton(title: "OK", action: {
                self.dismiss(animated: true, completion: nil)
            })
            
            popup.addButton(backButton)
            self.present(popup, animated: true, completion: nil);
            return false
        }
        
        return true;
    }
}
