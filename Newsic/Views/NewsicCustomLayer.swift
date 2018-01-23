//
//  CustomLayer.swift
//  Nusic
//
//  Created by Miguel Alcantara on 30/11/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

class NusicCustomLayer: CALayer {
    override var zPosition: CGFloat {
        get { return 0 }
        set {}
    }
}

extension CALayer {
    func removeGradientLayer(name: String) {
        if let index = self.sublayers?.index(where: { (layer) -> Bool in
            return layer.name == name
        }) {
            let borderLayer = self.sublayers![index]
            borderLayer.removeFromSuperlayer()
        }
    }
    
    func addGradientBorder(name:String, path: CGPath, colors:[UIColor],width:CGFloat = 1) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = name
        gradientLayer.frame =  CGRect(origin: CGPoint.zero, size: self.frame.size)
        gradientLayer.startPoint = CGPoint(x: 0.3, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.3, y: 0.75)
        gradientLayer.colors = colors.map({$0.cgColor})
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = width
        shapeLayer.path = path
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = UIColor.white.cgColor
        
        gradientLayer.mask = shapeLayer
        
        self.addSublayer(gradientLayer)
        
    }
}
