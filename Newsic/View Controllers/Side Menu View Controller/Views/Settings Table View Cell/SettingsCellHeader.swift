//
//  SettingsCellHeader.swift
//  Nusic
//
//  Created by Miguel Alcantara on 03/01/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import UIKit

class SettingsCellHeader: UIView {

    @IBOutlet weak var headerLabel: UILabel!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    static let headerHeight:CGFloat = 55
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    convenience init(label: String, frame: CGRect) {
        self.init(frame: frame)
        headerLabel.text = label
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func loadFromNib() {
        let contentView = UINib(nibName: self.className, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SettingsCellHeader
        contentView.addBlurEffect(style: .dark, alpha: 0.8)
        contentView.backgroundColor = NusicDefaults.deselectedColor
        contentView.frame = self.bounds
        contentView.tag = 1
        
        contentView.headerLabel.textColor = NusicDefaults.foregroundThemeColor
    
        self.headerLabel = contentView.headerLabel
        
        self.addSubview(contentView)
    }
}
