//
//  SongTableViewCell.swift
//  Nusic
//
//  Created by Miguel Alcantara on 15/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

class SongTableViewCell: UITableViewCell {

    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var albumImage: UIImageView!
    
    //let override var reuseIdentifier: String? = "songCell"
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
