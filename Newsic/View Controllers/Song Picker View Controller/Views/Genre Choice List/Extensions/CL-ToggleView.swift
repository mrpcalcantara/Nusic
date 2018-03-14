//
//  CL-ToggleView.swift
//  Nusic
//
//  Created by Miguel Alcantara on 20/12/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation

extension ChoiceListView {
    
    final func setupToggleView() {
        toggleView.backgroundColor = UIColor.clear
        
        var containsBlurEffect = false
        for toggleViewSubview in toggleView.subviews {
            if toggleViewSubview.tag == 1 {
                containsBlurEffect = true
                break;
            }
        }
        
        if !containsBlurEffect {
            toggleView.addBlurEffect(style: .dark, alpha: 0.7)
        }
        
        toggleViewHeight = toggleView.frame.height
        setupArrow()
        
        setupOpenBezierPaths()
    }
    
    final func manageToggleView() {
        toggleArrow()
        toggleBezierPaths()
    }
    
    final func setupArrow() {
        if toggleView.subviews.contains(arrowImageView) {
            arrowImageView.removeFromSuperview()
        }
        let image = UIImage(named: "Arrow")?.withRenderingMode(.alwaysTemplate)
        arrowImageView = UIImageView(frame: CGRect(x: toggleView.bounds.origin.x, y: toggleView.bounds.origin.y, width: self.bounds.width, height: toggleViewHeight))
        arrowImageView.image = image!
        arrowImageView.contentMode = .scaleAspectFit
        arrowImageView.tintColor = NusicDefaults.foregroundThemeColor
        toggleView.addSubview(arrowImageView)
        showOpenArrow()
    }
    
    final func toggleArrow() {
//        setupArrow()
        if isOpen {
            showCloseArrow()
        } else {
            showOpenArrow()
        }
    }
    
    final func removeBezierPaths() {
        leftLayer.removeFromSuperlayer()
        rightLayer.removeFromSuperlayer()
    }
    
    final func toggleBezierPaths() {
        removeBezierPaths()
        if isOpen {
            setupCloseBezierPaths()
        } else {
            setupOpenBezierPaths()
        }
    }
    
    fileprivate func setupOpenBezierPaths() {
        var initialX:CGFloat = 8
        let initialY:CGFloat = 0
        
        let leftPath = UIBezierPath();
        let endpointLeft = self.frame.width/2 - (arrowImageView.image?.size.width)!
        leftPath.move(to: CGPoint(x: initialX, y: initialY))
        leftPath.addLine(to: CGPoint(x: initialX, y: toggleView.bounds.height/4))
        let radius = toggleView.bounds.height/2 - toggleView.bounds.height/4
        leftPath.addArc(withCenter: CGPoint(x: initialX + radius, y: toggleView.bounds.height/4), radius: radius, startAngle: .pi, endAngle: .pi*0.5, clockwise: false)
        leftPath.addLine(to: CGPoint(x: endpointLeft, y: toggleView.bounds.height/2))
        
        leftLayer = CAShapeLayer()
        leftLayer.path = leftPath.cgPath
        leftLayer.fillColor = UIColor.clear.cgColor
        leftLayer.strokeColor = NusicDefaults.foregroundThemeColor.cgColor
        leftLayer.lineWidth = lineWidth
        
        self.layer.addSublayer(leftLayer)
        
        initialX = self.frame.width - 8
        
        let rightPath = UIBezierPath();
        let endpointRight = self.frame.width/2 + (arrowImageView.image?.size.width)!
        rightPath.move(to: CGPoint(x: initialX, y: 0))
        rightPath.addLine(to: CGPoint(x: initialX, y: toggleView.bounds.height/4))
//        rightPath.addLine(to: CGPoint(x: initialX-8, y: toggleView.bounds.height/2))
        
        rightPath.addArc(withCenter: CGPoint(x: initialX - radius, y: toggleView.bounds.height/4), radius: radius, startAngle: 0, endAngle: .pi*0.5, clockwise: true)
        rightPath.addLine(to: CGPoint(x: endpointRight, y: toggleView.bounds.height/2))
        
        rightLayer = CAShapeLayer()
        rightLayer.path = rightPath.cgPath
        rightLayer.fillColor = UIColor.clear.cgColor
        rightLayer.strokeColor = NusicDefaults.foregroundThemeColor.cgColor
        rightLayer.lineWidth = lineWidth
        
        self.layer.addSublayer(rightLayer)
    }
    
    fileprivate func setupCloseBezierPaths() {
        var initialX:CGFloat = 8
        let initialY:CGFloat = toggleView.bounds.height
        
        let leftPath = UIBezierPath();
        let endpointLeft = self.frame.width/2 - (arrowImageView.image?.size.width)!
        leftPath.move(to: CGPoint(x: initialX, y: initialY))
        leftPath.addLine(to: CGPoint(x: initialX, y: initialY-toggleView.bounds.height/4))
        let radius = toggleView.bounds.height/2 - toggleView.bounds.height/4
        leftPath.addArc(withCenter: CGPoint(x: initialX + radius, y: 3*toggleView.bounds.height/4), radius: radius, startAngle: .pi, endAngle: .pi*1.5, clockwise: true)
        leftPath.addLine(to: CGPoint(x: endpointLeft, y: toggleView.bounds.height/2))
        
        leftLayer = CAShapeLayer()
        leftLayer.path = leftPath.cgPath
        leftLayer.fillColor = UIColor.clear.cgColor
        leftLayer.strokeColor = NusicDefaults.foregroundThemeColor.cgColor
        leftLayer.lineWidth = lineWidth
        
        self.layer.addSublayer(leftLayer)
        
        initialX = self.frame.width - 8
        
        let rightPath = UIBezierPath();
        let endpointRight = self.frame.width/2 + (arrowImageView.image?.size.width)!
        rightPath.move(to: CGPoint(x: initialX, y: initialY))
        rightPath.addLine(to: CGPoint(x: initialX, y: initialY-toggleView.bounds.height/4))
        rightPath.addArc(withCenter: CGPoint(x: initialX - radius, y: 3*toggleView.bounds.height/4), radius: radius, startAngle: 0, endAngle: .pi*1.5, clockwise: false)
        rightPath.addLine(to: CGPoint(x: endpointRight, y: toggleView.bounds.height/2))
        
        rightLayer = CAShapeLayer()
        rightLayer.path = rightPath.cgPath
        rightLayer.fillColor = UIColor.clear.cgColor
        rightLayer.strokeColor = NusicDefaults.foregroundThemeColor.cgColor
        rightLayer.lineWidth = lineWidth
        
        self.layer.addSublayer(rightLayer)
    }
    
    fileprivate func showOpenArrow() {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            self.arrowImageView.transform = CGAffineTransform(rotationAngle: .pi)
        }, completion: nil)
    }
    
    fileprivate func showCloseArrow() {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            self.arrowImageView.transform = CGAffineTransform.identity
        }, completion: nil)
        
    }
    
}
