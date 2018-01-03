//
//  SettingsHeader.swift
//  Newsic
//
//  Created by Miguel Alcantara on 03/01/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import UIKit

protocol SettingsHeaderDelegate: class {
    func logout()
}

class SettingsHeader: NewsicView {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    static let reuseIdentifier = "settingsHeader"
    weak var delegate: SettingsHeaderDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func loadFromNib() {
        let contentView = UINib(nibName: self.className, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SettingsHeader
        contentView.backgroundColor = NewsicDefaults.deselectedColor
        contentView.frame = self.bounds
        contentView.tag = 1
        
        contentView.profileImageView.roundImage()
        self.profileImageView = contentView.profileImageView
        self.usernameLabel = contentView.usernameLabel
        
        self.addSubview(contentView)
    }
    
    func configure(image: UIImage? = nil, imageURL: String? = nil, username: String) {
        loadFromNib()
        
        self.addBlurEffect(style: .dark, alpha: 1)
        self.usernameLabel.textColor = UIColor.lightText
        
        if image == nil && imageURL == nil {
            return;
        } else if let image = image {
            profileImageView.image = image
        } else if let imageURL = imageURL {
            profileImageView.downloadedFrom(link: imageURL, contentMode: .scaleAspectFit, roundImage: true);
        }
        
        usernameLabel.text = username
    }
    
}
