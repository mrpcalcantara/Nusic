//
//  NewsicUser.swift
//  Newsic
//
//  Created by Miguel Alcantara on 07/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation
import FirebaseDatabase

class NewsicUser {
    
    let userName: String
    let displayName: String
    let territory: String
    var profileImage: UIImage?
    var favoriteGenres: [NewsicGenre]?
    var reference: DatabaseReference!
    
    init(userName: String, displayName: String, imageURL: String? = "", territory: String, favoriteGenres: [NewsicGenre]? = nil) {
        self.userName = userName;
        self.displayName = displayName;
        self.territory = territory;
        //self.profileImage = profileImage;
        self.getImage(imageURL: imageURL!);
        self.favoriteGenres = favoriteGenres;
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
    
    
    internal func getData(getCompleteHandler: @escaping (NSDictionary?, Error?) -> ()) {
        reference.child("users").child(userName).observeSingleEvent(of: .value, with: { (dataSnapshot) in
            let value = dataSnapshot.value as? NSDictionary
            //let extractedUsername = value?["canonicalUserName"] as? String ?? ""
            
            getCompleteHandler(value, nil);
        })
    }
    
    internal func saveData(saveCompleteHandler: @escaping (DatabaseReference?, Error?) -> ()) {
        let dictionary = ["canonicalUserName": userName,
                          "displayName": displayName,
                          "territory": territory]
        
        reference.child("users").child(userName).updateChildValues(dictionary);
    }
    
    internal func deleteData(deleteCompleteHandler: @escaping (DatabaseReference?, Error?) -> ()) {
        reference.child("users").child(userName).removeValue { (error, databaseReference) in
            
        }
    }
    
    func getUser(getUserHandler: @escaping (String) -> ()) {
        getData { (dictionary, error) in
            let extractedUsername = dictionary?["canonicalUserName"] as? String ?? ""
            getUserHandler(extractedUsername);
        }
    }
    
    func saveUser() {
        saveData { (databaseReference, error) in
            
        }
    }
    
    func deleteUser() {
        deleteData { (databaseReference, error) in

        }
    }
    
    func getFavoriteGenres(getGenresHandler: @escaping ([String: Int]?) -> ()) {
        var closureSelf = self;
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
            
            getGenresHandler(convertedDict);
        })
    }
    
    func saveFavoriteGenres() {
        if let favoriteGenres = favoriteGenres {
            var dict:[String: Int] = [:]
            for genre in favoriteGenres {
                dict[genre.mainGenre] = genre.count
            }
            Database.database().reference().child("genres").child(userName).updateChildValues(dict)
        }
    }
    
    func updateGenreCount(for genre: String) {
        var closureSelf = self;
        if let favoriteGenres = favoriteGenres {
            if let genreIndex = favoriteGenres.index(where: { (localGenre) -> Bool in
                return localGenre.mainGenre == genre
            }) {
                let localGenre = favoriteGenres[genreIndex]
                let key = reference.child("genres").child(userName)
                let updatedValue = [genre:localGenre.count+1];
                let childUpdateValues = ["/genres/\(userName)/" : updatedValue]
                print("childUpdateValues = \(childUpdateValues)")
                Database.database().reference().child("genres").child(userName).updateChildValues(updatedValue)
            }
            
            
        }
        
    }
    
}

extension NewsicUser {
    
}
