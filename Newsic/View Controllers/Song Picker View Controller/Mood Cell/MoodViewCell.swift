//
//  MoodViewCell.swift
//  Newsic
//
//  Created by Miguel Alcantara on 03/10/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

class MoodViewCell: UICollectionViewCell {
    
    @IBOutlet weak var moodLabel: UILabel!
    var borderPathLayer: CAShapeLayer?;
    var pointerPathLayer: CAShapeLayer?;
    var selectedColor: UIColor = UIColor.green.withAlphaComponent(0.2)
    var deselectedColor: UIColor = UIColor.clear
    var offsetPath: CGRect = CGRect.zero
    var offsetSelectedPoint: CGPoint = CGPoint.zero
    var leftOffset: CGFloat = 8
    
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }
    
    //Constraints
    @IBOutlet weak var labelTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelTopConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame);
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        labelTrailingConstraint.constant = 0
        labelLeadingConstraint.constant = offsetSelectedPoint.x + leftOffset * 2
        labelBottomConstraint.constant = 0
        labelTopConstraint.constant = 0
        if var sublayers = self.layer.sublayers {
            if sublayers.count > 1 {
                self.layer.sublayers?.remove(at: 0);
            }
        }
        
    }
    
    func configure(for index: Int, offsetRect: CGRect, isLastRow: Bool? = false) {
        self.backgroundColor = .clear
        self.moodLabel.textColor = UIColor.lightText
        self.moodLabel.font = UIFont(name: "Futura", size: 20)
        self.moodLabel.minimumScaleFactor = 0.1
        offsetPath = offsetRect
        
        addPointerPath(isLastRow)
        addPath(for: index)
        
        labelTrailingConstraint.constant = 0
        labelLeadingConstraint.constant = offsetSelectedPoint.x + leftOffset * 2
        labelBottomConstraint.constant = 0
        labelTopConstraint.constant = 0
        
    }
    
    func addPointerPath(_ isLastRow: Bool? = false) {
        let width = self.safeAreaLayoutGuide.layoutFrame.width
        let height = self.safeAreaLayoutGuide.layoutFrame.height
        
        let initialX:CGFloat = offsetPath.origin.x
        let initialY:CGFloat = 0
        
        let pointerPath = UIBezierPath();
        pointerPath.move(to: CGPoint(x: initialX, y: initialY));
        pointerPath.addLine(to: CGPoint(x: initialX, y: height/4))
        pointerPath.addLine(to: CGPoint(x: initialX + offsetPath.origin.x, y: height/2))
        pointerPath.addLine(to: CGPoint(x: initialX + offsetPath.origin.x * 3, y: height/2))
        
        if isLastRow! == false {
            pointerPath.move(to: CGPoint(x: initialX, y: initialY));
            pointerPath.addLine(to: CGPoint(x: initialX, y: height))
        }
        
        offsetSelectedPoint = CGPoint(x: initialX + offsetPath.origin.x * 3, y: height/2)
        
        let layer = CAShapeLayer()
        
        
        let color = UIColor(red: 255, green: 69, blue: 0, alpha: 1).cgColor
        layer.strokeColor = UIColor.green.cgColor
        layer.lineWidth = 2
        layer.fillColor = self.deselectedColor.cgColor
        layer.path = pointerPath.cgPath
        
        pointerPathLayer = layer
        if !(self.layer.sublayers?.contains(pointerPathLayer!))! {
            self.layer.insertSublayer(layer, at: 0)
        }
        
    }
    
    private func configureLabel() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = offsetSelectedPoint.x + leftOffset
        let attributes = [NSAttributedStringKey.paragraphStyle: paragraphStyle]
        
        let myMutableString = NSMutableAttributedString(
            string: self.moodLabel.text!,
            attributes: attributes)
        
        self.moodLabel.attributedText = myMutableString
    }
    //
    //    private func configureEven() {
    //
    //
    ////        moodLabel.textAlignment = .center
    ////        labelLeadingConstraint.constant = self.bounds.width/16
    ////        labelTrailingConstraint.constant = self.bounds.width * 0.25
    ////        labelTopConstraint.constant = self.moodLabel.font.lineHeight
    ////        self.contentView.layoutIfNeeded()
    //        /*
    //        print("labelLeadingConstraint.constant = \(labelLeadingConstraint.constant)")
    //        print("labelTrailingConstraint.constant = \(labelTrailingConstraint.constant)")
    //        print("labelTopConstraint.constant = \(labelTopConstraint.constant)")
    //        self.layoutIfNeeded()
    //        */
    //        let paragraphStyle = NSMutableParagraphStyle()
    //        paragraphStyle.firstLineHeadIndent = offsetSelectedPoint.x + leftOffset
    //        let attributes = [NSAttributedStringKey.paragraphStyle: paragraphStyle]
    //
    //        let myMutableString = NSMutableAttributedString(
    //            string: self.moodLabel.text!,
    //            attributes: attributes)
    //
    //        self.moodLabel.attributedText = myMutableString
    ////        self.layoutIfNeeded()
    //    }
    //
    //    private func configureOdd() {
    //
    ////        moodLabel.textAlignment = .center
    //        //        labelTrailingConstraint.constant = self.bounds.width/16
    //        //        labelLeadingConstraint.constant = self.bounds.width * 0.25
    //        //        labelBottomConstraint.constant = self.moodLabel.font.lineHeight
    //        //        self.contentView.layoutIfNeeded()
    //        /*
    //         print("labelLeadingConstraint.constant = \(labelLeadingConstraint.constant)")
    //         print("labelTrailingConstraint.constant = \(labelTrailingConstraint.constant)")
    //         print("labelBottomConstraint.constant = \(labelBottomConstraint.constant)")
    //         self.layoutIfNeeded()
    //         */
    //        let paragraphStyle = NSMutableParagraphStyle()
    //        paragraphStyle.firstLineHeadIndent = offsetSelectedPoint.x + leftOffset
    //        let attributes = [NSAttributedStringKey.paragraphStyle: paragraphStyle]
    //
    //        let myMutableString = NSMutableAttributedString(
    //            string: self.moodLabel.text!,
    //            attributes: attributes)
    //
    //        self.moodLabel.attributedText = myMutableString
    ////        self.layoutIfNeeded()
    //    }
    
    
    private func addPath(for index: Int) {
        let path = drawPath(for: index);
        let layer = CAShapeLayer()
        
        
        let color = UIColor(red: 255, green: 69, blue: 0, alpha: 1).cgColor
        layer.strokeColor = UIColor.green.cgColor
        layer.lineWidth = 2
        layer.fillColor = self.deselectedColor.cgColor
        layer.backgroundColor = self.deselectedColor.cgColor
        layer.path = path.cgPath
        
        borderPathLayer = layer
        
    }
    
    
    
    private func drawPath(for index: Int) -> UIBezierPath {
        let width = self.safeAreaLayoutGuide.layoutFrame.width
        let height = self.safeAreaLayoutGuide.layoutFrame.height
        
        let initialX:CGFloat = offsetSelectedPoint.x
        let initialY:CGFloat = 0
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: initialX, y: height/2))
        bezierPath.addLine(to: CGPoint(x: initialX + 8, y: initialY));
        bezierPath.addLine(to: CGPoint(x: width - 8, y: initialY))
        bezierPath.addLine(to: CGPoint(x: width, y: height/2))
        bezierPath.addLine(to: CGPoint(x: width - 8, y: height))
        bezierPath.addLine(to: CGPoint(x: initialX + 8, y: height))
        bezierPath.close()
        
        return bezierPath;
        
    }
    
    func setPathSelectAnimation() {
        if let borderPathLayer = borderPathLayer {
            borderPathLayer.removeAllAnimations()
            borderPathLayer.strokeColor = UIColor.green.cgColor
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = 0
            animation.duration = 0.2
            
            let flashAnimation = CABasicAnimation(keyPath: "fillColor")
            flashAnimation.fromValue = self.deselectedColor.cgColor
            flashAnimation.toValue = self.selectedColor.cgColor
            flashAnimation.duration = 0.5
            flashAnimation.autoreverses = true
            flashAnimation.repeatCount = .infinity
            
            let animationGroup = CAAnimationGroup()
            animationGroup.animations = [animation, flashAnimation]
            animationGroup.duration = .greatestFiniteMagnitude
            borderPathLayer.add(animationGroup, forKey: "myAnimation")
            
            self.layer.insertSublayer(borderPathLayer, at: 0)
        }
    }
    
    func setPathDeselectAnimation() {
        
        if let borderPathLayer = borderPathLayer {
            borderPathLayer.removeAllAnimations()
            borderPathLayer.strokeColor = self.deselectedColor.cgColor
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = 1
            animation.toValue = 0
            animation.duration = 0.5
            
            let flashAnimation = CABasicAnimation(keyPath: "fillColor")
            flashAnimation.toValue = self.deselectedColor.cgColor
            flashAnimation.duration = 0.5
            flashAnimation.autoreverses = true
            
            let animationGroup = CAAnimationGroup()
            animationGroup.animations = [animation, flashAnimation]
            animationGroup.duration = 0.5
            borderPathLayer.add(animationGroup, forKey: "myAnimation")
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            self.borderPathLayer!.removeFromSuperlayer()
        }
    }
    
    func selectCell() {
        setPathSelectAnimation()
    }
    
    func deselectCell() {
        setPathDeselectAnimation()
    }
    
}

