//
//  MoodViewCell.swift
//  Nusic
//
//  Created by Miguel Alcantara on 03/10/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

class MoodViewCell: UICollectionViewCell {
    
    @IBOutlet weak var moodLabel: UILabel!
    
    static let reuseIdentifier = "moodCell"
    
    var borderPathLayer: CAShapeLayer?;
    var pointerPathLayer: CAShapeLayer?;
    var selectedColor: UIColor = UIColor.green.withAlphaComponent(0.2)
    var deselectedColor: UIColor = UIColor.clear
    var offsetPath: CGRect = CGRect.zero
    var offsetSelectedPoint: CGPoint = CGPoint.zero
    var leftOffset: CGFloat = 8
    var rightOffset: CGFloat = 8
    var associatedIndex: Int = -1
    let defaultFont = UIFont(name: "Futura", size: 18);
    
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
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return layoutAttributes
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.layer.shouldRasterize = true;
        self.layer.rasterizationScale = UIScreen.main.scale
        setConstraints(for: associatedIndex);
        borderPathLayer?.removeFromSuperlayer()
        borderPathLayer = nil
        pointerPathLayer?.removeFromSuperlayer()
        pointerPathLayer = nil
    }
    
    func configure(for index: Int, offsetRect: CGRect, isLastRow: Bool? = false) {
        
//        self.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        self.associatedIndex = index;
        DispatchQueue.main.async {
            self.backgroundColor = .clear
            self.moodLabel.textColor = UIColor.lightText
            self.moodLabel.font = self.defaultFont!
//            self.moodLabel.textAlignment = self.associatedIndex % 2 == 0 ? .left : .right
            self.moodLabel.textAlignment = .center
            self.moodLabel.minimumScaleFactor = 0.1
        }
        
        offsetPath = offsetRect
        
        addPointerPath(for: index, isLastRow)
        addPath(for: index)
        setConstraints(for: index);
        
    }
    
    
    func setConstraints(for index: Int) {
        if associatedIndex % 2 == 0 {
            labelTrailingConstraint.constant = 0
            labelLeadingConstraint.constant = offsetSelectedPoint.x + leftOffset
            labelBottomConstraint.constant = 0
            labelTopConstraint.constant = 0
        } else {
            let width = self.bounds.width - offsetSelectedPoint.x + rightOffset
            labelTrailingConstraint.constant = width
            labelLeadingConstraint.constant = 0
            labelBottomConstraint.constant = 0
            labelTopConstraint.constant = 0
        }
    }
    
    func addPointerPath(for index: Int, _ isLastRow: Bool? = false) {
        if index % 2 == 0 {
            addPointerPathForEven(isLastRow)
        } else {
            addPointerPathForOdd(isLastRow)
        }
    }
    
    func addPointerPathForEven(_ isLastRow: Bool? = false) {
        let width = self.safeAreaLayoutGuide.layoutFrame.width
        let height = self.safeAreaLayoutGuide.layoutFrame.height
        
        let initialX:CGFloat = offsetPath.origin.x
        let initialY:CGFloat = 0
        
        let pointerPath = UIBezierPath();
        pointerPath.move(to: CGPoint(x: initialX, y: initialY));
        pointerPath.addLine(to: CGPoint(x: initialX, y: height/4))
        pointerPath.addLine(to: CGPoint(x: initialX + offsetPath.origin.x, y: height/2))
        pointerPath.addLine(to: CGPoint(x: initialX + offsetPath.origin.x * 2, y: height/2))
        
        if isLastRow! == false {
            pointerPath.move(to: CGPoint(x: initialX, y: initialY));
            pointerPath.addLine(to: CGPoint(x: initialX, y: height))
        }
        
        offsetSelectedPoint = CGPoint(x: initialX + offsetPath.origin.x * 2, y: height/2)
        
        let layer = CAShapeLayer()
        
        
        let color = UIColor(red: 255, green: 69, blue: 0, alpha: 1).cgColor
        layer.strokeColor = UIColor.green.cgColor
        layer.lineWidth = 2
        layer.fillColor = self.deselectedColor.cgColor
        layer.path = pointerPath.cgPath
        
        pointerPathLayer = layer
        self.layer.insertSublayer(layer, at: 0)
    }
    
    func addPointerPathForOdd(_ isLastRow: Bool? = false) {
        let width = self.safeAreaLayoutGuide.layoutFrame.width
        let height = self.safeAreaLayoutGuide.layoutFrame.height
        
        let initialX:CGFloat = width - offsetPath.origin.x
        let initialY:CGFloat = 0
        
        let pointerPath = UIBezierPath();
        pointerPath.move(to: CGPoint(x: initialX, y: initialY));
        pointerPath.addLine(to: CGPoint(x: initialX, y: height/4))
        pointerPath.addLine(to: CGPoint(x: initialX - offsetPath.origin.x, y: height/2))
        pointerPath.addLine(to: CGPoint(x: initialX - offsetPath.origin.x * 2, y: height/2))
        
        if isLastRow! == false {
            pointerPath.move(to: CGPoint(x: initialX, y: initialY));
            pointerPath.addLine(to: CGPoint(x: initialX, y: height))
        }
        
        offsetSelectedPoint = CGPoint(x: initialX - offsetPath.origin.x * 2, y: height/2)
        
        let layer = CAShapeLayer()
        
        
        let color = UIColor(red: 255, green: 69, blue: 0, alpha: 1).cgColor
        layer.strokeColor = UIColor.green.cgColor
        layer.lineWidth = 2
        layer.fillColor = self.deselectedColor.cgColor
        layer.path = pointerPath.cgPath
        
        pointerPathLayer = layer
        self.layer.insertSublayer(layer, at: 0)
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
        
        if index % 2 == 0 {
            return drawPathForEven()
        } else {
            return drawPathForOdd()
        }
        
    }
    
    private func drawPathForOdd() -> UIBezierPath {
        let width = self.safeAreaLayoutGuide.layoutFrame.width
        let height = self.safeAreaLayoutGuide.layoutFrame.height
        
        let initialX:CGFloat = offsetSelectedPoint.x
        let initialY:CGFloat = 0
        
        let bezierPath = UIBezierPath()

        bezierPath.move(to: CGPoint(x: initialX, y: height/2))
        bezierPath.addLine(to: CGPoint(x: initialX - 8, y: height))
        bezierPath.addLine(to: CGPoint(x: 0, y: height))
        bezierPath.addLine(to: CGPoint(x: 0, y: height/2))
        bezierPath.move(to: CGPoint(x: initialX, y: height/2))
        bezierPath.addLine(to: CGPoint(x: initialX - 8, y: initialY))
        bezierPath.addLine(to: CGPoint(x: 0, y: initialY));
        bezierPath.addLine(to: CGPoint(x: 0, y: height/2))
//        bezierPath.close()
        
        return bezierPath;
    }
    
    private func drawPathForEven() -> UIBezierPath {
        let width = self.safeAreaLayoutGuide.layoutFrame.width
        let height = self.safeAreaLayoutGuide.layoutFrame.height
        
        let initialX:CGFloat = offsetSelectedPoint.x
        let initialY:CGFloat = 0
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: initialX, y: height/2))
        bezierPath.addLine(to: CGPoint(x: initialX + 8, y: initialY));
        bezierPath.addLine(to: CGPoint(x: width, y: initialY))
        bezierPath.addLine(to: CGPoint(x: width, y: height/2))
        bezierPath.move(to: CGPoint(x: initialX, y: height/2))
        bezierPath.addLine(to: CGPoint(x: initialX + 8, y: height));
        bezierPath.addLine(to: CGPoint(x: width, y: height))
        bezierPath.addLine(to: CGPoint(x: width, y: height/2))
        
//        bezierPath.close()
        
        return bezierPath;
    }
    
    func setPathSelectAnimation() {
        if let borderPathLayer = borderPathLayer {
            borderPathLayer.removeAllAnimations()
            borderPathLayer.strokeColor = UIColor.green.cgColor
            let strokePathAnimation = CABasicAnimation(keyPath: "strokeEnd")
            strokePathAnimation.fromValue = 0
            strokePathAnimation.duration = 0.2
            
            let flashAnimation = CABasicAnimation(keyPath: "fillColor")
            flashAnimation.fromValue = self.deselectedColor.cgColor
            flashAnimation.toValue = self.selectedColor.cgColor
            flashAnimation.duration = 0.5
            flashAnimation.autoreverses = true
            flashAnimation.repeatCount = .infinity
            
            let strokeColorAnimation = CABasicAnimation(keyPath: "strokeColor")
            strokeColorAnimation.fromValue = self.selectedColor.cgColor
            strokeColorAnimation.toValue = UIColor.green.cgColor
            strokeColorAnimation.duration = 0.5
            strokeColorAnimation.autoreverses = true
            strokeColorAnimation.repeatCount = .infinity
            
            let animationGroup = CAAnimationGroup()
            animationGroup.animations = [strokePathAnimation, strokeColorAnimation, flashAnimation]
            animationGroup.duration = .greatestFiniteMagnitude
            borderPathLayer.add(animationGroup, forKey: "myAnimation")
            
            let width = self.moodLabel.text?.width(withConstraintedHeight: self.moodLabel.frame.height, font: defaultFont!)
            
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

