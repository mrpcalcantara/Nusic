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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    static let reuseIdentifier: String = "moodGenreCell"
    
    //View
    var currentImageIndex: Int = 0
    let cornerRadius:CGFloat = 5
    let deselectedLabelColor: UIColor = UIColor.lightText
    let selectedLabelColor: UIColor = UIColor.white
    let highlightedAlpha: CGFloat = 1
    let unhighlightedAlpha: CGFloat = 0.4
    var borderPathLayer: CAShapeLayer?
    var imageUrlList: [String]?
    var imageList: [UIImage]? {
        didSet {
            DispatchQueue.main.async {
                self.setTimer()
            }
        }
    }
    
    //Data
    var trackList: [SpotifyTrack]?
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
        self.backgroundImage.alpha = self.unhighlightedAlpha
        self.imageUrlList = nil
        self.imageList = nil
        self.currentImageIndex = 0
        self.deselectCell()
        self.borderPathLayer = nil
        self.timer?.invalidate()
        self.timer = nil
        self.activityIndicator.stopAnimating()
    }
    
    final func configure(text: String) {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.setupBorderLayer()
        self.layer.cornerRadius = self.cornerRadius
        self.moodGenreLabel.backgroundColor = NusicDefaults.deselectedColor
        self.moodGenreLabel.font = NusicDefaults.font!
        self.moodGenreLabel.textColor = self.deselectedLabelColor
        self.moodGenreLabel.text = text
        
        self.backgroundImage.contentMode = .scaleAspectFit
        self.backgroundImage.alpha = self.unhighlightedAlpha
        
        self.activityIndicator.hidesWhenStopped = true
        self.imageList = self.imageList != nil ? self.imageList : Array();
        guard let imageList = self.imageList, imageList.count > 0 else {
            return;
        }
        self.backgroundImage.image = imageList[self.currentImageIndex]
        self.setTimer()
        DispatchQueue.main.async {
            
        }
    }
    
    final func addImages(urlList: [String]) {
        imageUrlList = Array(urlList.prefix(2))
        let dispatchGroup = DispatchGroup()
        var downloadedImageList: [UIImage] = Array()
        for imageUrl in imageUrlList! {
            dispatchGroup.enter()
            if let url = URL(string: imageUrl) {
                guard (UIImage(named: "TransparentAppIcon")?.downloadImage(from: url, downloadImageHandler: { (downloadedImage) in
                    guard let downloadedImage = downloadedImage else { dispatchGroup.leave(); return; }
                        downloadedImageList.append(downloadedImage);
                    dispatchGroup.leave()
                })) != nil else {
                    return
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.imageList = downloadedImageList
        }
    }
    
    final func selectCell() {
        setPathSelectAnimation()
        
    }
    
    final func deselectCell() {
        setPathDeselectAnimation()
    }
    
    fileprivate func setupBorderLayer() {
        let path = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius)
        let layer = CAShapeLayer()
        layer.strokeColor = NusicDefaults.foregroundThemeColor.cgColor
        layer.lineWidth = 2
        layer.fillColor = NusicDefaults.deselectedColor.cgColor
        layer.backgroundColor = NusicDefaults.deselectedColor.cgColor
        layer.path = path.cgPath
        
        borderPathLayer = layer
    }
    
    @objc fileprivate func cycleImages() {
        if self.activityIndicator.isAnimating {
            self.activityIndicator.stopAnimating()
        }
        if currentImageIndex == imageUrlList?.count {
            currentImageIndex = 0
        }
        guard let imageList = self.imageList else { return; }
        DispatchQueue.main.async {
            
            UIView.transition(with: self.backgroundImage, duration: 1, options: [.transitionCrossDissolve], animations: {
                guard self.currentImageIndex < imageList.count else { return; }
                self.backgroundImage.image = imageList[self.currentImageIndex]
                self.currentImageIndex += 1
            }, completion: { (isCompleted) in
                
            })
        }
    }
    
    fileprivate func setTimer() {
        self.timer?.invalidate()
        self.timer = nil
        self.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { (timer) in
            self.cycleImages()
        })
        timer?.fire()
    }
    
    fileprivate func setPathSelectAnimation() {
        self.moodGenreLabel.textColor = selectedLabelColor
        guard let borderPathLayer = borderPathLayer else { return; }
        borderPathLayer.removeAllAnimations()
        borderPathLayer.strokeColor = NusicDefaults.foregroundThemeColor.cgColor
        let strokePathAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokePathAnimation.fromValue = 0
        strokePathAnimation.duration = 0.2
        
        let flashAnimation = CABasicAnimation(keyPath: "fillColor")
        flashAnimation.fromValue = NusicDefaults.deselectedColor.cgColor
        flashAnimation.toValue = NusicDefaults.selectedColor.withAlphaComponent(0.5).cgColor
        flashAnimation.duration = 0.5
        flashAnimation.autoreverses = true
        flashAnimation.repeatCount = .infinity
        
        let strokeColorAnimation = CABasicAnimation(keyPath: "strokeColor")
        strokeColorAnimation.fromValue = NusicDefaults.selectedColor.cgColor
        strokeColorAnimation.toValue = NusicDefaults.foregroundThemeColor.cgColor
        strokeColorAnimation.duration = 0.5
        strokeColorAnimation.autoreverses = true
        strokeColorAnimation.repeatCount = .infinity
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [strokePathAnimation, strokeColorAnimation, flashAnimation]
        animationGroup.duration = .greatestFiniteMagnitude
        borderPathLayer.add(animationGroup, forKey: "myAnimation")
        
        self.layer.addSublayer(borderPathLayer)
        
    }
    
    fileprivate func setPathDeselectAnimation() {
        self.moodGenreLabel.textColor = deselectedLabelColor
        guard let borderPathLayer = borderPathLayer else { return; }
        borderPathLayer.removeAllAnimations()
        borderPathLayer.strokeColor = NusicDefaults.deselectedColor.cgColor
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 1
        animation.toValue = 0
        animation.duration = 0.5
        
        let flashAnimation = CABasicAnimation(keyPath: "fillColor")
        flashAnimation.toValue = NusicDefaults.deselectedColor.cgColor
        flashAnimation.duration = 0.5
        flashAnimation.autoreverses = true
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [animation, flashAnimation]
        animationGroup.duration = 0.5
        borderPathLayer.add(animationGroup, forKey: "myAnimation")
        borderPathLayer.removeFromSuperlayer()
    }

    final func animateHighlightedCell(isHighlighted: Bool) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
            self.moodGenreLabel.alpha = isHighlighted ? 0 : 1
            self.backgroundImage.alpha = isHighlighted ? self.highlightedAlpha : self.unhighlightedAlpha
        }, completion: nil)
    }
}
