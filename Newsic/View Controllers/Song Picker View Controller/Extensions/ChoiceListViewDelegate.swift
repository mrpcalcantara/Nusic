//
//  ChoiceListViewDelegate.swift
//  Newsic
//
//  Created by Miguel Alcantara on 18/12/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

extension SongPickerViewController : ChoiceListDelegate {
    func didFinishPanHeader() {
        
    }
    
    func didTapGenre() {
        
    }
    func didTapMood() {
        
    }
    func didTapHeader(willOpen: Bool) {
        if willOpen {
            listMenuView.frame.origin.y = self.view.frame.height/2
            listViewBottomConstraint.constant = self.view.frame.height/2
        } else {
            listMenuView.frame.origin.y = self.view.frame.height - listMenuView.toggleViewHeight
            listViewBottomConstraint.constant = listMenuView.toggleViewHeight
        }
        self.view.layoutIfNeeded()
    }
    
    func didPanHeader(_ translationX: CGFloat, _ translationY: CGFloat) {
        
        print(translationY)
        let minPointY = self.view.safeAreaInsets.top + self.navbar.frame.height + self.newsicControl.frame.origin.y + self.newsicControl.frame.height
        let maxPointY = self.view.frame.height
        if translationY > minPointY && translationY < maxPointY {
            listViewBottomConstraint.constant = self.view.frame.height-translationY
            listMenuView.frame.origin.y = translationY
            self.view.layoutIfNeeded()
        }
        
    }
}
