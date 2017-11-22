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
    var selectedColor: UIColor = UIColor.green.withAlphaComponent(0.2)
    var deselectedColor: UIColor = UIColor.clear
    
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
        // Initialization code
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
        labelLeadingConstraint.constant = 0
        labelBottomConstraint.constant = 0
        labelTopConstraint.constant = 0
        if var sublayers = self.layer.sublayers {
            if sublayers.count > 1 {
                self.layer.sublayers?.remove(at: 0);
            }
        }
        
    }
    
    func configure(for index: Int) {
//        print("configuring Cell for indexPath \(index)")
        self.backgroundColor = .clear
        self.moodLabel.textColor = UIColor.lightText
        self.moodLabel.font = UIFont(name: "Futura", size: 15)
        //self.tintColor = UIColor.red
        if index % 2 == 0 {
            configureEven();
        } else {
            configureOdd();
        }
        
        let path = drawPath(for: index);
        
//        self.viewWithTag(111)?.removeFromSuperview()
        
        let sublayers = self.layer.sublayers
        if sublayers != nil {
            if (sublayers?.count)! > 1 {
                var index = 0;
                
                while index < (sublayers?.count)! - 1 {
                    self.layer.sublayers![index].removeFromSuperlayer();
                    index += 1
                }
                
            }
        }
        
        let layer = CAShapeLayer()
        
        
        let color = UIColor(red: 255, green: 69, blue: 0, alpha: 1).cgColor
        layer.strokeColor = UIColor.green.cgColor
        layer.lineWidth = 2
        layer.fillColor = self.deselectedColor.cgColor
        layer.path = path.cgPath
        
//        layer.shadowPath = path.cgPath
//        layer.shadowColor = UIColor.gray.cgColor
//        layer.shadowOffset = CGSize(width: 5, height: 10)
//        layer.shadowRadius = 5
//        layer.shadowOpacity = 0.2
        
        borderPathLayer = layer
        
//        let containerEffect = UIBlurEffect(style: .dark)
//        let containerView = UIVisualEffectView(effect: containerEffect)
//        containerView.alpha = 0.25
//        containerView.frame = self.bounds
//        containerView.tag = 111 // Blur Effect view Tag
//        containerView.isUserInteractionEnabled = false // Edit: so that subview simply passes the event through to the button
//
//        self.insertSubview(containerView, aboveSubview: self.moodLabel!)
        
        //self.layer.addSublayer(layer)
        self.layer.insertSublayer(layer, at: 0)
        
        
    }
    
    func setShadow() {
        
    }
    
    private func configureEven() {
        
        
        moodLabel.textAlignment = .center
//        labelLeadingConstraint.constant = self.bounds.width/16
//        labelTrailingConstraint.constant = self.bounds.width * 0.25
//        labelTopConstraint.constant = self.moodLabel.font.lineHeight
//        self.contentView.layoutIfNeeded()
        /*
        print("labelLeadingConstraint.constant = \(labelLeadingConstraint.constant)")
        print("labelTrailingConstraint.constant = \(labelTrailingConstraint.constant)")
        print("labelTopConstraint.constant = \(labelTopConstraint.constant)")
        self.layoutIfNeeded()
        */
    }
    
    private func configureOdd() {
        
        moodLabel.textAlignment = .center
//        labelTrailingConstraint.constant = self.bounds.width/16
//        labelLeadingConstraint.constant = self.bounds.width * 0.25
//        labelBottomConstraint.constant = self.moodLabel.font.lineHeight
//        self.contentView.layoutIfNeeded()
        /*
        print("labelLeadingConstraint.constant = \(labelLeadingConstraint.constant)")
        print("labelTrailingConstraint.constant = \(labelTrailingConstraint.constant)")
        print("labelBottomConstraint.constant = \(labelBottomConstraint.constant)")
        self.layoutIfNeeded()
        */
    }
    
    private func drawPath(for index: Int) -> UIBezierPath {
        let width = self.safeAreaLayoutGuide.layoutFrame.width
        let height = self.safeAreaLayoutGuide.layoutFrame.height
        
        let initialX:CGFloat = 0
        let initialY:CGFloat = 0
        
        if index % 2 == 0 {
            return drawPathForEven(width: width, height: height)
        } else {
            return drawPathForOdd(width: width, height: height)
        }
//
//        let bezierPath = UIBezierPath()
//        bezierPath.move(to: CGPoint(x: initialX + 8, y: initialY));
//        bezierPath.addLine(to: CGPoint(x: width - 8, y: initialY))
//        bezierPath.addLine(to: CGPoint(x: width, y: initialY + 8))
//        bezierPath.addLine(to: CGPoint(x: width, y: height - 8))
//        bezierPath.addLine(to: CGPoint(x: width - 8, y: height))
//        bezierPath.addLine(to: CGPoint(x: initialX + 8, y: height))
//        bezierPath.addLine(to: CGPoint(x: initialX, y: height - 8))
//        bezierPath.addLine(to: CGPoint(x: initialX, y: initialY + 8))
//
//
//        bezierPath.close()
//
//        //return bezierPath;
//
//        return UIBezierPath(roundedRect: CGRect(origin: self.safeAreaLayoutGuide.layoutFrame.origin, size: self.safeAreaLayoutGuide.layoutFrame.size), cornerRadius: 2)
    }
    
    private func drawPathForEven(width:CGFloat, height:CGFloat) -> UIBezierPath {
        let initialWidth = width;
        let initialHeight = height
        let initialX:CGFloat = 0
        let initialY:CGFloat = height * 0.25;
        
        let bezierPath = UIBezierPath()
        
        bezierPath.move(to: CGPoint(x: width, y: 0));
        bezierPath.addLine(to: CGPoint(x: width, y: height))
        bezierPath.addLine(to: CGPoint(x: 0, y: height))
        
        return bezierPath
    }
    
    private func drawPathForOdd(width:CGFloat, height:CGFloat) -> UIBezierPath {
        let initialWidth = width;
        let initialHeight = height
        let initialX:CGFloat = 0
        let initialY:CGFloat = height * -0.25 ;
        
        let bezierPath = UIBezierPath();
        bezierPath.move(to: CGPoint(x: 0, y: 0));
        bezierPath.addLine(to: CGPoint(x: 0, y: height))
        bezierPath.addLine(to: CGPoint(x: width, y: height))
        
        return bezierPath
    }
    
    func selectCell() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.allowUserInteraction, .repeat, .autoreverse], animations: {
            self.contentView.backgroundColor = self.selectedColor
        }, completion: nil)
        
        self.animateSelection()
    }
    
    func deselectCell() {
        UIView.animate(withDuration: 0.3, animations: {
            self.contentView.backgroundColor = self.deselectedColor
        });
        self.animateSelection()
    }
    
    
    
}
