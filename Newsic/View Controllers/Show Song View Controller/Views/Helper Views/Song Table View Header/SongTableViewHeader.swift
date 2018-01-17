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
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func loadFromNib() {
        let contentView = UINib(nibName: self.className, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SongTableViewHeader
//        contentView.autoresizesSubviews = true
        contentView.frame.size = self.frame.size
        self.displayName = contentView.displayName
        contentView.sortElementImageView.tintColor = UIColor.gray
        self.sortElementImageView = contentView.sortElementImageView
        
        self.addSubview(contentView)
    }
    
    func setupView() {
        loadFromNib()
        self.frame.size = CGSize(width: 200, height: 100)
        sortElementImageView.image = sortImages[0]
        setupGestureRecognizer()
    }
    
    func setupGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(headerTouched))
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func headerTouched() {
        var nextSortIndex = sortElements.index(after: sortElements.index(of: currentSortElement)!)
        if nextSortIndex >= sortElements.count {
            nextSortIndex = 0
        }
        currentSortElement = sortElements[nextSortIndex]
        sortElementImageView.image = sortImages[nextSortIndex]
        delegate?.touchedHeader()
    }
    
    
    
}
