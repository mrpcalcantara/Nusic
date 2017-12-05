//
//  UILabel.swift
//  Newsic
//
//  Created by Miguel Alcantara on 16/11/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

extension UILabel {
    
    func animate(newText: String, characterDelay: TimeInterval) {
        let text = ["N", "Ne", "New", "News", "Newsi", "Newsic"]
        
        
        var index = 0
        
        let label = "Newsic"
//        for charIndex in label.characters.indices {
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1 * Double(index), execute: {
//                let firstPart = label.substring(to: label.index(after: charIndex))
//                let secondPart = label.substring(from: label.index(after: charIndex))
//
//                let attrs1 = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 45), NSAttributedStringKey.foregroundColor : UIColor.green]
//                let attrs2 = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 45), NSAttributedStringKey.foregroundColor : UIColor.white]
//                let attributedString1 = NSMutableAttributedString(string:firstPart, attributes:attrs1)
//                let attributedString2 = NSMutableAttributedString(string:secondPart, attributes:attrs1)
//                attributedString1.append(attributedString2)
//                self.attributedText = attributedString1
//                print(firstPart)
//            })
//            index += 1
//        }
        for line in text {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1 * Double(index), execute: {
                let attrs1 = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 45), NSAttributedStringKey.foregroundColor : UIColor.green]
                let attrs2 = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18), NSAttributedStringKey.foregroundColor : UIColor.white]
                let attributedString1 = NSMutableAttributedString(string:line, attributes:attrs1)
                //attributedString1.append(attributedString2)
                self.attributedText = attributedString1
            })
            
           index += 1
        }
        
        let animation: CATransition = CATransition()
        animation.duration = 1.0
        animation.type = kCATransitionFade
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.layer.add(animation, forKey: "changeTextTransition")
//
//        DispatchQueue.main.async {
//
//
//
//            let attrs1 = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18), NSAttributedStringKey.foregroundColor : UIColor.green]
//            let attrs2 = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18), NSAttributedStringKey.foregroundColor : UIColor.white]
//            let attributedString1 = NSMutableAttributedString(string:"Drive", attributes:attrs1)
//            let attributedString2 = NSMutableAttributedString(string:"safe", attributes:attrs2)
//
//
//            self.attributedText = attributedString1
//            attributedString1.append(attributedString2)
//            self.attributedText = attributedString1
//
//        }
    }
    
}
