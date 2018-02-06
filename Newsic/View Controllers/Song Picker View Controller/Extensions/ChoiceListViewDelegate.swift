//
//  ChoiceListViewDelegate.swift
//  Nusic
//
//  Created by Miguel Alcantara on 18/12/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

extension SongPickerViewController {
    
    func setupListMenu() {
        let x = self.view.frame.origin.x
        let y = self.view.frame.height
        let maxY = self.view.safeAreaLayoutGuide.layoutFrame.maxY > 0 ? self.view.safeAreaLayoutGuide.layoutFrame.maxY : self.view.frame.height
        let width = self.view.frame.width
        let height = self.view.frame.height - self.navbar.frame.height
        
        listMenuView = ChoiceListView(frame: CGRect(x: x, y: y, width: width, height: height), maxY: maxY)
        listMenuView.delegate = self
        self.view.addSubview(listMenuView)
    }
    
    func reloadListMenu() {
        var newY:CGFloat = 0
        if !listMenuView.isShowing {
            newY = self.view.frame.height
        } else {
            if listMenuView.isOpen {
                newY = self.view.frame.height/2
            } else {
                newY = self.view.safeAreaLayoutGuide.layoutFrame.maxY - listMenuView.toggleViewHeight
            }
        }
        listMenuView.maxY = self.view.safeAreaLayoutGuide.layoutFrame.maxY - listMenuView.toggleViewHeight
        listMenuView.frame = CGRect(x: listMenuView.frame.origin.x, y: newY, width: self.view.frame.width, height: listMenuView.frame.height)
        listMenuView.reloadView()
    }
    
}

extension SongPickerViewController : ChoiceListDelegate {
    
    func didTapGenre(value: String) {
        if let genre = SpotifyGenres(rawValue: value) {
            var addedSection = false
            if var indexPath = getIndexPathForGenre(value) {
                
            } else {
                sectionGenreTitles.append(genre.rawValue)
                sectionGenreTitles.sort()
                if let index = sectionGenreTitles.index(of: genre.rawValue) {
                    sectionGenres.insert([], at: index)
                }
                addedSection = true
            }
            
            if var indexPath = getIndexPathForGenre(value) {
                sectionGenres[indexPath.section].append(genre)
                sectionGenres[indexPath.section].sort(by: { (genre1, genre2) -> Bool in
                    return genre1.rawValue < genre2.rawValue
                })
                selectedSongsForGenre.removeValue(forKey: value)
                if addedSection {
//                    genreCollectionView.performBatchUpdates({
//                        genreCollectionView.insertSections(IndexSet(arrayLiteral: indexPath.section))
//                    }, completion: nil)
                    
                    genreCollectionView.reloadData()
                } else {
                    if let genreCell = genreCollectionView.cellForItem(at: indexPath) as? MoodGenreListCell {
                        genreCell.items = sectionGenres[indexPath.section].map({ $0.rawValue })
                        let selectedIndexPath = IndexPath(row: indexPath.row, section: 0)
                        if let selectedCell = genreCell.listCollectionView.cellForItem(at: selectedIndexPath) as? MoodGenreCell {
                            
                        }
                        
//                        genreCell.listCollectionView.reloadData()
                        genreCell.listCollectionView.performBatchUpdates({
                            var indexSet = IndexSet()
                            indexSet.insert(0);
                            genreCell.listCollectionView.insertItems(at: [IndexPath(row: 0, section: 0)])
                            genreCell.listCollectionView.reloadSections(indexSet)
                        }, completion: nil)
                    }
                }
            }
        }
        
        
        
//
//
//        if var indexPath = getIndexPathForGenre(value) {
//            if let genre = SpotifyGenres(rawValue: value) {
//
//                sectionGenres[indexPath.section].append(genre)
//                sectionGenres[indexPath.section].sort(by: { (genre1, genre2) -> Bool in
//                    return genre1.rawValue < genre2.rawValue
//                })
//                //                selectedGenres.removeValue(forKey: genre.rawValue.lowercased());
//                if let genreCell = genreCollectionView.cellForItem(at: indexPath) as? MoodGenreListCell {
//                    genreCell.items = sectionGenres[indexPath.section].map({ $0.rawValue })
//                    let selectedIndexPath = IndexPath(row: indexPath.row, section: 0)
//                    if let selectedCell = genreCell.listCollectionView.cellForItem(at: selectedIndexPath) as? MoodGenreCell {
//                        selectedSongsForGenre.removeValue(forKey: value)
//                    }
//                    genreCell.listCollectionView.performBatchUpdates({
//
//                        var indexSet = IndexSet()
//                        indexSet.insert(indexPath.section);
//                        if sectionGenres[indexPath.section].count == 0 {
//                            genreCollectionView.insertSections(indexSet)
//                            genreCell.listCollectionView.insertItems(at: [IndexPath(row: 0, section: 0)])
//                        } else {
//                            genreCell.listCollectionView.reloadSections(indexSet)
//                        }
//
//
//                    }, completion: nil)
//                }
//            }
//        } else {
//
//        }
    }
    
    func didRemoveGenres() {
//        selectedGenres.removeAll()
        selectedSongsForGenre.removeAll()
        resetGenresPerSection()
    }
    
    func didTapMood(value: String) {
        
    }
    
    func didTapHeader(willOpen: Bool) {
        toggleChoiceMenu(willOpen: willOpen)
        self.view.layoutIfNeeded()
        self.view.sizeToFit()
    }
    
    func didPanHeader(_ translationX: CGFloat, _ translationY: CGFloat) {
        listViewBottomConstraint.constant = self.view.frame.height-translationY
        self.view.layoutIfNeeded()
        self.view.sizeToFit()
    }
    
    func willMove(to point: CGPoint, animated: Bool) {
        animateMove(to: point)
    }
    
    func getSongs() {
        getNewSong(NusicButton(type: .system))
    }
   
    func isEmpty() {
        manageButton(for: genreCollectionView);
        closeChoiceMenu()
        self.listMenuView.arrowImageView.alpha = 1
    }
    
    func isNotEmpty() {
        manageButton(for: genreCollectionView);
        openChoiceMenu()
        UIView.animate(withDuration: 1, delay: 0, options: [.curveEaseInOut, .autoreverse, .repeat], animations: {
            self.listMenuView.arrowImageView.alpha = 0.2
        }, completion: nil)
    }
    
}

extension SongPickerViewController {
    
    func showChoiceMenu() {
        self.listViewBottomConstraint.constant = self.view.frame.height/2
        let point = CGPoint(x: listMenuView.frame.origin.x, y: self.view.safeAreaLayoutGuide.layoutFrame.height/2)
        willMove(to: point, animated: true)
        listMenuView.animateMove(to: point)
        listMenuView.isShowing = true
    }
    
    func hideChoiceMenu() {
        self.listViewBottomConstraint.constant = listMenuView.toggleViewHeight
        let point = CGPoint(x: listMenuView.frame.origin.x, y: self.view.safeAreaLayoutGuide.layoutFrame.maxY - listMenuView.toggleViewHeight)
        willMove(to: point, animated: true)
        listMenuView.animateMove(to: point)
        listMenuView.isShowing = true
    }
    
    func openChoiceMenu() {
        self.listViewBottomConstraint.constant = listMenuView.toggleViewHeight
        //        print(self.view.safeAreaLayoutGuide.layoutFrame.maxY)
        let point = CGPoint(x: listMenuView.frame.origin.x, y: self.view.safeAreaLayoutGuide.layoutFrame.maxY - listMenuView.toggleViewHeight)
        willMove(to: point, animated: true)
        listMenuView.animateMove(to: point)
        listMenuView.isShowing = true
    }
    
    func closeChoiceMenu() {
        self.listViewBottomConstraint.constant = 0
        willMove(to: CGPoint(x: listMenuView.frame.origin.x, y: self.view.frame.height), animated: true)
        listMenuView.isShowing = false
    }
    
    func toggleChoiceMenu(willOpen: Bool) {
        listMenuView.isOpen = willOpen
        listMenuView.manageToggleView()
        if willOpen {
            showChoiceMenu()
        } else {
            hideChoiceMenu()
        }
    }
    
    func animateMove(to point:CGPoint) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.listMenuView.frame.origin.y = point.y
            self.view.layoutIfNeeded()
        }, completion: { (isCompleted) in
            //            self.listMenuView.animateMove(to: point)
        })
        
    }
    
}
