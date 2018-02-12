//
//  NusicSegmentedControl.swift
//  Nusic
//
//  Created by Miguel Alcantara on 05/10/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

public protocol NusicSegmentedControlDelegate: class {
    func didSelect(_ segmentIndex: Int)
    func didMove(_ control: UIControl, _ progress: CGFloat, _ toIndex: Int)
}


class NusicSegmentedControl: UIControl {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
    }
    */
    
    override var intrinsicContentSize: CGSize {
        return UILayoutFittingExpandedSize
    }
    
    private var lastSetPoint: CGPoint? = CGPoint.zero
    private var labels = [UIImageView]()
    private var correction: CGFloat = 0
    private var thumbView = UIView()
    open weak var delegate: NusicSegmentedControlDelegate?
    
    var items: [UIImage] = [UIImage(named: "MoodIcon")!.withRenderingMode(.alwaysTemplate), UIImage(named: "MusicNote")!.withRenderingMode(.alwaysTemplate)] {
        didSet {
            setupLabels()
        }
    }
    
    var selectedIndex : Int = 0 {
        didSet {
            displayNewSelectedIndex()
        }
    }
    
    @IBInspectable var selectedLabelColor : UIColor = NusicDefaults.foregroundThemeColor {
        didSet {
            setSelectedColors()
        }
    }
    
    @IBInspectable var unselectedLabelColor : UIColor = UIColor.clear {
        didSet {
            setSelectedColors()
        }
    }
    
    @IBInspectable var thumbColor : UIColor = NusicDefaults.foregroundThemeColor {
        didSet {
            setSelectedColors()
        }
    }
    
    @IBInspectable var borderColor : UIColor = NusicDefaults.foregroundThemeColor {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var font : UIFont! = UIFont.systemFont(ofSize: 12) {
        didSet {
            setFont()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setupView(){
        
//        let containerEffect = UIBlurEffect(style: .dark)
//        let containerView = UIVisualEffectView(effect: containerEffect)
//        containerView.alpha = 0.9
//        containerView.frame = self.bounds
//
//        containerView.isUserInteractionEnabled = false // Edit: so that subview simply passes the event through to the button
//
//        self.insertSubview(containerView, at: 0)
//
//        layer.cornerRadius = frame.height / 2
        layer.cornerRadius = 22
//        layer.borderColor = UIColor(white: 1.0, alpha: 0.5).cgColor
        layer.borderWidth = 1
        
        backgroundColor = UIColor.clear
        
        setupLabels()
        
        addIndividualItemConstraints(items: labels, mainView: self, padding: 0)
        insertSubview(thumbView, at: 0)
        addTapGesture()
        addDragGesture()
    }
    
    func setupLabels(){
        
        for label in labels {
            label.removeFromSuperview()
        }
        
        labels.removeAll(keepingCapacity: true)
        
        for index in 1...items.count {
            
            let frame = CGRect(x: 0, y: 0, width: self.bounds.height - 5, height: self.bounds.height - 5);
            let label = UIImageView(frame: frame)
            label.contentMode = .center
            //label.clipsToBounds = true;
            label.image = items[index - 1]
            label.backgroundColor = UIColor.clear;
            label.tintColor = UIColor.white
            label.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(label)
            labels.append(label)
        }
        
        addIndividualItemConstraints(items: labels, mainView: self, padding: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var selectFrame = self.bounds
        
        let newWidth = selectFrame.width / CGFloat(items.count)
        selectFrame.size.width = newWidth
        thumbView.frame = selectFrame
        thumbView.backgroundColor = thumbColor
        
        thumbView.layer.cornerRadius = thumbView.frame.height / 2
        
        displayNewSelectedIndex()
        
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        
        let location = touch.location(in:self)
        
        var calculatedIndex : Int?
        var index = 0
        for item in labels {
            if item.frame.contains(location) {
                calculatedIndex = index
            }
            index += 1
        }
        
        
        if calculatedIndex != nil {
            selectedIndex = calculatedIndex!
            sendActions(for: .valueChanged)
        }
        
        return false
    }
    
    func displayNewSelectedIndex(){
        for item in labels {
            item.backgroundColor = unselectedLabelColor
        }
        
        let label = labels[selectedIndex]
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
            
            self.thumbView.frame = label.frame
            
        }, completion: nil)
    }
    
    func addIndividualItemConstraints(items: [UIView], mainView: UIView, padding: CGFloat) {
        
        var index = 0;
        for button in items {
            
            let topConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: mainView, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0)
            
            let bottomConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: mainView, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0)
            
            var rightConstraint : NSLayoutConstraint!
            
            if index == items.count - 1 {
                
                rightConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: mainView, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: -padding)
                
            }else{
                
                let nextButton = items[index+1]
                rightConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: nextButton, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: -padding)
            }
            
            
            var leftConstraint : NSLayoutConstraint!
            
            if index == 0 {
                
                leftConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: mainView, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: padding)
                
            }else{
                
                let prevButton = items[index-1]
                leftConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: prevButton, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: padding)
                
                let firstItem = items[0]
                
                let widthConstraint = NSLayoutConstraint(item: button, attribute: .width, relatedBy: NSLayoutRelation.equal, toItem: firstItem, attribute: .width, multiplier: 1.0  , constant: 0)
                
                mainView.addConstraint(widthConstraint)
            }
            
            mainView.addConstraints([topConstraint, bottomConstraint, rightConstraint, leftConstraint])
            index += 1;
        }
    }
    
    func setSelectedColors(){
        /*
        for item in labels {
            item.backgroundColor = unselectedLabelColor
        }
        
        if labels.count > 0 {
            labels[0].backgroundColor = selectedLabelColor
        }
        */
        //thumbView.backgroundColor = thumbColor
    }
    
    func setFont(){
        /*
        for item in labels {
            item.font = font
        }
        */
    }
    
    // MARK: Tap gestures
    private func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tap)
    }
    
    private func addDragGesture() {
        let drag = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        thumbView.addGestureRecognizer(drag)
    }
    
    @objc private func didTap(tapGesture: UITapGestureRecognizer) {
        moveToNearestPoint(basedOn: tapGesture)
    }
    
    @objc private func didPan(panGesture: UIPanGestureRecognizer) {
        switch panGesture.state {
        case .cancelled, .ended, .failed:
            moveToNearestPoint(basedOn: panGesture, velocity: panGesture.velocity(in: thumbView))
            lastSetPoint = thumbView.center
        case .began:
            correction = panGesture.location(in: thumbView).x - thumbView.frame.width/2
            lastSetPoint = thumbView.center
        case .changed:
            
            let location = panGesture.location(in: self)
            thumbView.center.x = location.x - correction
            let trans = panGesture.translation(in: self)
            let progress = trans.x / self.thumbView.frame.width
            var toIndex = progress < 0 ? selectedIndex - 1 : selectedIndex + 1
            
            var allowMove: Bool = true;
            
            //Set minimum index to 0
            if toIndex < 0 {
                toIndex = 0
                allowMove = progress < 0 ? false : true
            }
            //Set maximum index to last index of the labels
            else if toIndex > labels.count - 1 {
                toIndex = labels.count - 1
                allowMove = progress > 0 ? false : true
            }
            
            let const = CGFloat(fminf(fmaxf(abs(Float(progress)), 0.0), 1.0))
            
            //Disallow delegate method trigger if user moves to the left on the first index or to the right on the last index.
            if allowMove {
                delegate?.didMove(self, const, toIndex);
            }
        case .possible: ()
        }
    }
    
    // MARK: Slider position
    private func moveToNearestPoint(basedOn gesture: UIGestureRecognizer, velocity: CGPoint? = nil) {
        var location = gesture.location(in: self)
        if let velocity = velocity {
            let offset = velocity.x / 12
            location.x += offset
        }
        let index = segmentIndex(for: location)
        move(to: index)
        delegate?.didSelect(index)
    }
    
    open func move(to index: Int) {
        let correctOffset = center(at: index)
        animate(to: correctOffset)
        selectedIndex = index
        displayNewSelectedIndex()
    }
    
    private func segmentIndex(for point: CGPoint) -> Int {
        var index = Int(point.x / thumbView.frame.width)
        if index < 0 { index = 0 }
        if index > labels.count - 1 { index = labels.count - 1 }
        return index
    }
    
    private func center(at index: Int) -> CGFloat {
        let xOffset = CGFloat(index) * thumbView.frame.width + thumbView.frame.width / 2
        return xOffset
    }
    
    private func animate(to position: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            self.thumbView.center.x = position
        }
    }


}
