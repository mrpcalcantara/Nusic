//
//  ChoiceList.swift
//  Newsic
//
//  Created by Miguel Alcantara on 18/12/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

@objc protocol ChoiceListDelegate: class {
    func didTapGenre()
    func didTapMood()
    @objc optional func didTapHeader(willOpen: Bool)
    @objc optional func didPanHeader(_ translationX: CGFloat, _ translationY: CGFloat)
    @objc optional func didFinishPanHeader()
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
    
    
    //Data
    var chosenMoods: [String] = []
    var hasMoods: Bool = false
    var chosenGenres: [String] = []
    var hasGenres: Bool = false
    var isOpen: Bool = false
    
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
        
        choiceCollectionView.backgroundColor = UIColor.clear
        
        if let layout = choiceCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
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
        delegate?.didTapHeader!(willOpen: isOpen)
    }
    
    @objc func handleListMenuPan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: self)
        switch gestureRecognizer.state {
        case .began:
            lastPanPoint = self.frame.origin
        case .changed:
            delegate?.didPanHeader!(translation.x, lastPanPoint.y+translation.y);
        case .cancelled:
            break;
        case .ended:
            break;
        default:
            break
        }
    }
}

extension ChoiceListView: UICollectionViewDelegate {
    
}

extension ChoiceListView: UICollectionViewDataSource {
    
    enum Section: Int {
        case moodSection
        case genreSection
    }
    
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


