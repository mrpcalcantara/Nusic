//
//  NusicButton.swift
//  Nusic
//
//  Created by Miguel Alcantara on 15/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

class NusicButton: UIButton {

    // IBInspectable properties for rounded corners and border color / width
    @IBInspectable var cornerSize: CGFloat = 0
    @IBInspectable var borderSize: CGFloat = 0
    @IBInspectable var borderColor: UIColor = UIColor.black
    @IBInspectable var borderAlpha: CGFloat = 1.0
    @IBInspectable var bezierPath: UIBezierPath = UIBezierPath()
    @IBInspectable var allowBlur: Bool = false;
    @IBInspectable var blurAlpha: CGFloat = 1.0;
    @IBInspectable var animated: Bool = false;
    //
    
    
    override func awakeFromNib() {
        //self.addTarget(self, action: #selector(handleTouch), for: .touchDown);
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        self.titleLabel?.textColor = borderColor;
        
        self.layer.masksToBounds = true
        self.layer.borderColor = borderColor.withAlphaComponent(borderAlpha).cgColor
        self.layer.borderWidth = borderSize
        self.layer.cornerRadius = cornerSize
        
        if allowBlur {
            let containerView = createBlurEffect(style: .dark, alpha: blurAlpha)
            containerView.isUserInteractionEnabled = false // Edit: so that subview simply passes the event through to the button
            self.insertSubview(containerView, belowSubview: self.titleLabel!)
            
        }
    
        if animated {
            let flashAnimation = CABasicAnimation(keyPath: "fillColor")
            flashAnimation.fromValue = NusicDefaults.deselectedColor.cgColor
            flashAnimation.toValue = NusicDefaults.foregroundThemeColor.cgColor
            flashAnimation.duration = 0.5
            flashAnimation.autoreverses = true
            flashAnimation.repeatCount = .infinity
            
            let strokeColorAnimation = CABasicAnimation(keyPath: "strokeColor")
            strokeColorAnimation.fromValue = NusicDefaults.deselectedColor.cgColor
            strokeColorAnimation.toValue = NusicDefaults.foregroundThemeColor.cgColor
            strokeColorAnimation.duration = 0.5
            strokeColorAnimation.autoreverses = true
            strokeColorAnimation.repeatCount = .infinity
            
            let animationGroup = CAAnimationGroup()
            animationGroup.animations = [strokeColorAnimation, flashAnimation]
            animationGroup.duration = .greatestFiniteMagnitude
            self.layer.add(animationGroup, forKey: "buttonAnimation")
        }
    }
    
    private func setBackgroundColor(color: UIColor, forState: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))

        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(colorImage, for: forState)
    }
    
}
