//
//  Spotify.swift
//  Nusic
//
//  Created by Miguel Alcantara on 30/08/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation

class Spotify {
    
    fileprivate static var genreList:[String] = ["acoustic", "afrobeat", "alt-rock", "alternative", "ambient", "anime", "black-metal", "bluegrass", "blues", "bossanova", "brazil", "breakbeat", "british", "cantopop", "chicago-house", "children", "chill", "classical", "club", "comedy", "country", "dance", "dancehall", "death-metal", "deep-house", "detroit-techno", "disco", "disney", "drum-and-bass", "dub", "dubstep", "edm", "electro", "electronic", "emo", "folk", "forro", "french", "funk", "garage", "german", "gospel", "goth", "grindcore", "groove", "grunge", "guitar", "happy", "hard-rock", "hardcore", "hardstyle", "heavy-metal", "hip-hop", "holidays", "honky-tonk", "house", "idm", "indian", "indie", "indie-pop", "industrial", "iranian", "j-dance", "j-idol", "j-pop", "j-rock", "jazz", "k-pop", "kids", "latin", "latino", "malay", "mandopop", "metal", "metal-misc", "metalcore", "minimal-techno", "movies", "mpb", "new-age", "new-release", "opera", "pagode", "party", "philippines-opm", "piano", "pop", "pop-film", "post-dubstep", "power-pop", "progressive-house", "psych-rock", "punk", "punk-rock", "r-n-b", "rainy-day", "reggae", "reggaeton", "road-trip", "rock", "rock-n-roll", "rockabilly", "romance", "sad", "salsa", "samba", "sertanejo", "show-tunes", "singer-songwriter", "ska", "sleep", "songwriter", "soul", "soundtracks", "spanish", "study", "summer", "swedish", "synth-pop", "tango", "techno", "trance", "trip-hop", "turkish", "work-out", "world-music"]
    static let swapURL: String! = "https://newsic-spotifytokenrefresh.herokuapp.com/swap"
    static let refreshURL: String! = "https://newsic-spotifytokenrefresh.herokuapp.com/refresh"
    static let redirectURI: String! = "newsic://callback"
    static let clientId: String! = "82b9329aa00c415f8123445414d473fa"
    static let getAllArtistsForPlaylistUrl: String! = ""
    static let getAllGenresForArtistsUrl: String! = ""
    static let getAllPlaylistsUrl: String! = ""
    static let getFollowedArtistsForUser: String! = ""
    static let getTrackDetailsUrl: String! = ""
    static let getUserUrl: String! = ""
    static let searchMusicForGenresUrl: String! = ""
    var auth: SPTAuth! = SPTAuth.defaultInstance();
    var user: SPTUser! = nil;
    var genreCount: [String: Int] = Spotify.getAllValuesDict()
    
    private func getGenreForTrack(trackId: String, trackGenreHandler: @escaping([String]?, NusicError?) -> ()) {
        getTrackArtist(trackId: trackId) { (fetchedArtistId, error) in
            if error != nil {
                trackGenreHandler(nil, error)
            } else {
                if let fetchedArtistId = fetchedArtistId {
                    self.getGenresForArtist(artistId: fetchedArtistId, fetchedArtistGenresHandler: { (artistGenres, error) in
                        trackGenreHandler(artistGenres, nil);
                    })
                }
            }
        }
    }
    
    final func getGenresForTrackList(trackIdList: [String], trackGenreHandler: @escaping([String]?, NusicError?) -> ()) {
        let count = trackIdList.count;
        var index = 0
        var allGenres:[String] = [];
        guard trackIdList.count > 0 else { trackGenreHandler(nil, nil); return; }
        for trackId in trackIdList {
            getGenreForTrack(trackId: trackId, trackGenreHandler: { (genres, error) in
                guard error == nil else { trackGenreHandler(nil, error); return; }
                if let genres = genres {
                    allGenres.append(contentsOf: genres)
                }
                index += 1
                if index == count {
                    trackGenreHandler(allGenres, nil);
                }
            })
        }
    }
    
    final func getGenreCount(for artistList: [SpotifyArtist]) -> [String: Int] {
        var countDictionary:[String: Int] = [:];
        
        for artist in artistList {
            if let subGenres = artist.subGenres {
                for subGenre in subGenres {
                    if Spotify.genreList.contains(subGenre) {
                        if countDictionary.index(forKey: subGenre) != nil {
                            countDictionary.updateValue(countDictionary[subGenre]!+1, forKey: subGenre)
                        } else {
                            countDictionary[subGenre] = 1;
                        }
                    }
                }
            }
        }
        genreCount = countDictionary
        
        return genreCount;
    }
    
    
    private func getRefreshToken(currentSession: SPTSession, refreshTokenCompletionHandler: @escaping (Bool) -> ()) {
        let userDefaults = UserDefaults.standard;
        SPTAuth.defaultInstance().renewSession(currentSession, callback: { (error, session) in
            guard error == nil else { refreshTokenCompletionHandler(false); return; }
            let sessionData = NSKeyedArchiver.archivedData(withRootObject: session!)
            userDefaults.set(sessionData, forKey: "SpotifySession")
            userDefaults.synchronize()
            self.auth.session = session;
            refreshTokenCompletionHandler(true)
        })
    }
    
    final func executeSpotifyCall(with request: URLRequest, retryNumber: Int? = 3, retryAfter: Int? = 2, spotifyCallCompletionHandler: @escaping (Data?, HTTPURLResponse?, Error?, Bool) -> ()) {
        let session = URLSession.shared;
        session.executeCall(with: request) { (data, response, error, isSuccess) in
            let statusCode = response?.statusCode
            guard error == nil else { spotifyCallCompletionHandler(data, response, error, false); return; }
            if isSuccess {
                spotifyCallCompletionHandler(data, response, error, true)
            } else {
                switch statusCode! {
                case 400...499:
                    if statusCode == HTTPErrorCodes.unauthorized.rawValue {
                        self.getRefreshToken(currentSession: self.auth.session, refreshTokenCompletionHandler: { (isRefreshSuccessful) in
                            guard isRefreshSuccessful,
                                let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                                let url = request.url else { spotifyCallCompletionHandler(data, response, error, isSuccess); return; }
                            appDelegate.auth = self.auth
                            var newRequest = URLRequest(url: url);
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshSuccessful"), object: nil);
                            newRequest.addValue("Bearer \(self.auth.session.accessToken!)", forHTTPHeaderField: "Authorization");
                            self.executeSpotifyCall(with: newRequest, spotifyCallCompletionHandler: spotifyCallCompletionHandler)
                        })
                    }
                case 500...599:
                    spotifyCallCompletionHandler(data, response, error, false);
                default:
                    spotifyCallCompletionHandler(data, nil, error, false);
                }
            }
        }
    }
    
    // STATIC FUNCTIONS
    
    static func transformToURI(type: SpotifyType, id: String) -> String {
        return "\(type.rawValue)\(id)"
    }
    
    static func transformToID(type: SpotifyType, uri: String) -> String {
        var uri = uri
        uri.removeSubrange(uri.range(of: type.rawValue)!)
        return uri
    }
    
    static func getAllValuesDict() -> [String: Int] {
        var dict: [String: Int] = [:]
        for value in SpotifyGenres.allShownValues {
            dict[value.rawValue.lowercased()] = 1
        }
        return dict
    }
    
    static func getFirstArtist(artistName: String) -> String {
        let subString = artistName.split(separator: ",")
        if let substring = subString.first {
            return substring.lowercased()
        } else {
            return artistName.lowercased()
        }
    }
    
    static func getFirstArtist(from list: [String]) -> String {
        if let firstElement = list.first {
            return firstElement
        }
        return ""
    }
    
    static func filterSpotifyGenres(genres: [String]) -> [String] {
        var filteredList: [String] = []
        //Removing the - to match the genres
        let filteredGenreList = Spotify.genreList.map({ $0.replacingOccurrences(of: "-", with: " ")})
        for genre in genres {
            for listedGenre in filteredGenreList {
                if genre.lowercased().range(of: listedGenre.lowercased()) != nil && !filteredList.contains(listedGenre) {
                    filteredList.append(listedGenre)
                }
            }
        }
        return filteredList;
    }
}
