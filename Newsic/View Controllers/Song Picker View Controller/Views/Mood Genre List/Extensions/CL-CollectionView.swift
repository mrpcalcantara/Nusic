//
//  CL-CollectionView.swift
//  Newsic
//
//  Created by Miguel Alcantara on 20/12/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation

extension ChoiceListView {
    
    func setupCollectionView() {
        let x = self.bounds.origin.x
        let y = toggleView.bounds.height
        let width = self.bounds.width
        let height:CGFloat = self.bounds.height - y - fetchSongsButton.bounds.height
        //        choiceCollectionView.frame = CGRect(x: x, y: y, width: width, height: height)
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
        
        let headerNib = UINib(nibName: ChoiceListViewHeader.className, bundle: nil)
        let view = UINib(nibName: MusicChoiceCell.className, bundle: nil);
        
        choiceCollectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: ChoiceListViewHeader.reuseIdentifier)
        choiceCollectionView.register(view, forCellWithReuseIdentifier: MusicChoiceCell.reuseIdentifier);
        
        let genreLayout = choiceCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        genreLayout.sectionHeadersPinToVisibleBounds = true
        let genreHeaderSize = CGSize(width: choiceCollectionView.bounds.width, height: 45)
        genreLayout.headerReferenceSize = genreHeaderSize
        
        //        self.addSubview(choiceCollectionView)
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
    
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    //        var width: CGFloat = 100
    //        let height = window!.frame.height/10
    ////        let font = UIFont(name: "Futura", size: 36)
    //        switch indexPath.section {
    //        case Section.genreSection.rawValue:
    //            width = chosenGenres[indexPath.row].width(withConstraintedHeight: height, font: NewsicDefaults.font!)
    ////        case Section.moodSection.rawValue:
    ////            width = chosenMoods[indexPath.row].width(withConstraintedHeight: 50, font: font!)
    //        default:
    //            break;
    //        }
    //
    //
    //
    //        if let cell = collectionView.cellForItem(at: indexPath) {
    //            print("exists")
    //
    //        }
    ////        let size = UICollectionViewFlowLayoutAutomaticSize
    //
    //        return CGSize(width: width, height: height)
    ////        return UICollectionViewFlowLayoutAutomaticSize
    //
    //    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8;
    }
    
    
}

extension ChoiceListView: ChoiceListViewHeaderDelegate {
    
    func buttonClicked() {
        emptyGenres()
    }
    
    
}
