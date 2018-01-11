//
//  NusicScrollView.swift
//  Nusic
//
//  Created by Miguel Alcantara on 18/12/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

class NusicScrollView: UIScrollView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIControl {
            return true
        }
        return super.touchesShouldCancel(in: view)
    }

}
