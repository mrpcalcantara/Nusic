//
//  FirebaseModel.swift
//  Nusic
//
//  Created by Miguel Alcantara on 07/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import FirebaseDatabase

protocol FirebaseModel {
    
    var reference: DatabaseReference! { get }
    
    func getData(getCompleteHandler: @escaping (NSDictionary?, NusicError?) -> ())
    func saveData(saveCompleteHandler: @escaping (DatabaseReference?, NusicError?) -> ())
    func deleteData(deleteCompleteHandler: @escaping (DatabaseReference?, NusicError?) -> ())
    
}
