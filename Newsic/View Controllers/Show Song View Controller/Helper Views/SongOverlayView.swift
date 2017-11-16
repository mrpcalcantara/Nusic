//
//  SongOverlayView.swift
//  Newsic
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
    
    @IBOutlet lazy var albumImage: UIImageView! = {
        [unowned self] in
        var imageView = UIImageView();
        
        return imageView
    }()
        
    @IBOutlet lazy var songTitle: UILabel! = {
        [unowned self] in
        
        var label = UILabel()
        label.font = UIFont(name: "Futura", size: 15)
        return label;
    }()
    @IBOutlet lazy var songArtist: UILabel! = {
        [unowned self] in
        
        var label = UILabel()
        label.font = UIFont(name: "Futura", size: 15)
        return label;
    }()
    
    @IBOutlet lazy var spotifyIcon: UIImageView! = {
        [unowned self] in
        
        var image = UIImageView()
        image.image = UIImage();
        return image;
        }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView() {
        //self.addSubview(videoPlayer);
        self.addSubview(albumImage);
        self.addSubview(songTitle);
        songTitle.layer.zPosition = 1;
        self.addSubview(songArtist);
        songArtist.layer.zPosition = 1;
    }
    
    func loadViewFromNib() -> UIView {
        let view: UIView = UINib(nibName: "OverlayView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
        return view
    }
    
    override var overlayState: SwipeResultDirection?  {
        didSet {
            switch overlayState {
            case .left? :
                //self.backgroundColor = UIColor.red.withAlphaComponent(0.75)
                albumImage.image = UIImage(named: songOverlaySwipedLeftImage)
                albumImage.contentMode = .scaleToFill
                albumImage.alpha = 0.7
            case .right? :
                //self.backgroundColor = UIColor.green.withAlphaComponent(0.75)
                albumImage.image = UIImage(named: songOverlaySwipedRightImage)
                albumImage.contentMode = .scaleToFill
                albumImage.alpha = 0.7
            default:
                albumImage.image = nil
            }
            
        }
    }

}
