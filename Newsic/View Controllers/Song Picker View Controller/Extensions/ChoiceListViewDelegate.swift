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
    func isEmpty() {
        closeChoiceMenu()
    }
    
    func isNotEmpty() {
        showChoiceMenu()
    }
    
    func willMove(to point: CGPoint, animated: Bool) {
        let minPointY = self.view.safeAreaInsets.top + self.navbar.frame.height + self.newsicControl.frame.origin.y + self.newsicControl.frame.height
        let maxPointY = self.view.frame.height
//        self.listViewBottomConstraint.constant = self.view.frame.height - point.y
        if animated {
            animateMove(to: point)
        } else {
            listMenuView.frame.origin.y = point.y
            self.view.layoutIfNeeded()
        }
    }
    
    func didTapGenre(value: String) {
//        if let firstCharacter = value.first?.description {
//            manageSectionTitle(for: firstCharacter);
//        }
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
//        if let indexPath = getIndexPathForGenre(value) {
//            sectionGenres[indexPath.section].insert(SpotifyGenres(rawValue: value), at: indexPath.row)
//        }
    }
    
    func didTapHeader(willOpen: Bool) {
        toggleChoiceMenu(willOpen: willOpen)
        self.view.sizeToFit()
    }
    
    func didPanHeader(_ translationX: CGFloat, _ translationY: CGFloat) {
        listViewBottomConstraint.constant = self.view.frame.height-translationY
        self.view.layoutIfNeeded()
        self.view.sizeToFit()
    }
    
    func showChoiceMenu() {
        self.listViewBottomConstraint.constant = self.view.frame.height*0.25 + 16
        willMove(to: CGPoint(x: listMenuView.frame.origin.x, y: self.view.frame.height*0.75), animated: true)
    }
    
    func hideChoiceMenu() {
        self.listViewBottomConstraint.constant = listMenuView.toggleViewHeight + 16
        willMove(to: CGPoint(x: listMenuView.frame.origin.x, y: self.view.frame.height - listMenuView.toggleViewHeight), animated: true)
    }
    
    func closeChoiceMenu() {
        self.listViewBottomConstraint.constant = 0
        willMove(to: CGPoint(x: listMenuView.frame.origin.x, y: self.view.frame.height), animated: true)
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
        }, completion: nil)
    }
}
