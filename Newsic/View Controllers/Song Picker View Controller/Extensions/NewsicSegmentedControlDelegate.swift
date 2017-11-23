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
}
