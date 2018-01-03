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
    weak var delegate: SettingsCellDelegate?
    private var alertController: UIAlertController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        
//        print("isSelected")
//        if let alertController = alertController {
//            alertController.present(alertController, animated: true, completion: nil)
//        }
        delegate?.showAlertController()
    }
    
    func configureCell(title: String, value: String, options: [UIAlertAction]? = nil, acessoryType: UITableViewCellAccessoryType? = .none) {
        self.backgroundColor = NewsicDefaults.deselectedColor
        self.accessoryType = accessoryType
        
        self.itemValue.textColor = UIColor.white
        self.itemDescription.textColor = UIColor.lightText
        
        itemDescription.text = title
        itemValue.text = value
        
        if let options = options {
            alertController = UIAlertController(title: "title", message: nil, preferredStyle: .actionSheet)
            for option in options {
                alertController?.addAction(option);
            }
        }
    }
    
    
    
}
