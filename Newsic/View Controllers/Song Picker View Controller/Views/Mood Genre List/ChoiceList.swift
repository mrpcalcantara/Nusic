//
//  ChoiceList.swift
//  Nusic
//
//  Created by Miguel Alcantara on 18/12/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

@objc protocol ChoiceListDelegate: class {
    func didTapGenre(value: String)
    func didRemoveGenres()
    func didTapMood(value: String)
    func didTapHeader(willOpen: Bool)
    func didPanHeader(_ translationX: CGFloat, _ translationY: CGFloat)
    func willMove(to point:CGPoint, animated: Bool)
    func getSongs()
    func isEmpty()
    func isNotEmpty()
//    @objc optional func didFinishPanHeader()
}

class ChoiceListView: NusicView {
    

    //Delegate
    weak var delegate: ChoiceListDelegate?
    //View properties
    //----------------------
    let viewFrame: CGRect = CGRect.zero
    var buttonSize: CGSize = CGSize.zero
    private var lastPanPoint: CGPoint = CGPoint.zero
    
    //Top part: Bar with arrow
//    let toggleView: UIView = UIView()
    var toggleViewHeight: CGFloat = 40
    var arrowImageView: UIImageView = UIImageView()
    var leftLayer: CAShapeLayer = CAShapeLayer()
    var rightLayer: CAShapeLayer = CAShapeLayer()
    var lineWidth: CGFloat = 3
//    var fetchSongsButton: NusicButton = NusicButton()
    
    @IBOutlet weak var toggleView: UIView!
    @IBOutlet weak var choiceCollectionView: UICollectionView!
    @IBOutlet weak var fetchSongsButton: NusicButton!
    
    //Animator
    let viewAnimator = UIViewPropertyAnimator()
    
    //Bottom part: Collection View
//    let choiceCollectionView: UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    var startY: CGFloat = 0
    var maxY: CGFloat = 0 {
        didSet {
            midY = maxY/2
            print("set midY = \(midY)")
        }
    }
    var midY: CGFloat = 0
    var closeThreshold: CGFloat = 0.3
    var panProgress: CGFloat = 0
    
    
    //Data
    var chosenMoods: [String] = []
    var hasMoods: Bool = false
    var chosenGenres: [String] = [] {
        didSet {
            if chosenGenres.count == 0 {
                delegate?.isEmpty()
                isOpen = false
                manageToggleView()
            }
        }
    }
    var hasGenres: Bool = false
    var isOpen: Bool = false
    var isShowing: Bool = false
    
    enum Section: Int {
//        case moodSection
        case genreSection
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromNib()
    }
    
    convenience init(frame: CGRect, maxY: CGFloat) {
        self.init(frame: frame)
        setupView(maxY: maxY)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func loadFromNib() {
        let contentView = UINib(nibName: "ChoiceList", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ChoiceListView
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.frame = bounds
        
        self.choiceCollectionView = contentView.choiceCollectionView
        self.toggleView = contentView.toggleView
        self.fetchSongsButton = contentView.fetchSongsButton
        addSubview(contentView)
    }
    
    func setupView(maxY: CGFloat) {
        
        setupToggleView();
        setupCollectionView();
        setupButton()
        setupGestureRecognizers()
        self.maxY = maxY
        startY = self.frame.origin.y
        
    }
    
    func reloadView() {
        setupArrow()
        toggleArrow()
        removeBezierPaths()
        toggleBezierPaths()
        
        startY = self.frame.origin.y
        self.fetchSongsButton.layoutIfNeeded()
        if self.isShowing {
            self.layoutChoiceView()
        }
        
    }
    
    @objc func toggleListMenu() {
        isOpen = !isOpen
        manageToggleView()
        lastPanPoint = self.frame.origin
        delegate?.didTapHeader(willOpen: isOpen)
        
    }
    
    @objc func handleListMenuPan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: self)
        self.frame.size = CGSize(width: self.frame.width, height: maxY)
        switch gestureRecognizer.state {
        case .began:
            lastPanPoint = self.frame.origin
            panProgress = 0
        case .changed:
            let pointY = lastPanPoint.y+translation.y
            panProgress = pointY / maxY
            self.frame.origin.y = pointY
            animateMove(to: CGPoint(x: self.frame.origin.x, y: pointY))
            delegate?.didPanHeader(translation.x, pointY);
        case .cancelled:
            break;
        case .ended:
            isOpen = true
            if panProgress > 1-closeThreshold || self.frame.origin.y > maxY {
                isOpen = false
            }
            delegate?.didTapHeader(willOpen: isOpen)
            manageToggleView()

        default:
            break
        }
    }
    
    func animateMove(to point:CGPoint) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.frame.origin.y = point.y
            //HACK: Resizing the frame of the view so the collection view resizes along and the user is able to scroll to the end.
            self.layoutChoiceView()
            self.layoutIfNeeded()
        }, completion: { (isCompleted) in
            
            
        })
        
    }
    
    func layoutChoiceView() {
        self.frame.size = CGSize(width: self.frame.width, height: (UIApplication.shared.keyWindow?.frame.height)! - self.frame.origin.y)
    }
    
    func insertChosenGenre(value: String) {
        if chosenGenres.count == 0 {
            delegate?.isNotEmpty()
        }
        chosenGenres.append(value)
        chosenGenres.sort()
        let indexPath = IndexPath(row: chosenGenres.index(of: value)!, section: Section.genreSection.rawValue)
        choiceCollectionView.performBatchUpdates({
            choiceCollectionView.insertItems(at: [indexPath])
        }, completion: nil)
    }
    
    func emptyGenres() {
        chosenGenres.removeAll()
        choiceCollectionView.reloadData()
        delegate?.didRemoveGenres()
    }
    
    func emptyMoods() {
        chosenMoods.removeAll()
        choiceCollectionView.reloadData()
    }
    
}




