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
    
}

extension SongPickerViewController : ChoiceListDelegate {
    
    func didTapGenre(value: String) {
        if var indexPath = getIndexPathForGenre(value) {
            if let genre = SpotifyGenres(rawValue: value) {
                
                sectionGenres[indexPath.section-1].append(genre)
                sectionGenres[indexPath.section-1].sort(by: { (genre1, genre2) -> Bool in
                    return genre1.rawValue < genre2.rawValue
                })
                selectedGenres.removeValue(forKey: genre.rawValue.lowercased());
                genreCollectionView.performBatchUpdates({
                    if indexPath.row + 1 > sectionGenres[indexPath.section-1].count {
                        indexPath.row = sectionGenres[indexPath.section-1].count-1
                    }
                    self.genreCollectionView.insertItems(at: [indexPath])
                    var indexSet = IndexSet()
                    indexSet.insert(indexPath.section)
                    self.genreCollectionView.reloadSections(indexSet)
                }, completion: { (isCompleted) in
                    
                })
                
            }
            
        }
    }
    
    func didRemoveGenres() {
        selectedGenres.removeAll()
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
