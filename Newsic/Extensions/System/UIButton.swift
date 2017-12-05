//
//  UIButton.swift
//  Newsic
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
    
}
