//
//  FirebaseModel.swift
//  Newsic
//
//  Created by Miguel Alcantara on 07/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import FirebaseDatabase

protocol FirebaseModel {
    
    var reference: DatabaseReference! { get }
    
    func getData(getCompleteHandler: @escaping (NSDictionary?, Error?) -> ())
    func saveData(saveCompleteHandler: @escaping (DatabaseReference?, Error?) -> ())
    func deleteData(deleteCompleteHandler: @escaping (DatabaseReference?, Error?) -> ())
    
}
