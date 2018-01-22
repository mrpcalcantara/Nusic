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
    var displayName: String
    var emailAddress: String
    var territory: String
    var profileImage: UIImage?
    var favoriteGenres: [NusicGenre]?
    var isPremium: Bool?
    var settingValues: NusicUserSettings
    var reference: DatabaseReference!
    
    init(userName: String, displayName: String? = "", emailAddress: String? = "", imageURL: String? = "", territory: String? = "", favoriteGenres: [NusicGenre]? = nil, isPremium: Bool? = false, settingValues: NusicUserSettings? = NusicUserSettings()) {
        let firebaseUsername = userName.replaceSymbols(symbol: ".", with: "-")
        self.userName = firebaseUsername
        self.displayName = displayName!;
        self.emailAddress = emailAddress!
        self.territory = territory!;
        self.favoriteGenres = favoriteGenres;
        self.isPremium = isPremium
        self.settingValues = settingValues!;
        self.settingValues.preferredPlayer = isPremium! ? NusicPreferredPlayer.spotify : NusicPreferredPlayer.youtube
        
        self.getImage(imageURL: imageURL!);
        self.reference = Database.database().reference();
    }
    
    func getImage(imageURL: String) {
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
                          "emailAddress": emailAddress,
                          "isPremium": isPremium! ? 1 : 0] as [String : Any]
        
        
        reference.child("users").child(userName).updateChildValues(dictionary) { (error, reference) in
            if let error = error {
                saveCompleteHandler(reference, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.saveUser.rawValue, systemError: error))
            } else {
                saveCompleteHandler(reference, nil)
            }
            
        }
        //        reference.child(userName).child(self.id!).updateChildValues(dict);
    }
    
    internal func deleteData(deleteCompleteHandler: @escaping (DatabaseReference?, NusicError?) -> ()) {
        reference.child("users").child(userName).removeValue { (error, databaseReference) in
            if let error = error {
                deleteCompleteHandler(self.reference, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.deleteUser.rawValue, systemError: error))
            } else {
                deleteCompleteHandler(self.reference, nil)
            }
            
        }
    }
    
    func getUser(getUserHandler: @escaping (NusicUser?, NusicError?) -> ()) {
        getData { (dictionary, error) in
            if let dictionary = dictionary, dictionary.count > 1 {
                self.userName = dictionary["canonicalUserName"] as? String ?? self.userName
                
                self.displayName = dictionary["displayName"] as? String ?? self.displayName
                self.emailAddress = dictionary["emailAddress"] as? String ?? self.emailAddress
                if let isPremiumValue = dictionary["isPremium"] as? NSNumber {
                    self.isPremium = Bool(isPremiumValue) ?? self.isPremium
                }
                
                if let territory = dictionary["territory"] as? String {
                    self.territory = territory != "" ? territory : self.territory 
                }
                
                self.getSettings(fetchSettingsHandler: { (settings, error) in
                    if let settings = settings {
                        self.settingValues = settings
                    } else {
                        var preferredPlayer: NusicPreferredPlayer = .youtube
                        if self.isPremium! {
                            preferredPlayer = .spotify
                        }
                        self.settingValues = NusicUserSettings(useMobileData: false, preferredPlayer: preferredPlayer)
                    }
                    
                    
                    getUserHandler(self, error);
                })
                
                
            } else {
                getUserHandler(nil, error);
            }
            
            
            
        }
    }
    
    func saveUser(saveUserHandler: @escaping (Bool?, NusicError?) -> ()) {
        saveData { (databaseReference, error) in
            if let error = error {
                saveUserHandler(false, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.saveUser.rawValue, systemError: error))
            } else {
                self.saveSettings(saveSettingsHandler: { (isSaved, error) in
                    saveUserHandler(isSaved, error)
                })
            }
        }
    }
    
    func deleteUser(deleteUserHandler: @escaping (Bool?, NusicError?) -> ()) {
        deleteData { (databaseReference, error) in
            if let error = error {
                deleteUserHandler(false, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.deleteUser.rawValue, systemError: error))
            } else {
                deleteUserHandler(true, nil)
            }
        }
    }
    
    func getFavoriteGenres(getGenresHandler: @escaping ([String: Int]?, NusicError?) -> ()) {
        let closureSelf = self;
//        reference.child("genres").child(userName).observe(.value, with: { (dataSnapshot) in
        reference.child("genres").child(userName).observeSingleEvent(of: .value, with: { (dataSnapshot) in
            let value = dataSnapshot.value as? NSDictionary
            var convertedDict: [String: Int] = [:]
            if value != nil {
                convertedDict = value as! [String: Int]
                
                var iterator = convertedDict.makeIterator()
                
                var nextElement = iterator.next();
                var genreList: [NusicGenre]? = []
                while nextElement != nil {
                    if let element = nextElement {
                        genreList?.append(NusicGenre(mainGenre: element.key, count: element.value, userName: closureSelf.userName))
                    }
                    nextElement = iterator.next()
                }
                //let extractedUsername = value?["canonicalUserName"] as? String ?? ""
                closureSelf.favoriteGenres = genreList;
            } 
            
            getGenresHandler(convertedDict, nil);
        }, withCancel: { (error) in
            getGenresHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.getFavoriteGenres.rawValue, systemError: error));
        })
    }
    
    func saveFavoriteGenres(saveGenresHandler: @escaping (Bool?, NusicError?) -> ()) {
        if let favoriteGenres = favoriteGenres {
            var dict:[String: Int] = [:]
            for genre in favoriteGenres {
                dict[genre.mainGenre] = genre.count
            }
            Database.database().reference().child("genres").child(userName).updateChildValues(dict, withCompletionBlock: { (error, reference) in
                if let error = error {
                    saveGenresHandler(false, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.saveFavoriteGenres.rawValue, systemError: error))
                } else {
                    saveGenresHandler(true, nil)
                }
            })
        }
    }
    
    func deleteFavoriteGenres(deleteGenresHandler: @escaping (Bool?, NusicError?) -> ()) {
        Database.database().reference().child("genres").child(userName).removeValue { (error, reference) in
            if let error = error {
                deleteGenresHandler(false, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.deleteFavoriteGenres.rawValue, systemError: error))
            } else {
                deleteGenresHandler(true, nil)
            }
        }
    }
    
    func updateGenreCount(for genre: String, updateGenreHandler: @escaping (Bool?, NusicError?) -> ()) {
        if favoriteGenres == nil {
            self.favoriteGenres = []
        }
        if var favoriteGenres = favoriteGenres {
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
                if let error = error {
                    updateGenreHandler(false, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.updateGenreCount.rawValue, systemError: error))
                } else {
                    updateGenreHandler(true, nil)
                }
            })
        }
    }
    
    //Settings
    //----------------
    
    func getSettings(fetchSettingsHandler: @escaping (NusicUserSettings?, NusicError?) -> ()) {
        reference.child("settings").child(userName).observeSingleEvent(of: .value, with: { (dataSnapshot) in
            let dictionary = dataSnapshot.value as? NSDictionary
            if let dictionary = dictionary {
                
                var preferredPlayer: NusicPreferredPlayer?
                var useMobileData: Bool? = true
                var spotifySettings = NusicUserSpotifySettings(bitrate: .normal)
                
                if let preferredPlayerValue = dictionary["preferredPlayer"] as? NSNumber {
                    preferredPlayer = NusicPreferredPlayer(rawValue: Int(preferredPlayerValue))
                }
                
                if let useMobileDataValue = dictionary["useMobileData"] as? NSNumber {
                    useMobileData = Bool(useMobileDataValue)
                }
                
                if let spotifyDict = dictionary["spotify"] as? NSDictionary {
                    let bitrate = spotifyDict["bitrate"] as? NSNumber
                    spotifySettings.bitrate = SPTBitrate(rawValue: UInt(bitrate!))!
                }
                
                let settings = NusicUserSettings(useMobileData: useMobileData!, preferredPlayer: preferredPlayer!, spotifySettings: spotifySettings)
                
                fetchSettingsHandler(settings, nil);
            } else {
                fetchSettingsHandler(nil, nil);
            }
        }) { (error) in
            fetchSettingsHandler(nil, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: "", systemError: error));
        }
    }
    
    func saveSettings(saveSettingsHandler: @escaping(Bool, NusicError?) -> ()) {
        let spotify = settingValues.spotifySettings?.toDictionary()
        let dictionary = ["preferredPlayer": settingValues.preferredPlayer?.rawValue,
                          "useMobileData": settingValues.useMobileData! ? 1 : 0,
                          "spotify": spotify] as [String : Any]
        
        
        reference.child("settings").child(userName).updateChildValues(dictionary) { (error, reference) in
            if let error = error {
                saveSettingsHandler(false, NusicError(nusicErrorCode: NusicErrorCodes.firebaseError, nusicErrorSubCode: NusicErrorSubCode.technicalError, nusicErrorDescription: FirebaseErrorCodeDescription.saveSettings.rawValue, systemError: error))
            } else {
                saveSettingsHandler(true, nil);
            }
            
        }
    }
    
}
