//
//  MoodGenreCell.swift
//  Newsic
//
//  Created by Miguel Alcantara on 29/01/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import UIKit

class MoodGenreCell: UICollectionViewCell {

    @IBOutlet weak var moodGenreLabel: UILabel!
    @IBOutlet weak var moodGenreIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.layer.shouldRasterize = true;
        self.layer.rasterizationScale = UIScreen.main.scale
        self.moodGenreLabel.text = ""
        self.moodGenreIcon.image = nil
    }
    
    func configure(text: String) {
        DispatchQueue.main.async {
//            self.removeBlurEffect()
//            self.addBlurEffect(style: .dark, alpha: 0.5, inFront: true)
            self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            self.layer.borderWidth = 2
            self.layer.borderColor = NusicDefaults.greenColor.withAlphaComponent(0.5).cgColor
            self.layer.cornerRadius = 5
            self.moodGenreLabel.backgroundColor = NusicDefaults.deselectedColor
            self.moodGenreLabel.font = NusicDefaults.font!
            self.moodGenreLabel.textColor = UIColor.lightText
            self.moodGenreLabel.text = text
            
            self.moodGenreIcon.contentMode = .scaleAspectFit
            
            if let image = UIImage(named: text) {
                self.moodGenreIcon.image = image
            }
            
        }

    }

}
