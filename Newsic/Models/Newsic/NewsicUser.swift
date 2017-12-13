//
//  NewsicUser.swift
//  Newsic
//
//  Created by Miguel Alcantara on 07/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation
import FirebaseDatabase

class NewsicUser: Iterable {
    
    var userName: String
    var displayName: String
    var emailAddress: String
    var territory: String
    var profileImage: UIImage?
    var favoriteGenres: [NewsicGenre]?
    var isPremium: Bool?
    var preferredPlayer: NewsicPreferredPlayer? = .youtube
    var reference: DatabaseReference!
    
    init(userName: String, displayName: String? = "", emailAddress: String? = "", imageURL: String? = "", territory: String? = "", favoriteGenres: [NewsicGenre]? = nil, isPremium: Bool? = false, preferredPlayer: NewsicPreferredPlayer? = nil) {
        self.userName = userName;
        self.displayName = displayName!;
        self.emailAddress = emailAddress!
        self.territory = territory!;
        self.favoriteGenres = favoriteGenres;
        self.isPremium = isPremium
        if preferredPlayer != nil {
            self.preferredPlayer = preferredPlayer
        } else {
            self.preferredPlayer = isPremium! ? .spotify : .youtube
        }
        
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

extension NewsicUser: FirebaseModel {
    
    internal func getData(getCompleteHandler: @escaping (NSDictionary?, NewsicError?) -> ()) {
        reference.child("users").child(userName).observeSingleEvent(of: .value, with: { (dataSnapshot) in
            let value = dataSnapshot.value as? NSDictionary
            getCompleteHandler(value, nil);
        }) { (error) in
            getCompleteHandler(nil, NewsicError(newsicErrorCode: NewsicErrorCodes.firebaseError, newsicErrorSubCode: NewsicErrorSubCode.technicalError, newsicErrorDescription: FirebaseErrorCodeDescription.getUser.rawValue, systemError: error));
        }
        
        
    }
    
    internal func saveData(saveCompleteHandler: @escaping (DatabaseReference?, NewsicError?) -> ()) {
        let dictionary = ["canonicalUserName": userName,
                          "displayName": displayName,
                          "territory": territory,
                          "emailAddress": emailAddress,
                          "isPremium": isPremium! ? 1 : 0,
                          "preferredPlayer": preferredPlayer?.rawValue] as [String : Any]
        
        
        reference.child("users").child(userName).updateChildValues(dictionary) { (error, reference) in
            if let error = error {
                saveCompleteHandler(reference, NewsicError(newsicErrorCode: NewsicErrorCodes.firebaseError, newsicErrorSubCode: NewsicErrorSubCode.technicalError, newsicErrorDescription: FirebaseErrorCodeDescription.saveUser.rawValue, systemError: error))
            } else {
                saveCompleteHandler(reference, nil)
            }
            
        }
        //        reference.child(userName).child(self.id!).updateChildValues(dict);
    }
    
    internal func deleteData(deleteCompleteHandler: @escaping (DatabaseReference?, NewsicError?) -> ()) {
        reference.child("users").child(userName).removeValue { (error, databaseReference) in
            if let error = error {
                deleteCompleteHandler(self.reference, NewsicError(newsicErrorCode: NewsicErrorCodes.firebaseError, newsicErrorSubCode: NewsicErrorSubCode.technicalError, newsicErrorDescription: FirebaseErrorCodeDescription.deleteUser.rawValue, systemError: error))
            } else {
                deleteCompleteHandler(self.reference, nil)
            }
            
        }
    }
    
    func getUser(getUserHandler: @escaping (NewsicUser?, NewsicError?) -> ()) {
        getData { (dictionary, error) in
            if let dictionary = dictionary {
                self.userName = dictionary["canonicalUserName"] as? String ?? ""
                
                self.displayName = dictionary["displayName"] as? String ?? ""
                self.emailAddress = dictionary["emailAddress"] as? String ?? ""
                if let isPremiumValue = dictionary["isPremium"] as? NSNumber {
                    self.isPremium = Bool(isPremiumValue) ?? false
                }
                
                self.preferredPlayer = NewsicPreferredPlayer(rawValue: (dictionary["preferredPlayer"] as? Int)!) ?? NewsicPreferredPlayer.youtube
                self.territory = dictionary["territory"] as? String ?? ""
                
                getUserHandler(self, error);
            } else {
                getUserHandler(nil, error);
            }
            
            
            
        }
    }
    
    func saveUser(saveUserHandler: @escaping (Bool?, NewsicError?) -> ()) {
        saveData { (databaseReference, error) in
            if let error = error {
                saveUserHandler(false, NewsicError(newsicErrorCode: NewsicErrorCodes.firebaseError, newsicErrorSubCode: NewsicErrorSubCode.technicalError, newsicErrorDescription: FirebaseErrorCodeDescription.saveUser.rawValue, systemError: error))
            } else {
                saveUserHandler(true, nil)
            }
        }
    }
    
    func deleteUser(deleteUserHandler: @escaping (Bool?, NewsicError?) -> ()) {
        deleteData { (databaseReference, error) in
            if let error = error {
                deleteUserHandler(false, NewsicError(newsicErrorCode: NewsicErrorCodes.firebaseError, newsicErrorSubCode: NewsicErrorSubCode.technicalError, newsicErrorDescription: FirebaseErrorCodeDescription.deleteUser.rawValue, systemError: error))
            } else {
                deleteUserHandler(true, nil)
            }
        }
    }
    
    func getFavoriteGenres(getGenresHandler: @escaping ([String: Int]?, NewsicError?) -> ()) {
        let closureSelf = self;
//        reference.child("genres").child(userName).observe(.value, with: { (dataSnapshot) in
        reference.child("genres").child(userName).observeSingleEvent(of: .value, with: { (dataSnapshot) in
            let value = dataSnapshot.value as? NSDictionary
            var convertedDict: [String: Int] = [:]
            if value != nil {
                convertedDict = value as! [String: Int]
                
                var iterator = convertedDict.makeIterator()
                
                var nextElement = iterator.next();
                var genreList: [NewsicGenre]? = []
                while nextElement != nil {
                    if let element = nextElement {
                        genreList?.append(NewsicGenre(mainGenre: element.key, count: element.value, userName: closureSelf.userName))
                    }
                    nextElement = iterator.next()
                }
                //let extractedUsername = value?["canonicalUserName"] as? String ?? ""
                closureSelf.favoriteGenres = genreList;
            } 
            
            getGenresHandler(convertedDict, nil);
        }, withCancel: { (error) in
            getGenresHandler(nil, NewsicError(newsicErrorCode: NewsicErrorCodes.firebaseError, newsicErrorSubCode: NewsicErrorSubCode.technicalError, newsicErrorDescription: FirebaseErrorCodeDescription.getFavoriteGenres.rawValue, systemError: error));
        })
    }
    
    func saveFavoriteGenres(saveGenresHandler: @escaping (Bool?, NewsicError?) -> ()) {
        if let favoriteGenres = favoriteGenres {
            var dict:[String: Int] = [:]
            for genre in favoriteGenres {
                dict[genre.mainGenre] = genre.count
            }
            Database.database().reference().child("genres").child(userName).updateChildValues(dict, withCompletionBlock: { (error, reference) in
                if let error = error {
                    saveGenresHandler(false, NewsicError(newsicErrorCode: NewsicErrorCodes.firebaseError, newsicErrorSubCode: NewsicErrorSubCode.technicalError, newsicErrorDescription: FirebaseErrorCodeDescription.saveFavoriteGenres.rawValue, systemError: error))
                } else {
                    saveGenresHandler(true, nil)
                }
            })
        }
    }
    
    func deleteFavoriteGenres(deleteGenresHandler: @escaping (Bool?, NewsicError?) -> ()) {
        Database.database().reference().child("genres").child(userName).removeValue { (error, reference) in
            if let error = error {
                deleteGenresHandler(false, NewsicError(newsicErrorCode: NewsicErrorCodes.firebaseError, newsicErrorSubCode: NewsicErrorSubCode.technicalError, newsicErrorDescription: FirebaseErrorCodeDescription.deleteFavoriteGenres.rawValue, systemError: error))
            } else {
                deleteGenresHandler(true, nil)
            }
        }
    }
    
    func updateGenreCount(for genre: String, updateGenreHandler: @escaping (Bool?, NewsicError?) -> ()) {
        if let favoriteGenres = favoriteGenres {
            if let genreIndex = favoriteGenres.index(where: { (localGenre) -> Bool in
                return localGenre.mainGenre == genre
            }) {
                let localGenre = favoriteGenres[genreIndex]
                let key = reference.child("genres").child(userName)
                let updatedValue = [genre:localGenre.count+1];
//                let childUpdateValues = ["/genres/\(userName)/" : updatedValue]
                key.updateChildValues(updatedValue, withCompletionBlock: { (error, reference) in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                })
                Database.database().reference().child("genres").child(userName).updateChildValues(updatedValue, withCompletionBlock: { (error, reference) in
                    if let error = error {
                        updateGenreHandler(false, NewsicError(newsicErrorCode: NewsicErrorCodes.firebaseError, newsicErrorSubCode: NewsicErrorSubCode.technicalError, newsicErrorDescription: FirebaseErrorCodeDescription.updateGenreCount.rawValue, systemError: error))
                    } else {
                        updateGenreHandler(true, nil)
                    }
                })
            }
            
            
        }
        
    }
    
}
