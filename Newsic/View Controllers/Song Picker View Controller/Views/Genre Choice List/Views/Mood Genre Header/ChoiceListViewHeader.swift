//
//  CollectionViewHeader.swift
//  Nusic
//
//  Created by Miguel Alcantara on 27/11/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

protocol ChoiceListViewHeaderDelegate: class {
    func clearButtonClicked()
}

class ChoiceListViewHeader: UICollectionReusableView {

    @IBOutlet weak var sectionHeaderLabel: UILabel!
    @IBOutlet weak var clearButton: NusicButton!
    static let reuseIdentifier = "choiceViewHeader"
//    static let reuseIdentifier: String? = "choiceListViewHeader"
    
    weak var delegate: ChoiceListViewHeaderDelegate?
    
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
    
    @IBAction func clearButtonClicked(_ sender: UIButton) {
        delegate?.clearButtonClicked()
    }
    
    func setupLabel(label: String) {
        self.sectionHeaderLabel.text = label
        self.sectionHeaderLabel.textColor = NusicDefaults.foregroundThemeColor
        self.addBlurEffect(style: .dark, alpha: 0.7);
    }
    
    func setupButton() {
        clearButton.setTitle("Reset", for: .normal)
        
        clearButton.titleLabel?.adjustsFontSizeToFitWidth = true
        clearButton.titleLabel?.minimumScaleFactor = 0.1
        clearButton.tintColor = NusicDefaults.foregroundThemeColor
        clearButton.borderColor = NusicDefaults.foregroundThemeColor
    }
    
    func configure(label: String) {
        setupLabel(label: label)
        setupButton()
        
    }
}
