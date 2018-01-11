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
    
//    override var bounds: CGRect {
//        didSet {
//            print("DID SET BOUNDS")
//            contentView.frame = bounds
//        }
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.layer.shouldRasterize = true;
        self.layer.rasterizationScale = UIScreen.main.scale
    }
    
//    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes)
//        -> UICollectionViewLayoutAttributes {
//            print(layoutAttributes)
//
//            var attrs = layoutAttributes
//            attrs.size = CGSize(width: <#T##CGFloat#>, height: <#T##CGFloat#>)
//            return layoutAttributes
//    }
    
    
    func setupView() {

        self.layer.cornerRadius = 15
        self.contentView.addBlurEffect(style: .dark, alpha: 1)
        self.backgroundColor = UIColor.clear
        
//        let borderLayer = CAShapeLayer()
//        borderLayer.path = UIBezierPath(roundedRect: self.frame, cornerRadius: 15).cgPath
//        borderLayer.strokeColor = NusicDefaults.greenColor.cgColor
//        borderLayer.fillColor = UIColor.clear.cgColor
////        self.layer.insertSublayer(borderLayer, at: 0)
////        self.layer.addSublayer(borderLayer)
    }
    
    func setupLabel(with text: String) {
        choiceLabel.font = NusicDefaults.font!
        choiceLabel.textAlignment = .center
        choiceLabel.textColor = NusicDefaults.greenColor
        choiceLabel.text = text
        choiceLabel.minimumScaleFactor = 0.1
    }
    
    func configure(with text: String) {
        setupLabel(with: text)
        setupView()
    }
}
