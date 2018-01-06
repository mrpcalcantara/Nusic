//
//  NewsicAlertController.swift
//  Newsic
//
//  Created by Miguel Alcantara on 04/01/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import UIKit

class NewsicAlertController : YBAlertController {
    
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
    
    func setupUI() {
        super.overlayColor = UIColor.black.withAlphaComponent(0.8)
        super.containerView.backgroundColor = UIColor.red
        
        //Message Details
        super.messageFont = UIFont(name: "Futura", size: 15)
        super.messageTextColor = NewsicDefaults.greenColor
        super.messageLabel.backgroundColor = NewsicDefaults.blackColor
        
        //Button Details
        super.buttonFont = UIFont(name: "Futura", size: 15)
        super.buttonTextColor = NewsicDefaults.greenColor
        
        //Cancel Button Details
        super.cancelButtonFont = UIFont(name: "Futura", size: 15)
        super.cancelButtonTextColor = NewsicDefaults.greenColor
        
    }
    
}
