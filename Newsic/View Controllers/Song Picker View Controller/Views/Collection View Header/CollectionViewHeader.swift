//
//  CollectionViewHeader.swift
//  Nusic
//
//  Created by Miguel Alcantara on 27/11/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

class CollectionViewHeader: UICollectionReusableView {

    @IBOutlet weak var sectionHeaderLabel: UILabel!
    
    static let reuseIdentifier = "collectionViewHeader"
    
    override class var layerClass: AnyClass {
        get { return NusicCustomLayer.self }
    }
    
    override func prepareForReuse() {
        self.removeBlurEffect()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(label: String) {
        self.sectionHeaderLabel.text = label
        self.sectionHeaderLabel.textColor = NusicDefaults.greenColor
        self.addBlurEffect(style: .dark, alpha: 1);
    }
}
