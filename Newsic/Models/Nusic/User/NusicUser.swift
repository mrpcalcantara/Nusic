//
//  NusicUser.swift
//  Nusic
//
//  Created by Miguel Alcantara on 07/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation
import FirebaseDatabase

class NusicUser: Iterable {
    
    var userName: String {
        didSet {
            userName.replace(symbol: ".", with: "-")
        }
    }
    var version: String?
    var displayName: String
    var territory: String
    var profileImage: UIImage?
    var favoriteGenres: [NusicGenre]?
    var isPremium: Bool?
    var settingValues: NusicUserSettings
    var reference: DatabaseReference!
    
    init(version: String? = "1.1", userName: String, displayName: String? = "", imageURL: String? = "", territory: String? = "", favoriteGenres: [NusicGenre]? = nil, isPremium: Bool? = false, settingValues: NusicUserSettings? = NusicUserSettings()) {
        let firebaseUsername = userName.replaceSymbols(symbol: ".", with: "-")
        self.userName = firebaseUsername
        self.displayName = displayName!;
        self.territory = territory!;
        self.favoriteGenres = favoriteGenres;
        self.isPremium = isPremium
        self.settingValues = settingValues!;
        self.settingValues.preferredPlayer = isPremium! ? NusicPreferredPlayer.spotify : NusicPreferredPlayer.youtube
        self.version = version!
        self.getImage(imageURL: imageURL!);
        self.reference = Database.database().reference();
        setupListeners()
    }
    
    convenience init(user: SPTUser) {
        self.init(userName: user.canonicalUserName!)
        userName = user.canonicalUserName!
        displayName = user.displayName != nil ? user.displayName : ""
        let imageURL = user.smallestImage != nil ? user.smallestImage.imageURL.absoluteString : ""
        self.getImage(imageURL: imageURL)
        territory = user.territory != nil ? user.territory! : "";
        isPremium = user.product == SPTProduct.premium ? true : false
    }
    
    private func getImage(imageURL: String) {
        let image = UIImage();
        if imageURL != "" {
            let url = URL(string: imageURL)
            image.downloadImage(from: url!, downloadImageHandler: { (image) in
                self.profileImage = image;
            })
        } 
    }
    
}

extension NusicUser: FirebaseModel {
    
    private func setupListeners() {
        
        //Delete
        Database.database().reference().child("users").child(userName).observe(.childRemoved) { (dataSnapshot) in
            Database.database().reference().child("settings").child(self.userName).removeValue()
            Database.database().reference().child("playlists").child(self.userName).removeValue()
            Database.database().reference().child("suggestedTracks").child(self.userName).removeValue()
            Database.database().reference().child("moodTracks").child(self.userName).removeValue()
            Database.database().reference().child("likedTracks").child(self.userName).removeValue()
            Database.database().reference().child("genres").child(self.userName).removeValue()
            FirebaseAuthHelper.deleteUserData(userId: self.userName)
            UserDefaults.standard.removeObject(forKey: "SpotifySession")
        }
    }
    
    internal func getData(getCompleteHandler: @escaping (NSDictionary?, NusicError?) -> ()) {
        reference.child("users").child(userName).observeSingleEvent(of: .value, with: { (dataSnapshot) in
            let value = dataSnapshot.value as? NSDictionary
            getCompleteHandler(value, nil);
        }) { (error) in
            getCompleteHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.getUser.rawValue, systemError: error));
        }
        
        
    }
    
    internal func saveData(saveCompleteHandler: @escaping (DatabaseReference?, NusicError?) -> ()) {
        let dictionary = ["canonicalUserName": userName,
                          "displayName": displayName,
                          "territory": territory,
                          "isPremium": isPremium! ? 1 : 0,
                          "version": version as Any] as [String : Any]
        
        
        reference.child("users").child(userName).updateChildValues(dictionary) { (error, reference) in
            let error = error == nil ? nil : NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.saveUser.rawValue, systemError: error)
            saveCompleteHandler(reference, error)
        }
    }
    
    internal func deleteData(deleteCompleteHandler: @escaping (DatabaseReference?, NusicError?) -> ()) {
        reference.child("users").child(userName).removeValue { (error, databaseReference) in
            let error = error == nil ? nil : NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.deleteUser.rawValue, systemError: error)
            deleteCompleteHandler(self.reference, error)
        }
    }
    
    final func getUser(getUserHandler: @escaping (NusicUser?, NusicError?) -> ()) {
        getData { (dictionary, error) in
            guard let dictionary = dictionary, dictionary.count > 1 else { getUserHandler(nil, error); return; }
            self.userName = dictionary["canonicalUserName"] as? String ?? self.userName
            self.displayName = dictionary["displayName"] as? String ?? self.displayName
            self.isPremium = dictionary["isPremium"] as? NSNumber != nil ? Bool(truncating: dictionary["isPremium"] as! NSNumber) : self.isPremium
            self.territory = dictionary["territory"] as? String != nil && dictionary["territory"] as? String != "" ? dictionary["territory"] as! String : self.territory
            self.version = dictionary["version"] as? String ?? "1.0"
            self.getSettings(fetchSettingsHandler: { (settings, error) in
                if let settings = settings {
                    self.settingValues = settings
                } else {
                    let preferredPlayer:NusicPreferredPlayer = self.isPremium! ? .spotify : .youtube
                    self.settingValues = NusicUserSettings(useMobileData: false, preferredPlayer: preferredPlayer)
                }
                getUserHandler(self, error);
            })
        }
    }
    
    final func saveUser(saveUserHandler: @escaping (Bool?, NusicError?) -> ()) {
        saveData { (databaseReference, error) in
            guard error == nil else { saveUserHandler(false, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.saveUser.rawValue, systemError: error)); return; }
            self.saveSettings(saveSettingsHandler: { (isSaved, error) in
                saveUserHandler(isSaved, error)
            })
        }
    }
    
    final func deleteUser(deleteUserHandler: @escaping (Bool?, NusicError?) -> ()) {
        deleteData { (databaseReference, error) in
            let error = error == nil ? nil : NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.deleteUser.rawValue, systemError: error)
            deleteUserHandler(error == nil, error)

        }
    }
    
    final func getFavoriteGenres(getGenresHandler: @escaping ([String: Int]?, NusicError?) -> ()) {
        let closureSelf = self;
        var convertedDict: ([String: Int])?
        var error: NusicError?
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        reference.child("genres").child(userName).observeSingleEvent(of: .value, with: { (dataSnapshot) in
            if let value = dataSnapshot.value as? NSDictionary, let dict = value as? [String: Int] {
                convertedDict = dict
                var iterator = dict.makeIterator()
                var nextElement = iterator.next();
                var genreList: [NusicGenre]? = []
                while nextElement != nil {
                    if let element = nextElement {
                        genreList?.append(NusicGenre(mainGenre: element.key, count: element.value, userName: closureSelf.userName))
                    }
                    nextElement = iterator.next()
                }
                closureSelf.favoriteGenres = genreList;
            } 
            dispatchGroup.leave()
        }, withCancel: { (cancelError) in
            error = NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.getFavoriteGenres.rawValue, systemError: cancelError)
            dispatchGroup.leave()
        })
        
        dispatchGroup.notify(queue: .main) {
            getGenresHandler(convertedDict, error);
        }
        
    }
    
    final func saveFavoriteGenres(saveGenresHandler: @escaping (Bool?, NusicError?) -> ()) {
        guard let favoriteGenres = favoriteGenres else { return; }
        var dict:[String: Int] = [:]
        for genre in favoriteGenres {
            dict[genre.mainGenre] = genre.count
        }
        Database.database().reference().child("genres").child(userName).updateChildValues(dict, withCompletionBlock: { (error, reference) in
            let error = error == nil ? nil : NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.saveFavoriteGenres.rawValue, systemError: error)
            saveGenresHandler(error == nil, error)
        })
    }
    
    final func deleteFavoriteGenres(deleteGenresHandler: @escaping (Bool?, NusicError?) -> ()) {
        Database.database().reference().child("genres").child(userName).removeValue { (error, reference) in
            let error = error == nil ? nil : NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.deleteFavoriteGenres.rawValue, systemError: error)
            deleteGenresHandler(error == nil, error)
        }
    }
    
    final func updateGenreCount(for genre: String, updateGenreHandler: @escaping (Bool?, NusicError?) -> ()) {
        if favoriteGenres == nil {
            self.favoriteGenres = []
        }
        guard var favoriteGenres = favoriteGenres else { return; }
        let key = reference.child("genres").child(userName)
        var localGenre: NusicGenre
        var updatedValue: [String: Int]
        if let genreIndex = favoriteGenres.index(where: { (localGenre) -> Bool in
            return localGenre.mainGenre == genre
        }) {
            //                favoriteGenres[genreIndex].count += 1
            localGenre = favoriteGenres[genreIndex]
            localGenre.count += 1
            self.favoriteGenres![genreIndex] = localGenre
        } else {
            localGenre = NusicGenre(mainGenre: genre, count: 1, userName: userName)
            self.favoriteGenres?.append(localGenre)
        }
        
        updatedValue = [localGenre.mainGenre:localGenre.count];
        
        key.updateChildValues(updatedValue, withCompletionBlock: { (error, reference) in
            let error = error == nil ? nil : NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.updateGenreCount.rawValue, systemError: error)
            updateGenreHandler(error == nil, error)
        })
        
    }
    
    //Settings
    //----------------
    
    final func getSettings(fetchSettingsHandler: @escaping (NusicUserSettings?, NusicError?) -> ()) {
        reference.child("settings").child(userName).observeSingleEvent(of: .value, with: { (dataSnapshot) in
            guard let dictionary = dataSnapshot.value as? NSDictionary else { fetchSettingsHandler(nil, nil); return; }
            let useMobileData: Bool? = dictionary["useMobileData"] as? NSNumber != nil ? Bool(truncating: dictionary["useMobileData"] as! NSNumber) : true
            let preferredPlayer: NusicPreferredPlayer = dictionary["preferredPlayer"] as? NSNumber != nil ? NusicPreferredPlayer(rawValue: Int(truncating: dictionary["preferredPlayer"] as! NSNumber))! : .youtube
            var spotifySettings = NusicUserSpotifySettings(bitrate: .normal)
            if let spotifyDict = dictionary["spotify"] as? NSDictionary, let bitrate = spotifyDict["bitrate"] as? NSNumber {
                spotifySettings.bitrate = SPTBitrate(rawValue: UInt(truncating: bitrate))!
            }
            let settings = NusicUserSettings(useMobileData: useMobileData!, preferredPlayer: preferredPlayer, spotifySettings: spotifySettings)
            
            fetchSettingsHandler(settings, nil);
        }) { (error) in
            fetchSettingsHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: "", systemError: error));
        }
    }
    
    final func saveSettings(saveSettingsHandler: @escaping(Bool, NusicError?) -> ()) {
        let spotify = settingValues.spotifySettings?.toDictionary()
        let dictionary = ["preferredPlayer": settingValues.preferredPlayer?.rawValue,
                          "useMobileData": settingValues.useMobileData! ? 1 : 0,
                          "spotify": spotify] as [String : Any]
        reference.child("settings").child(userName).updateChildValues(dictionary) { (error, reference) in
            let error = error == nil ? nil : NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.saveSettings.rawValue, systemError: error)
            saveSettingsHandler(error == nil, error)
        }
    }
    
}
