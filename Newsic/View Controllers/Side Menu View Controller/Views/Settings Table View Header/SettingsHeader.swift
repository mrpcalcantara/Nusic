//
//  SettingsHeader.swift
//  Nusic
//
//  Created by Miguel Alcantara on 03/01/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import UIKit

protocol SettingsHeaderDelegate: class {
    func logout()
}

class SettingsHeader: NusicView {
    
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
        contentView.backgroundColor = NusicDefaults.deselectedColor
        contentView.frame = self.bounds
        contentView.tag = 1
        
        contentView.profileImageView.roundImage()
        self.profileImageView = contentView.profileImageView
        self.usernameLabel = contentView.usernameLabel
        
        self.addSubview(contentView)
    }
    
    func configure(image: UIImage? = nil, imageURL: String? = nil, username: String) {
        loadFromNib()
        
        self.backgroundColor = UIColor.clear
        let customBounds = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y + self.bounds.height * 0.25, width: self.bounds.width, height: self.bounds.height * 0.75)
        self.addBlurEffect(style: .dark, alpha: 0.8, customBounds: customBounds)
        self.usernameLabel.textColor = UIColor.lightText
        
        if image == nil && imageURL == nil {
            return;
        } else if let image = image {
            profileImageView.image = image
        } else if let imageURL = imageURL {
            let image = UIImage()
            if let url = URL(string: imageURL) {
                image.downloadImage(from: url, downloadImageHandler: { (image) in
                    DispatchQueue.main.async {
                        self.profileImageView.image = image
                        self.profileImageView.roundImage(border: true)
                    }
                })
            }

        }        
        usernameLabel.text = username
    }
    
}
