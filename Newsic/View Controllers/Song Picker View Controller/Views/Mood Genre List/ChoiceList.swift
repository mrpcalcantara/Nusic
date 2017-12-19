//
//  ChoiceList.swift
//  Newsic
//
//  Created by Miguel Alcantara on 18/12/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

@objc protocol ChoiceListDelegate: class {
    func didTapGenre(value: String)
    func didTapMood(value: String)
    func didTapHeader(willOpen: Bool)
    func didPanHeader(_ translationX: CGFloat, _ translationY: CGFloat)
    func willMove(to point:CGPoint, animated: Bool)
    func isEmpty()
    func isNotEmpty()
//    @objc optional func didFinishPanHeader()
}

class ChoiceListView: NewsicView {
    

    //Delegate
    weak var delegate: ChoiceListDelegate?
    //View properties
    //----------------------
    let viewFrame: CGRect = CGRect.zero
    private var lastPanPoint: CGPoint = CGPoint.zero
    
    //Top part: Bar with arrow
    let toggleView: UIView = UIView()
    let toggleViewHeight: CGFloat = 40
    
    //Bottom part: Collection View
    let choiceCollectionView: UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    var startY: CGFloat = 0
    var maxY: CGFloat = 0
    var closeThreshold: CGFloat = 0.25
    var panProgress: CGFloat = 0
    
    
    //Data
    var chosenMoods: [String] = []
    var hasMoods: Bool = false
    var chosenGenres: [String] = [] {
        didSet {
            if chosenGenres.count == 0 {
                delegate?.isEmpty()
                isOpen = false
            }
        }
    }
    var hasGenres: Bool = false
    var isOpen: Bool = false
    
    enum Section: Int {
        case moodSection
        case genreSection
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupView() {
        
        setupToggleView();
        setupCollectionView();
        setupGestureRecognizers()
        
        maxY = (UIApplication.shared.keyWindow?.frame.height)! - self.toggleView.frame.height
        startY = self.frame.origin.y
        
    }
    
    func setupToggleView() {
        let x = self.bounds.origin.x
        let y = self.bounds.origin.y
        let width = self.bounds.width
        let height:CGFloat = toggleViewHeight
        toggleView.frame = CGRect(x: x, y: y, width: width, height: height)
        
        toggleView.backgroundColor = UIColor.gray
        self.addSubview(toggleView)
        
        
        let text = "Open"
        let label = UILabel(frame: CGRect(x: toggleView.bounds.origin.x, y: toggleView.bounds.origin.y, width: toggleView.bounds.width, height: toggleView.frame.height));
        label.text = text
        label.textAlignment = .center
        toggleView.addSubview(label);
    }
    
    func setupCollectionView() {
        let x = self.bounds.origin.x
        let y = toggleView.bounds.height
        let width = self.bounds.width
        let height:CGFloat = self.bounds.height - y
        choiceCollectionView.frame = CGRect(x: x, y: y, width: width, height: height)
        choiceCollectionView.delegate = self
        choiceCollectionView.dataSource = self
        choiceCollectionView.isScrollEnabled = true
        choiceCollectionView.bounces = true
        choiceCollectionView.alwaysBounceVertical = true
        choiceCollectionView.autoresizingMask = [.flexibleHeight, .flexibleBottomMargin]
        
        choiceCollectionView.backgroundColor = UIColor.clear
        
        if let layout = choiceCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
        }
        
        
        let headerNib = UINib(nibName: "CollectionViewHeader", bundle: nil)
        let view = UINib(nibName: "MoodViewCell", bundle: nil);
        
        choiceCollectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "collectionViewHeader")
        choiceCollectionView.register(view, forCellWithReuseIdentifier: "moodCell");
        
        let genreLayout = choiceCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        genreLayout.sectionHeadersPinToVisibleBounds = true
        let genreHeaderSize = CGSize(width: choiceCollectionView.bounds.width, height: 45)
        genreLayout.headerReferenceSize = genreHeaderSize
        
        self.addSubview(choiceCollectionView)
    }
    
    func setupGestureRecognizers() {
        let headerTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleListMenu));
        headerTapGestureRecognizer.numberOfTouchesRequired = 1
        headerTapGestureRecognizer.numberOfTapsRequired = 1
        toggleView.addGestureRecognizer(headerTapGestureRecognizer)
        
        let headerPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleListMenuPan))
        toggleView.addGestureRecognizer(headerPanGestureRecognizer)
    }
    
    
    @objc func toggleListMenu() {
        isOpen = !isOpen
        lastPanPoint = self.frame.origin
        delegate?.didTapHeader(willOpen: isOpen)
    }
    
    @objc func handleListMenuPan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: self)
        switch gestureRecognizer.state {
        case .began:
            lastPanPoint = self.frame.origin
            panProgress = 0
        case .changed:
            let pointY = lastPanPoint.y+translation.y
            panProgress = pointY / maxY
            print("progress = \(panProgress)")
            self.frame.origin.y = pointY
            animateMove(to: CGPoint(x: self.frame.origin.x, y: pointY))
            delegate?.didPanHeader(translation.x, pointY);
        case .cancelled:
            break;
        case .ended:
            isOpen = true
            if panProgress > 1-closeThreshold || self.frame.origin.y > maxY {
                animateMove(to: CGPoint(x: self.frame.origin.x, y: maxY))
                delegate?.didPanHeader(translation.x, maxY)
                isOpen = false
            } else if panProgress < 0.25 {
                animateMove(to: CGPoint(x: self.frame.origin.x, y: self.frame.height/4))
                delegate?.didPanHeader(translation.x, self.frame.height/4)
            }
        default:
            break
        }
    }
    
    func animateMove(to point:CGPoint) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.frame.origin.y = point.y
        }, completion: { (isCompleted) in
            self.frame.size = CGSize(width: self.frame.width, height: (UIApplication.shared.keyWindow?.frame.height)! - self.frame.origin.y)
        })
        
    }
    
    func insertChosenGenre(value: String) {
        chosenGenres.append(value)
        if !isOpen {
            delegate?.isNotEmpty()
            isOpen = true
        }
        choiceCollectionView.performBatchUpdates({
            var indexSet = IndexSet(); indexSet.insert(1)
            choiceCollectionView.reloadSections(indexSet)
        }, completion: nil)
        chosenGenres.sort()
    }
}

extension ChoiceListView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MoodViewCell
        if indexPath.section == Section.genreSection.rawValue {
            chosenGenres.remove(at: indexPath.row)
            delegate?.didTapGenre(value: (cell.moodLabel?.text)!)
        } else {
            chosenMoods.remove(at: indexPath.row)
            delegate?.didTapMood(value: (cell.moodLabel?.text)!)
        }
        
        collectionView.performBatchUpdates({
            collectionView.deleteItems(at: [indexPath])
        }, completion: nil)
        
        
    }
    
}

extension ChoiceListView: UICollectionViewDataSource {
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.genreSection.rawValue+1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case Section.genreSection.rawValue:
            return chosenGenres.count
        case Section.moodSection.rawValue:
            return chosenMoods.count
        default:
            return 2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            
            let headerCell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "collectionViewHeader", for: indexPath) as! CollectionViewHeader
            if indexPath.section == Section.genreSection.rawValue {
                headerCell.configure(label: "Genres")
            } else {
                headerCell.configure(label: "Mood");
            }
            return headerCell
        } else {
            fatalError("Unknown reusable kind element");
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MoodViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "moodCell", for: indexPath) as! MoodViewCell;
        
        cell.configure(for: indexPath.row, offsetRect: CGRect.zero, isLastRow: false)
        
        if indexPath.section == Section.genreSection.rawValue {
            cell.moodLabel.text = chosenGenres[indexPath.row]
        } else {
            cell.moodLabel.text = chosenMoods[indexPath.row]
        }
        
        return cell
    }
    
}

extension ChoiceListView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat = 100
        let font = UIFont(name: "Futura", size: 18)
        switch indexPath.section {
        case Section.genreSection.rawValue:
            width = chosenGenres[indexPath.row].width(withConstraintedHeight: 50, font: font!)
        case Section.moodSection.rawValue:
            width = chosenMoods[indexPath.row].width(withConstraintedHeight: 50, font: font!)
        default:
            break;
        }
        
        return CGSize(width: width, height: 50)

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8;
    }
    
}


