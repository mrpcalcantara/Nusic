//
//  CollectionViewHeader.swift
//  Newsic
//
//  Created by Miguel Alcantara on 27/11/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

class CollectionViewHeader: UICollectionReusableView {

    @IBOutlet weak var sectionHeaderLabel: UILabel!
//    @IBOutlet lazy var sectionHeaderLabel: UILabel! = {
//        [unowned self] in
//        let label = UILabel()
//        return label;
//    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(label: String) {
        self.sectionHeaderLabel.text = label
        self.sectionHeaderLabel.textColor = UIColor.green
        self.addBlurEffect(style: .dark, alpha: 1);
    }
}
