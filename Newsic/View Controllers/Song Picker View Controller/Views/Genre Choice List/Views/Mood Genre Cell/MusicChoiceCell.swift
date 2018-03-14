//
//  MusicChoiceCell.swift
//  Nusic
//
//  Created by Miguel Alcantara on 20/12/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

class MusicChoiceCell: UICollectionViewCell {

    @IBOutlet weak var choiceLabel: UILabel!
    static let reuseIdentifier = "choiceCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.layer.shouldRasterize = true;
        self.layer.rasterizationScale = UIScreen.main.scale
    }
    
    fileprivate func setupView() {
        self.layer.cornerRadius = 15
        self.contentView.addBlurEffect(style: .dark, alpha: 1)
        self.backgroundColor = UIColor.clear
    }
    
    fileprivate func setupLabel(with text: String) {
        choiceLabel.font = NusicDefaults.font!
        choiceLabel.textAlignment = .center
        choiceLabel.textColor = NusicDefaults.foregroundThemeColor
        choiceLabel.text = text
        choiceLabel.minimumScaleFactor = 0.1
    }
    
    final func configure(with text: String) {
        setupLabel(with: text)
        setupView()
    }
}
