//
//  CL-CollectionView.swift
//  Nusic
//
//  Created by Miguel Alcantara on 20/12/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation

extension ChoiceListView {
    
    func setupCollectionView() {
        choiceCollectionView.delegate = self
        choiceCollectionView.dataSource = self
        choiceCollectionView.isScrollEnabled = true
        choiceCollectionView.bounces = true
        choiceCollectionView.alwaysBounceVertical = true
        choiceCollectionView.autoresizingMask = [.flexibleHeight, .flexibleBottomMargin]
        choiceCollectionView.backgroundColor = UIColor.clear
        
        choiceCollectionView.setCollectionViewLayout(NusicCollectionViewLayout(), animated: true)
        
        if let layout = choiceCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
        }
        
        let headerNib = UINib(nibName: ChoiceListViewHeader.className, bundle: nil)
        let view = UINib(nibName: MusicChoiceCell.className, bundle: nil);
        
        choiceCollectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: ChoiceListViewHeader.reuseIdentifier)
        choiceCollectionView.register(view, forCellWithReuseIdentifier: MusicChoiceCell.reuseIdentifier);
        
        let genreLayout = choiceCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        genreLayout.sectionHeadersPinToVisibleBounds = true
        let genreHeaderSize = CGSize(width: choiceCollectionView.bounds.width, height: 45)
        genreLayout.headerReferenceSize = genreHeaderSize
        
    }
    
    func setupGestureRecognizers() {
        let headerTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleListMenu));
        headerTapGestureRecognizer.numberOfTouchesRequired = 1
        headerTapGestureRecognizer.numberOfTapsRequired = 1
        toggleView.addGestureRecognizer(headerTapGestureRecognizer)
        
        let headerPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleListMenuPan))
        toggleView.addGestureRecognizer(headerPanGestureRecognizer)
    }
    
}

extension ChoiceListView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MusicChoiceCell
        if indexPath.section == Section.genreSection.rawValue {
            chosenGenres.remove(at: indexPath.row)
            delegate?.didTapGenre(value: (cell.choiceLabel.text)!)
        } else {
            //            chosenMoods.remove(at: indexPath.row)
            //            delegate?.didTapMood(value: (cell.moodLabel?.text)!)
        }
        
        collectionView.performBatchUpdates({
            collectionView.deleteItems(at: [indexPath])
        }, completion: nil)
        //        collectionView.reloadData()
        
    }
    
}

extension ChoiceListView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.genreSection.rawValue + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case Section.genreSection.rawValue:
            return chosenGenres.count
            //        case Section.moodSection.rawValue:
        //            return chosenMoods.count
        default:
            return 2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            
            let headerCell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: ChoiceListViewHeader.reuseIdentifier, for: indexPath) as! ChoiceListViewHeader
//            let headerCell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "collectionViewHeader", for: indexPath) as! CollectionViewHeader
            if indexPath.section == Section.genreSection.rawValue {
                headerCell.configure(label: "Genres picked")
            } else {
                headerCell.configure(label: "Mood");
            }
            headerCell.delegate = self
            return headerCell
        } else {
            fatalError("Unknown reusable kind element");
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MusicChoiceCell = collectionView.dequeueReusableCell(withReuseIdentifier: MusicChoiceCell.reuseIdentifier, for: indexPath) as! MusicChoiceCell;
        
        if indexPath.section == Section.genreSection.rawValue {
            cell.configure(with: self.chosenGenres[indexPath.row])
            cell.layoutIfNeeded()
        } else {
            //            cell.moodLabel.text = chosenMoods[indexPath.row]
        }
        
        return cell
    }
    
}

extension ChoiceListView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8;
    }
    
}

extension ChoiceListView: ChoiceListViewHeaderDelegate {
    
    func clearButtonClicked() {
        emptyGenres()
    }
    
}
