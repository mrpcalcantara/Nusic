//
//  NusicView.swift
//  Nusic
//
//  Created by Miguel Alcantara on 18/12/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

class NusicView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupNusicView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    final func setupNusicView() {
        guard let image = UIImage(named: "BackgroundPattern") else { return }
        self.backgroundColor = UIColor(patternImage: image)
    }
    
}
