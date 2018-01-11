//
//  UIButton.swift
//  Nusic
//
//  Created by Miguel Alcantara on 10/10/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    
    
    func animateClick() {
        let trans = self.transform
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: trans.a*2, y: trans.a*2);
        }, completion: nil)
        UIView.animate(withDuration: 0.1, delay: 0.1, options: .curveLinear, animations: {
            self.transform = CGAffineTransform(scaleX: trans.a, y: trans.a);
        }, completion: nil)
    }
    
    func setBackgroundColor(_ color: UIColor, for state: UIControlState) {
        
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        setBackgroundImage(colorImage, for: state)
    }
    
}
