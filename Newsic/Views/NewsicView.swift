//
//  NewsicView.swift
//  Newsic
//
//  Created by Miguel Alcantara on 18/12/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

class NewsicView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupNewsicView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupNewsicView() {
        if let image = UIImage(named: "BackgroundPattern") {
            self.backgroundColor = UIColor(patternImage: image)
        }
        
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
