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
    private let sortImages = [UIImage(named: "ArtistIcon")?.withRenderingMode(.alwaysTemplate), UIImage(named: "GenreIcon")?.withRenderingMode(.alwaysTemplate), UIImage(named: "TrackIcon")?.withRenderingMode(.alwaysTemplate)]
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
    
    func configure(isMoodSelected: Bool, emotion: String?) {
        if isMoodSelected {
            self.displayName.text = "Mood: \(emotion!)"
        } else {
            self.displayName.text = "Liked in Nusic"
        }
        
        self.layer.shadowColor = UIColor.black.cgColor;
        self.layer.shadowOffset = CGSize(width: 1, height: -1);
        self.layer.shadowRadius = 3.0;
        self.layer.shadowOpacity = 1;
        
        let gradient = CAGradientLayer()
        gradient.frame.size = CGSize(width: self.bounds.width, height: 10)
        let stopColor = UIColor.white.cgColor
        let startColor = UIColor.white.cgColor
        
        gradient.colors = [stopColor,startColor]
        gradient.locations = [0.0,0.4]
        self.layer.addSublayer(gradient)
    }
    
    
    func setupView() {
        loadFromNib()
        self.frame.size = CGSize(width: 200, height: 100)
        sortElementImageView.image = sortImages[0]
        setupGestureRecognizer()
    }
    
    fileprivate func loadFromNib() {
        let contentView = UINib(nibName: self.className, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SongTableViewHeader
//        contentView.autoresizesSubviews = true
        contentView.frame.size = self.frame.size
        self.displayName = contentView.displayName
        contentView.sortElementImageView.tintColor = UIColor.gray
        self.sortElementImageView = contentView.sortElementImageView
        
        self.addSubview(contentView)
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
