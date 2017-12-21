//
//  ChoiceListViewDelegate.swift
//  Newsic
//
//  Created by Miguel Alcantara on 18/12/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

extension SongPickerViewController {
    
    func setupListMenu() {
        listMenuView = ChoiceListView(frame: CGRect(x: self.view.frame.origin.x, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height - self.view.safeAreaInsets.top - self.navbar.frame.height))
        
        self.listMenuView.delegate = self
        self.view.addSubview(listMenuView)
    }
    
}

extension SongPickerViewController : ChoiceListDelegate {
    
    func getSongs() {
        getNewSong(NewsicButton(type: .system))
    }
    func didRemoveGenres() {
        selectedGenres.removeAll()
        
        resetGenresPerSection()
    }
    
    func didRemoveMoods() {
        
    }
    
    func isEmpty() {
        manageButton(for: genreCollectionView);
        closeChoiceMenu()
    }
    
    func isNotEmpty() {
        manageButton(for: genreCollectionView);
        openChoiceMenu()
    }
    
    func willMove(to point: CGPoint, animated: Bool) {
        animateMove(to: point)
//        if animated {
//            
//        } else {
//            listMenuView.frame.origin.y = point.y
//            self.view.layoutIfNeeded()
//        }
//        listMenuView.layoutChoiceView()
    }
    
    func didTapGenre(value: String) {
        if let indexPath = getIndexPathForGenre(value) {
            if let genre = SpotifyGenres(rawValue: value) {
                
                sectionGenres[indexPath.section-1].append(genre)
                sectionGenres[indexPath.section-1].sort(by: { (genre1, genre2) -> Bool in
                    return genre1.rawValue < genre2.rawValue
                })
                selectedGenres.removeValue(forKey: genre.rawValue.lowercased());
                var indexSet = IndexSet()
                indexSet.insert(indexPath.section)
                genreCollectionView.reloadSections(indexSet)
//                genreCollectionView.reloadData()
            }
            
        }
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
    
    func showChoiceMenu() {
        self.listViewBottomConstraint.constant = self.view.frame.height/2
        let point = CGPoint(x: listMenuView.frame.origin.x, y: self.view.frame.height/2)
        willMove(to: point, animated: true)
        listMenuView.animateMove(to: point)
    }
    
    func hideChoiceMenu() {
        self.listViewBottomConstraint.constant = listMenuView.toggleViewHeight
        let point = CGPoint(x: listMenuView.frame.origin.x, y: self.view.frame.height - listMenuView.toggleViewHeight)
        willMove(to: point, animated: true)
        listMenuView.animateMove(to: point)
    }
    
    func openChoiceMenu() {
        self.listViewBottomConstraint.constant = listMenuView.toggleViewHeight
        let point = CGPoint(x: listMenuView.frame.origin.x, y: self.view.frame.height - listMenuView.toggleViewHeight)
        willMove(to: point, animated: true)
        listMenuView.animateMove(to: point)
        UIView.animate(withDuration: 1, delay: 0, options: [.curveEaseInOut, .autoreverse, .repeat], animations: {
            self.listMenuView.arrowImageView.alpha = 0.2
        }, completion: nil)
    }
    
    func closeChoiceMenu() {
        self.listViewBottomConstraint.constant = 0
        willMove(to: CGPoint(x: listMenuView.frame.origin.x, y: self.view.frame.height), animated: true)
        self.listMenuView.arrowImageView.alpha = 1
    }
    
    func toggleChoiceMenu(willOpen: Bool) {
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
