//
//  UIView.swift
//  Nusic
//
//  Created by Miguel Alcantara on 18/09/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

extension UIView {
    
    final func createBlurEffect(style: UIBlurEffectStyle, alpha: CGFloat, customBounds: CGRect? = nil, inFront: Bool? = true) -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = customBounds != nil ? customBounds! : self.bounds
        blurView.autoresizingMask = [.flexibleHeight, .flexibleWidth, .flexibleLeftMargin, .flexibleRightMargin];
        blurView.tag = 111
        blurView.alpha = alpha
        return blurView
    }
    
    final func addBlurEffect(style: UIBlurEffectStyle, alpha: CGFloat, customBounds: CGRect? = nil, inFront: Bool? = true) {
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = customBounds != nil ? customBounds! : self.bounds
        blurView.autoresizingMask = [.flexibleHeight, .flexibleWidth, .flexibleLeftMargin, .flexibleRightMargin];
        blurView.tag = 111
        blurView.alpha = alpha
        _ = inFront! ? self.insertSubview(blurView, at: 0) : self.addSubview(blurView)
    }
    
    final func removeBlurEffect() {
        let subviews = self.subviews
        for view in subviews {
            if view.tag == 111 {
                view.removeFromSuperview()
                break;
            }
        }
    }
    
    final func reloadBlurEffect() {
        for view in subviews {
            if view.tag == 111 {
                view.frame.size = self.bounds.size
                break;
            }
        }
    }
    
    final func addShadow(cornerRadius: CGFloat? = 3, shadowColor: CGColor? = UIColor.clear.cgColor, shadowOpacity: Float? = 0.5, shadowOffset: CGSize? = CGSize(width: -2, height: -7), shadowRadius: CGFloat? = 2) {
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
    
    final func selectAnimation() {
        UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: nil)
    }
    
    final func deselectAnimation() {
        UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: nil)
    }
    
    final func animateSelection() {
        
        UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: { (isCompleted) in
            UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        })
    }
    
}
