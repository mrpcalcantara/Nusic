//
//  Date.swift
//  Newsic
//
//  Created by Miguel Alcantara on 07/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation

extension Date {
    
    func toString() -> String {
        let formatter = DateFormatter();
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: self)
    }
    
    func fromString(dateString: String) -> Date {
        let formatter = DateFormatter();
        formatter.dateFormat = "yyyyMMdd"
        return formatter.date(from: dateString)!;
    }
}
