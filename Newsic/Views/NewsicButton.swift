//
//  NewsicButton.swift
//  Newsic
//
//  Created by Miguel Alcantara on 15/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

class NewsicButton: UIButton {

    // IBInspectable properties for rounded corners and border color / width
    @IBInspectable var cornerSize: CGFloat = 0
    @IBInspectable var borderSize: CGFloat = 0
    @IBInspectable var borderColor: UIColor = UIColor.black
    @IBInspectable var borderAlpha: CGFloat = 1.0
    @IBInspectable var bezierPath: UIBezierPath = UIBezierPath()
    @IBInspectable var allowBlur: Bool = false;
    //
    
    
    override func awakeFromNib() {
        //self.addTarget(self, action: #selector(handleTouch), for: .touchDown);
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        let width = self.bounds.width;
        let height = self.bounds.height;
        let initialX:CGFloat = 0
        let initialY:CGFloat = 0
        
        self.layer.masksToBounds = true
        self.titleLabel?.textColor = borderColor;
        
        //self.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15);
        
        //self.layer.borderColor = borderColor.withAlphaComponent(borderAlpha).cgColor
        //self.layer.borderWidth = borderSize
        
        if allowBlur {
            let containerEffect = UIBlurEffect(style: .dark)
            let containerView = UIVisualEffectView(effect: containerEffect)
            containerView.alpha = 0.75
            containerView.frame = self.bounds
            
            containerView.isUserInteractionEnabled = false // Edit: so that subview simply passes the event through to the button
            
            self.insertSubview(containerView, belowSubview: self.titleLabel!)
        }
        

//        let vibrancy = UIVibrancyEffect(blurEffect: containerEffect)
//        let vibrancyView = UIVisualEffectView(effect: vibrancy)
//        vibrancyView.frame = containerView.bounds
//        containerView.contentView.addSubview(vibrancyView)
//
//        vibrancyView.contentView.addSubview(self.titleLabel!)
//
//        blurEffectView.insertSubview(vibrancyEffectView, at: 0)
        
    }
    
    func setBackgroundColor(color: UIColor, forState: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))

        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(colorImage, for: forState)
    }

//    func handleTouch(button: NewsicButton, event: UIEvent) {
//        if let touch = event.touches(for: button)?.first {
//            let location = touch.location(in: button);
//
//            if !bezierPath.contains(location) {
//                button.cancelTracking(with: nil);
//            }
//        }
//    }
    
}
