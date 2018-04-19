

//
//  SongTableViewSectionHeader.swift
//  Nusic
//
//  Created by Miguel Alcantara on 02/10/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

class SongTableViewSectionHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var background: UIView!
    @IBOutlet weak var displayName: UILabel!
    
    static let reuseIdentifier: String = "SongTableViewHeader"
    
    override func awakeFromNib() {
        super.awakeFromNib();
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    final func configure(text: String) {
        self.removeBlurEffect()
        self.addBlurEffect(style: .dark, alpha: 1)
        self.displayName.textColor = NusicDefaults.foregroundThemeColor
        self.displayName.text = text
    }
    
}
