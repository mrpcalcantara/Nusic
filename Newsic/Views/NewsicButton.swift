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
    //
    
    
    override func awakeFromNib() {
        //self.addTarget(self, action: #selector(handleTouch), for: .touchDown);
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        // set up border and cornerRadius
        //self.layer.cornerRadius = cornerSize
        //self.layer.borderColor = borderColor.withAlphaComponent(borderAlpha).cgColor
        //self.layer.borderWidth = borderSize
        //self.layer.masksToBounds = true
        //self.titleLabel?.textColor = borderColor;
        
        //self.setBackgroundColor(color: UIColor.red, forState: .selected)
        //self.setBackgroundColor(color: UIColor.blue, forState: .normal)
        //self.titleLabel?.font = 
        /*
        // set up gradient
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = rect
        let c1 = bottomColor.colorWithAlphaComponent(bottomColorAlpha).CGColor
        let c2 = middleColor.colorWithAlphaComponent(middleColorAlpha).CGColor
        let c3 = topColor.colorWithAlphaComponent(topColorAlpha).CGColor
        gradientLayer.colors = [c3, c2, c1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        self.layer.insertSublayer(gradientLayer, atIndex: 0)
        */
        
        //Even indexes
        
        let width = self.bounds.width;
        let height = self.bounds.height;
        let initialX:CGFloat = 0
        let initialY:CGFloat = 0
        /*
        //Even indexes
        bezierPath.move(to: CGPoint(x: initialX + 16, y: initialY));
        bezierPath.addLine(to: CGPoint(x: width - 24, y: initialY))
        bezierPath.addLine(to: CGPoint(x: width - 8, y: initialY+(height*0.5)))
        bezierPath.addLine(to: CGPoint(x: width*0.5, y: initialY+(height*0.5)))
        bezierPath.addLine(to: CGPoint(x: (width*0.5) - 24, y: initialY+height))
        bezierPath.addLine(to: CGPoint(x: initialX + 16, y: initialY+height))
        bezierPath.addLine(to: CGPoint(x: initialX + 8, y: initialY+(height*0.75)))
        bezierPath.addLine(to: CGPoint(x: initialX + 8, y: initialY+(height*0.25)))
        bezierPath.close()
        */
        //Odd indexes
        self.layer.masksToBounds = true
        self.titleLabel?.textColor = borderColor;
        
        //self.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15);
        
        //self.layer.borderColor = borderColor.withAlphaComponent(borderAlpha).cgColor
        //self.layer.borderWidth = borderSize
        //self.titleLabel?.bounds = CGRect(origin: (self.titleLabel?.frame.origin)!, size: CGSize(width: width/2, height: height))
        
        bezierPath.move(to: CGPoint(x: 0, y: height*0.5));
        bezierPath.addLine(to: CGPoint(x: width*0.5, y: initialY+(height*0.5)))
        bezierPath.addLine(to: CGPoint(x: (width*0.5) + 24, y: initialY))
        bezierPath.addLine(to: CGPoint(x: width - 16, y: initialY))
        bezierPath.addLine(to: CGPoint(x: width - 8, y: height*0.25))
        bezierPath.addLine(to: CGPoint(x: width - 8, y: height*0.75))
        bezierPath.addLine(to: CGPoint(x: width - 16, y: height))
        bezierPath.addLine(to: CGPoint(x: initialX + 16, y: height))
        bezierPath.close()
        
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.green.cgColor
        layer.fillColor = UIColor.red.cgColor;
        layer.path = bezierPath.cgPath
        //self.layer.addSublayer(layer)
        //self.layer.insertSublayer(layer, at: 1);
    }
    
    func setBackgroundColor(color: UIColor, forState: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(colorImage, for: forState)
    }

    func handleTouch(button: NewsicButton, event: UIEvent) {
        if let touch = event.touches(for: button)?.first {
            let location = touch.location(in: button);
            
            if !bezierPath.contains(location) {
                button.cancelTracking(with: nil);
            }
        }
    }
    
}
