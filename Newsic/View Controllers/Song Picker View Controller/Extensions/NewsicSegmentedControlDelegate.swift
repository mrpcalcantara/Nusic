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
        print("moving to Index \(toIndex)")
        if toIndex == 0 {
            self.moodCollectionView.alpha = progress
            self.genreCollectionView.alpha = 1 - progress
            self.searchButton.alpha = 1 - progress
        } else {
            self.moodCollectionView.alpha = 1 - progress
            self.genreCollectionView.alpha = progress
            self.searchButton.alpha = progress
        }
    }
    
    func didMove(_ control: UIControl, _ location: CGPoint) {
        print(location)
        
        
    }
}
