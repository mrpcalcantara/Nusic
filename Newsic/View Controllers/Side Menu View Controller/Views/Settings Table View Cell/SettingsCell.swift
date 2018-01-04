//
//  SettingsCell.swift
//  Newsic
//
//  Created by Miguel Alcantara on 03/01/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import UIKit

protocol SettingsCellDelegate: class {
    func updateSettings(_ path: String)
    func showAlertController()
}

class SettingsCell: UITableViewCell {

    
    @IBOutlet weak var itemDescription: UILabel!
    @IBOutlet weak var itemValue: UILabel!
    
    static let reuseIdentifier = "settingsCell"
    static let rowHeight:CGFloat = 45
    weak var delegate: SettingsCellDelegate?
    var alertController: UIAlertController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        
        UIView.animate(withDuration: 0.3, animations: {
            if selected {
                self.backgroundColor = NewsicDefaults.greenColor.withAlphaComponent(0.5)
            } else {
                self.backgroundColor = NewsicDefaults.deselectedColor
            }
        })
        
    }
    
    func configureCell(title: String, value: String, options: [UIAlertAction]? = nil, acessoryType: UITableViewCellAccessoryType? = .none, centerText: Bool? = false, alertText: String? = nil, enableCell: Bool? = true) {
        
        
        
        self.backgroundColor = NewsicDefaults.deselectedColor
        self.accessoryType = accessoryType
        self.selectionStyle = .none
        self.addBlurEffect(style: .dark, alpha: 0.2)
        self.itemValue.textColor = UIColor.white
        self.itemDescription.textAlignment = centerText! ? .center : .natural;
        self.itemDescription.textColor = UIColor.lightText
        
        if !enableCell! {
            self.isUserInteractionEnabled = enableCell!
            self.itemValue.textColor = UIColor.gray
        }
        
        itemDescription.text = title
        itemValue.text = value
        
        if let options = options {
            alertController = UIAlertController(title: alertText != nil ? alertText! : nil, message: nil, preferredStyle: .actionSheet)
            
            alertController?.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                self.setSelected(false, animated: true)
                self.alertController?.dismiss(animated: true, completion: nil);
            }))
            
            for option in options {
                alertController?.addAction(option);
            }
            
//            alertController?.view.tintColor = NewsicDefaults.greenColor
            //WORKAROUND: Change Alert controller Background color
//            for subview in (alertController?.view.subviews.first?.subviews.first?.subviews)! {
//                subview.backgroundColor = UIColor.black.withAlphaComponent(0.9)
////                subview.addBlurEffect(style: .dark, alpha: 0.7)
//            }
            
        }
    }
    
    
    
    
}
