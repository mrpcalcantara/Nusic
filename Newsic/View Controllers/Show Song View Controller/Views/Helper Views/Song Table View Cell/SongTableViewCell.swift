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
    
    static let reuseIdentifier: String = "songCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configure(for track: NusicTrack) {
        self.albumImage.contentMode = .scaleAspectFit
        self.albumImage.image = track.trackInfo.thumbNail;
        self.artistLabel.text = track.trackInfo.artist.artistName;
        self.trackLabel.text = track.trackInfo.songName;
        self.backgroundColor = .clear
        self.layoutIfNeeded()
    }
}
