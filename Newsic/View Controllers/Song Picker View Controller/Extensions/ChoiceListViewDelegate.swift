//
//  ChoiceListViewDelegate.swift
//  Nusic
//
//  Created by Miguel Alcantara on 18/12/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

extension SongPickerViewController {
    
    final func setupListMenu() {
        let x = self.view.frame.origin.x
        let y = self.view.frame.height
        let maxY = self.view.safeAreaLayoutGuide.layoutFrame.maxY > 0 ? self.view.safeAreaLayoutGuide.layoutFrame.maxY : self.view.frame.height
        let width = self.view.frame.width
        let height = self.view.frame.height - self.navbar.frame.height
        
        listMenuView = ChoiceListView(frame: CGRect(x: x, y: y, width: width, height: height), maxY: maxY)
        listMenuView.delegate = self
        self.view.addSubview(listMenuView)
    }
    
    final func reloadListMenu() {
        guard listMenuView != nil else { return }
        var newY:CGFloat = 0
        if !listMenuView.isShowing {
            newY = self.view.frame.height
        } else {
            newY = listMenuView.isOpen ? self.view.frame.height/2 : self.view.safeAreaLayoutGuide.layoutFrame.maxY - listMenuView.toggleViewHeight
        }
        listMenuView.maxY = self.view.safeAreaLayoutGuide.layoutFrame.maxY - listMenuView.toggleViewHeight
        listMenuView.frame = CGRect(x: listMenuView.frame.origin.x, y: newY, width: self.view.frame.width, height: listMenuView.frame.height)
        listMenuView.reloadView()
        
    }
    
}

extension SongPickerViewController : ChoiceListDelegate {
    
    final func didTapGenre(value: String) {
        guard let genre = SpotifyGenres(rawValue: value) else { return; }
        var addedSection = false
        if getIndexPathForGenre(value) == nil {
            sectionGenreTitles.append(genre.rawValue)
            sectionGenreTitles.sort()
            if let index = sectionGenreTitles.index(of: genre.rawValue) {
                sectionGenres.insert([], at: index)
            }
            addedSection = true
        }
        
        guard let indexPath = getIndexPathForGenre(value) else { return; }
        sectionGenres[indexPath.section].append(genre)
        sectionGenres[indexPath.section].sort(by: { (genre1, genre2) -> Bool in
            return genre1.rawValue < genre2.rawValue
        })
        selectedSongsForGenre.removeValue(forKey: value)
        guard !addedSection else { genreCollectionView.reloadData(); return }
        guard let genreCell = genreCollectionView.cellForItem(at: indexPath) as? MoodGenreListCell else { return; }
        genreCell.items = sectionGenres[indexPath.section].map({ $0.rawValue })
        genreCell.listCollectionView.performBatchUpdates({
            var indexSet = IndexSet()
            indexSet.insert(0);
            genreCell.listCollectionView.insertItems(at: [IndexPath(row: 0, section: 0)])
            genreCell.listCollectionView.reloadSections(indexSet)
        }, completion: nil)
    }
    
    final func didRemoveGenres() {
        selectedSongsForGenre.removeAll()
        resetGenresPerSection()
    }
    
    final func didTapMood(value: String) {
        
    }
    
    final func didTapHeader(willOpen: Bool) {
        toggleChoiceMenu(willOpen: willOpen)
        self.view.layoutIfNeeded()
        self.view.sizeToFit()
    }
    
    final func didPanHeader(_ translationX: CGFloat, _ translationY: CGFloat) {
        self.view.layoutIfNeeded()
        self.view.sizeToFit()
    }
    
    final func willMove(to point: CGPoint, animated: Bool) {
        animateMove(to: point)
    }
    
    final func getSongs() {
        getNewSong(NusicButton(type: .system))
    }
   
    final func isEmpty() {
        manageButton(for: genreCollectionView);
        closeChoiceMenu()
        self.listMenuView.arrowImageView.alpha = 1
    }
    
    final func isNotEmpty() {
        manageButton(for: genreCollectionView);
        openChoiceMenu()
        UIView.animate(withDuration: 1, delay: 0, options: [.curveEaseInOut, .autoreverse, .repeat], animations: {
            self.listMenuView.arrowImageView.alpha = 0.2
        }, completion: nil)
    }
    
}

extension SongPickerViewController {
    
    final func showChoiceMenu() {
        let point = CGPoint(x: listMenuView.frame.origin.x, y: self.view.safeAreaLayoutGuide.layoutFrame.height/2)
        willMove(to: point, animated: true)
        listMenuView.animateMove(to: point)
        listMenuView.isShowing = true
    }
    
    final func hideChoiceMenu() {
        let point = CGPoint(x: listMenuView.frame.origin.x, y: self.view.safeAreaLayoutGuide.layoutFrame.maxY - listMenuView.toggleViewHeight)
        willMove(to: point, animated: true)
        listMenuView.animateMove(to: point)
        listMenuView.isShowing = true
    }
    
    final func openChoiceMenu() {
        let point = CGPoint(x: listMenuView.frame.origin.x, y: self.view.safeAreaLayoutGuide.layoutFrame.maxY - listMenuView.toggleViewHeight)
        willMove(to: point, animated: true)
        listMenuView.animateMove(to: point)
        listMenuView.isShowing = true
    }
    
    final func closeChoiceMenu() {
        willMove(to: CGPoint(x: listMenuView.frame.origin.x, y: self.view.frame.height), animated: true)
        listMenuView.isShowing = false
    }
    
    final func toggleChoiceMenu(willOpen: Bool) {
        listMenuView.isOpen = willOpen
        listMenuView.manageToggleView()
        _ = willOpen ? showChoiceMenu() : hideChoiceMenu()
    }
    
    final func animateMove(to point:CGPoint) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.listMenuView.frame.origin.y = point.y
            self.view.layoutIfNeeded()
        }, completion: { (isCompleted) in })
        
    }
    
}
