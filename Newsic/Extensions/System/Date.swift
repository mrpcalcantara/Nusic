//
//  Date.swift
//  Nusic
//
//  Created by Miguel Alcantara on 07/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation

extension Date {
    
    func toString(dateFormat: String? = "yyyyMMdd") -> String {
        let formatter = DateFormatter();
        formatter.dateFormat = dateFormat!
        return formatter.string(from: self)
    }
    
    func fromString(dateString: String, dateFormat: String? = "yyyyMMdd") -> Date {
        let formatter = DateFormatter();
        formatter.dateFormat = dateFormat!
        return formatter.date(from: dateString)!;
    }
}
