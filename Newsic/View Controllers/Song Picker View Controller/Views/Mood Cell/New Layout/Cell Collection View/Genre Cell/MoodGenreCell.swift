//
//  MoodGenreCell.swift
//  Newsic
//
//  Created by Miguel Alcantara on 29/01/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import UIKit

class MoodGenreCell: UICollectionViewCell {

    @IBOutlet weak var moodGenreLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    var imageUrlList: [String]?
    var trackList: [SpotifyTrack]?
    var imageList: [UIImage]? {
        didSet {
            DispatchQueue.main.async {
                self.setTimer()
            }
        }
    }
    var currentImageIndex: Int = 0
    var timer: Timer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.layer.shouldRasterize = true;
        self.layer.rasterizationScale = UIScreen.main.scale
        self.moodGenreLabel.text = ""
        self.backgroundImage.image = #imageLiteral(resourceName: "TransparentAppIcon")
        self.imageUrlList?.removeAll()
        self.imageList?.removeAll()
        self.currentImageIndex = 0
        self.timer?.invalidate()
        self.timer = nil
    }
    
    
    func configure(text: String) {
        DispatchQueue.main.async {
            self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            self.layer.cornerRadius = 5
            self.moodGenreLabel.backgroundColor = NusicDefaults.deselectedColor
            self.moodGenreLabel.font = NusicDefaults.font!
            self.moodGenreLabel.textColor = UIColor.lightText
            self.moodGenreLabel.text = text
            
            self.backgroundImage.contentMode = .scaleAspectFit
            
            if let imageList = self.imageList, imageList.count > 0 {
                self.setTimer()
            } else {
                self.imageList = Array()
            }
        }
    }
    
    func addImages(urlList: [String]) {
        imageUrlList = urlList
        var count = 0
        var downloadedImageList: [UIImage] = Array()
        for imageUrl in urlList {
            if let url = URL(string: imageUrl) {
                guard (UIImage(named: "TransparentAppIcon")?.downloadImage(from: url, downloadImageHandler: { (downloadedImage) in
                    if let downloadedImage = downloadedImage {
                        downloadedImageList.append(downloadedImage);
                    }
                    
                    count += 1
                    if count == urlList.count {
                        self.imageList = downloadedImageList
                    }
                })) != nil else {
                    break;
                }
            }
        }
    }
    
    @objc func cycleImages() {
        
        if currentImageIndex == imageUrlList?.count {
            currentImageIndex = 0
        }
        if let imageList = self.imageList {
                DispatchQueue.main.async {
                    UIView.transition(with: self.backgroundImage, duration: 1, options: [.transitionCrossDissolve], animations: {
                        if self.currentImageIndex < imageList.count {
                            print("\(self.moodGenreLabel.text) - assigning image for index = \(self.currentImageIndex)")
                            self.backgroundImage.image = imageList[self.currentImageIndex]
                            self.currentImageIndex += 1
                        }
                    }, completion: nil)
                }
        }
        
        
    }
    
    func setTimer() {
        self.timer?.invalidate()
        self.timer = nil
        self.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { (timer) in
            self.cycleImages()
        })
        timer?.fire()
    }

}
