//
//  NusicAlertController.swift
//  Nusic
//
//  Created by Miguel Alcantara on 04/01/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import UIKit

class NusicAlertController : YBAlertController {
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override init() {
        super.init()
        setupUI()
    }
    
    convenience init(title:String?, message:String?, style: YBAlertControllerStyle) {
        self.init()
        self.title = title
        self.message = message
        self.style = style
    }
    
    final func setupUI() {
        super.overlayColor = UIColor.black.withAlphaComponent(0.9)
        
        //Title details
        super.titleFont = NusicDefaults.font
        super.titleTextColor = NusicDefaults.foregroundThemeColor
        
        //Message Details
        super.messageFont = NusicDefaults.font
        super.messageTextColor = NusicDefaults.foregroundThemeColor
        super.messageLabel.backgroundColor = NusicDefaults.blackColor
        
        //Button Details
        super.buttonFont = NusicDefaults.font
        super.buttonTextColor = NusicDefaults.foregroundThemeColor
        
        //Cancel Button Details
        super.cancelButtonFont = NusicDefaults.font
        super.cancelButtonTextColor = NusicDefaults.foregroundThemeColor
        
    }
    
    final func configure(options: [YBButton]? = nil, alertText: String? = nil) {
        guard let options = options else { return }
        self.title = alertText
        self.style = YBAlertControllerStyle.ActionSheet
        for option in options {
            self.addButton(icon: option.icon, title: option.textLabel.text!, action: option.action)
        }
    }
    
}
