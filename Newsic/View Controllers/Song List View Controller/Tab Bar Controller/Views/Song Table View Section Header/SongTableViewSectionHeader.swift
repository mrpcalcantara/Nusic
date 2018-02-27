

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
//        loadFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//
//        loadFromNib()
    }
    
    fileprivate func loadFromNib() {
        let contentView = UINib(nibName: self.className, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SongTableViewSectionHeader
        contentView.displayName.textColor = NusicDefaults.foregroundThemeColor
        self.displayName = contentView.displayName
        contentView.background.backgroundColor = NusicDefaults.blackColor
        self.addSubview(contentView)
    }
    
    func configure(text: String) {
        self.contentView.backgroundColor = NusicDefaults.blackColor
        self.background.backgroundColor = NusicDefaults.blackColor
        self.displayName.textColor = NusicDefaults.foregroundThemeColor
        self.displayName.text = text
    }
    
}
