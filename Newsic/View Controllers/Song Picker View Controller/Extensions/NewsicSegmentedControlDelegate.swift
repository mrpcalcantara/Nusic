//
//  NewsicSegmentedControl.swift
//  Newsic
//
//  Created by Miguel Alcantara on 23/11/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation

extension SongPickerViewController: NewsicSegmentedControlDelegate {
    func didSelect(_ segmentIndex: Int) {
        toggleCollectionViews(for: segmentIndex)
    }
    
    func didMove(_ control: UIControl, _ progress: CGFloat, _ toIndex: Int) {
        segmentedControlMove(progress, toIndex)
    }
    
    func segmentedControlMove(_ progress: CGFloat, _ toIndex: Int) {
        updateConstraintsMoveTo(for: toIndex, progress: progress)
        let showProgress = progress
        let hideProgress = 1 - progress
        
        if toIndex == 0 {
            moodCollectionView.alpha = showProgress
            genreCollectionView.alpha = hideProgress
            searchButton.alpha = hideProgress
        } else {
            moodCollectionView.alpha = hideProgress
            genreCollectionView.alpha = showProgress
            searchButton.alpha = showProgress
        }
    }
    
}
