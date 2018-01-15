//
//  SongOverlayView.swift
//  Nusic
//
//  Created by Miguel Alcantara on 29/08/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit
import Koloda
import youtube_ios_player_helper

class SongOverlayView: OverlayView {
    
    private let songOverlaySwipedLeftImage = "SongOverlaySwipedLeft"
    private let songOverlaySwipedRightImage = "SongOverlaySwipedRight"
    
    @IBOutlet lazy var swipeImage: UIImageView! = {
        [unowned self] in
        var imageView = UIImageView();
        
        return imageView
        }()
    
    @IBOutlet lazy var youtubePlayer: YTPlayerView! = {
        [unowned self] in
        var playerView = YTPlayerView()
        
        return playerView
    }()
    
    @IBOutlet lazy var albumImage: UIImageView! = {
        [unowned self] in
        var imageView = UIImageView();
        
        return imageView
    }()
        
    @IBOutlet lazy var songTitle: UILabel! = {
        [unowned self] in
        
        var label = UILabel()
        label.backgroundColor = UIColor.clear
        label.font = UIFont(name: "Futura", size: 15)
        return label;
    }()
    @IBOutlet lazy var songArtist: UILabel! = {
        [unowned self] in
        
        var label = UILabel()
        label.backgroundColor = UIColor.clear
        label.font = UIFont(name: "Futura", size: 15)
        return label;
    }()
    
    @IBOutlet lazy var genreLabel: UILabel! = {
        [unowned self] in
        
        var label = UILabel()
        label.backgroundColor = UIColor.clear
        label.font = UIFont(name: "Futura", size: 10)
        return label;
        }()
    
    @IBOutlet lazy var clickIcon: UIImageView! = {
        [unowned self] in
        
        var imageView = UIImageView()
//        imageView.image = UIImage(named: "Click")
        return imageView
    }()
    
    override var overlayState: SwipeResultDirection?  {
        didSet {
            switch overlayState {
                
            case .left? :
                albumImage.image = UIImage(named: songOverlaySwipedLeftImage)
                albumImage.contentMode = .scaleToFill
                albumImage.alpha = 1
            case .right? :
                albumImage.image = UIImage(named: songOverlaySwipedRightImage)
                albumImage.contentMode = .scaleToFill
                albumImage.alpha = 1
            default:
                albumImage.image = nil
            }
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView() {
        
        self.addSubview(songTitle);
        songTitle.layer.zPosition = 1;
        self.addSubview(songArtist);
        songArtist.layer.zPosition = 1;
        self.addSubview(albumImage);
        self.addSubview(genreLabel);
        genreLabel.layer.zPosition = 1;
        genreLabel.alpha = 0.5
        youtubePlayer.tag = 123
        self.addSubview(youtubePlayer);
        
        
        self.layer.cornerRadius = 15
        
    }
    
    func setupViewForSpotify() {
        self.youtubePlayer.alpha = 0
//        self.layoutIfNeeded()
    }
    
    func setupViewForYoutube() {
        self.albumImage.alpha = 0
    }
    
    func loadViewFromNib() -> UIView {
        let view: UIView = UINib(nibName: "OverlayView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
        return view
    }
    
    override func update(progress: CGFloat) {
        alpha = progress < 0.75 ? progress : 0.75
        
        backgroundColor = UIColor.clear
    }

}
