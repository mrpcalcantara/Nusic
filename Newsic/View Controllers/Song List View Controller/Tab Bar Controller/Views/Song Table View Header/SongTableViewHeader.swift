//
//  SongTableViewHeader.swift
//  Nusic
//
//  Created by Miguel Alcantara on 02/10/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

protocol SongTableViewHeaderDelegate : class {
    func touchedHeader()
}

class SongTableViewHeader: UIView {

    @IBOutlet weak var displayName: UILabel!
    @IBOutlet weak var sortElementImageView: UIImageView!
    
    private let sortElements = [SpotifyType.artist, SpotifyType.genre, SpotifyType.track]
    private var sortImages = [UIImage(named: "ArtistIcon")?.withRenderingMode(.alwaysTemplate), UIImage(named: "GenreIcon")?.withRenderingMode(.alwaysTemplate), UIImage(named: "TrackIcon")?.withRenderingMode(.alwaysTemplate)]
    var currentSortElement: SpotifyType = SpotifyType.artist
    weak var delegate: SongTableViewHeaderDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib();
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureLikedList(isMoodSelected: Bool, emotion: String?) {
        if isMoodSelected {
            self.displayName.text = "Mood: \(emotion!)"
        } else {
            self.displayName.text = "Liked in Nusic"
        }
        
        
        
        
        
    }
    
    func configureSuggestedList() {
        setImages(images: [#imageLiteral(resourceName: "ButtonAppIcon")])
        sortElementImageView.image = sortImages[0]
        self.displayName.text = "Suggested by Nusic"
        
        self.layer.shadowColor = UIColor.black.cgColor;
        self.layer.shadowOffset = CGSize(width: 1, height: -1);
        self.layer.shadowRadius = 3.0;
        self.layer.shadowOpacity = 1;
        
    }
    
    
    func setupView() {
        loadFromNib()
        self.frame.size = CGSize(width: 200, height: 100)
        
        self.backgroundColor = NusicDefaults.blackColor.withAlphaComponent(0.5)
        self.layer.shadowColor = UIColor.black.cgColor;
        self.layer.shadowOffset = CGSize(width: 1, height: -1);
        self.layer.shadowRadius = 3.0;
        self.layer.shadowOpacity = 1;
        sortElementImageView.image = sortImages[0]
        
        setupGestureRecognizer()
    }
    
    fileprivate func loadFromNib() {
        let contentView = UINib(nibName: self.className, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SongTableViewHeader
        contentView.frame.size = self.frame.size
        contentView.displayName.textColor = NusicDefaults.foregroundThemeColor
        self.displayName = contentView.displayName
        contentView.sortElementImageView.tintColor = NusicDefaults.foregroundThemeColor
        self.sortElementImageView = contentView.sortElementImageView
        contentView.backgroundColor = .clear
        self.addSubview(contentView)
    }
    
    func setImages(images: [UIImage]) {
        self.sortImages = images
    }
    
    fileprivate func setupGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(headerTouched))
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc fileprivate func headerTouched() {
        var nextSortIndex = sortElements.index(after: sortElements.index(of: currentSortElement)!)
        if nextSortIndex >= sortElements.count {
            nextSortIndex = 0
        }
        currentSortElement = sortElements[nextSortIndex]
        sortElementImageView.image = sortImages[nextSortIndex]
        delegate?.touchedHeader()
    }
    
    
    
}
