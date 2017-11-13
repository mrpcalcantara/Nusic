//
//  UIView.swift
//  Newsic
//
//  Created by Miguel Alcantara on 18/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

extension UIView {
    
    
    
    func addBlurEffect() {
        
        let blurEffect = UIBlurEffect(style: .extraLight)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.bounds
        blurView.autoresizingMask = [.flexibleHeight, .flexibleWidth];
        blurView.tag = 1
        self.addSubview(blurView)
        
    }
    
    func removeBlurEffect() {
        let subviews = self.subviews
        for view in subviews {
            if view.tag == 1 {
                view.removeFromSuperview()
                break;
            }
        }
    }
    
    func addShadow(cornerRadius: CGFloat? = 3, shadowColor: CGColor? = UIColor.lightGray.cgColor, shadowOpacity: Float? = 0.5, shadowOffset: CGSize? = CGSize(width: -2, height: -7), shadowRadius: CGFloat? = 2) {
        self.layer.cornerRadius = cornerRadius!
        self.layer.masksToBounds = false
        
        self.layer.shadowColor = shadowColor!
        self.layer.shadowOpacity = shadowOpacity!
        self.layer.shadowOffset = shadowOffset!
        self.layer.shadowRadius = shadowRadius!
        let bounds = self.layer.bounds;
        self.layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale

    }
    
    func selectAnimation() {
        UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: nil)
    }
    
    func deselectAnimation() {
        UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: nil)
    }
    
    func animateSelection() {
        
        UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: { (isCompleted) in
            UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        })
    }
}
