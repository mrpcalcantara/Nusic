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
    var deselectedColor: UIColor = UIColor.white.withAlphaComponent(0.8);
    
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
        print("configuring Cell for indexPath \(index)")
        
        if index % 2 == 0 {
            configureEven();
        } else {
            configureOdd();
        }
        
        let path = drawPath(for: index);
        
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
        
        layer.strokeColor = UIColor.green.cgColor
        layer.lineWidth = 5
        layer.fillColor = deselectedColor.cgColor
        layer.path = path.cgPath
        
        layer.shadowPath = path.cgPath
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 5, height: 10)
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.2
        
        borderPathLayer = layer
        self.layer.addSublayer(layer)
        self.layer.insertSublayer(layer, at: 0)
        
        
    }
    
    func setShadow() {
        
    }
    
    private func configureEven() {
        
        
        moodLabel.textAlignment = .left
        labelLeadingConstraint.constant = self.bounds.width/16
        labelTrailingConstraint.constant = self.bounds.width * 0.25
        labelTopConstraint.constant = self.moodLabel.font.lineHeight
        self.contentView.layoutIfNeeded()
        /*
        print("labelLeadingConstraint.constant = \(labelLeadingConstraint.constant)")
        print("labelTrailingConstraint.constant = \(labelTrailingConstraint.constant)")
        print("labelTopConstraint.constant = \(labelTopConstraint.constant)")
        self.layoutIfNeeded()
        */
    }
    
    private func configureOdd() {
        
        moodLabel.textAlignment = .right
        labelTrailingConstraint.constant = self.bounds.width/16
        labelLeadingConstraint.constant = self.bounds.width * 0.25
        labelBottomConstraint.constant = self.moodLabel.font.lineHeight
        self.contentView.layoutIfNeeded()
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
        
        if index % 2 == 0 {
            return drawPathForEven(width: width, height: height)
        } else {
            return drawPathForOdd(width: width, height: height)
        }
    }
    
    private func drawPathForEven(width:CGFloat, height:CGFloat) -> UIBezierPath {
        let initialWidth = width;
        let initialHeight = height
        let initialX:CGFloat = 0
        let initialY:CGFloat = height * 0.25;
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: initialX + 16, y: initialHeight*0.25));
        bezierPath.addLine(to: CGPoint(x: initialWidth - 16, y: initialHeight*0.25))
        bezierPath.addLine(to: CGPoint(x: initialWidth - 8, y: initialHeight*0.625))
        bezierPath.addLine(to: CGPoint(x: (initialWidth*0.5) + 12, y: initialHeight*0.625))
        bezierPath.addLine(to: CGPoint(x: (initialWidth*0.5) - 12, y: initialHeight*0.875))
        bezierPath.addLine(to: CGPoint(x: initialX + 8, y: initialHeight*0.875))
        bezierPath.addLine(to: CGPoint(x: initialX + 8, y: initialHeight*0.5))
        bezierPath.close()
        
        return bezierPath
    }
    
    private func drawPathForOdd(width:CGFloat, height:CGFloat) -> UIBezierPath {
        let initialWidth = width;
        let initialHeight = height
        let initialX:CGFloat = 0
        let initialY:CGFloat = height * -0.25 ;
        
        let bezierPath = UIBezierPath();
        bezierPath.move(to: CGPoint(x: initialX + 8, y: initialHeight*0.375))
        bezierPath.addLine(to: CGPoint(x: (initialWidth*0.5) - 12, y: initialHeight*0.375))
        bezierPath.addLine(to: CGPoint(x: (initialWidth*0.5) + 12, y: initialHeight*0.125))
        bezierPath.addLine(to: CGPoint(x: initialWidth - 8, y: initialHeight*0.125))
        bezierPath.addLine(to: CGPoint(x: initialWidth - 8, y: initialHeight*0.5))
        bezierPath.addLine(to: CGPoint(x: initialWidth - 16, y: initialHeight*0.75))
        bezierPath.addLine(to: CGPoint(x: initialX + 16, y: initialHeight*0.75))
        bezierPath.close()
        
        return bezierPath
    }
    
    func selectCell() {
        UIView.animate(withDuration: 0.3, animations: {
            DispatchQueue.main.async {
                if self.layer.sublayers!.contains(self.borderPathLayer!) {
                    let pathSublayer = self.layer.sublayers!.first as! CAShapeLayer
                    pathSublayer.fillColor = self.selectedColor.cgColor
                    //self.backgroundColor = self.selectedColor
                }
            }
        });
        self.animateSelection()
    }
    
    func deselectCell() {
        UIView.animate(withDuration: 0.3, animations: {
            DispatchQueue.main.async {
                if self.layer.sublayers!.contains(self.borderPathLayer!) {
                    let pathSublayer = self.layer.sublayers!.first as! CAShapeLayer
                    pathSublayer.fillColor = self.deselectedColor.cgColor
                    //self.backgroundColor = self.deselectedColor
                }
            }
        });
        self.animateSelection()
    }
    
    
    
}
