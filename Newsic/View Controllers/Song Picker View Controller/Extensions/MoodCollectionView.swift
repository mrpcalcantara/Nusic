
//
//  MoodCollectionView.swift
//  Nusic
//
//  Created by Miguel Alcantara on 03/10/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//
import Foundation
import SwiftSpinner

extension SongPickerViewController {
    
    final func setupCollectionCellViews() {
        
        let headerNib = UINib(nibName: CollectionViewHeader.className, bundle: nil)
        let view = UINib(nibName: MoodGenreListCell.className, bundle: nil);
        
        moodCollectionView.delegate = self;
        moodCollectionView.dataSource = self;
        moodCollectionView.allowsMultipleSelection = false;
        moodCollectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CollectionViewHeader.reuseIdentifier)
        moodCollectionView.register(view, forCellWithReuseIdentifier: MoodGenreListCell.reuseIdentifier);
        
        let moodLayout = moodCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        moodLayout.sectionHeadersPinToVisibleBounds = true
        let moodHeaderSize = CGSize(width: moodCollectionView.bounds.width, height: 45)
        moodLayout.headerReferenceSize = moodHeaderSize
        
        genreCollectionView.delegate = self;
        genreCollectionView.dataSource = self;
        genreCollectionView.allowsMultipleSelection = true;
        genreCollectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CollectionViewHeader.reuseIdentifier)
        genreCollectionView.register(view, forCellWithReuseIdentifier: MoodGenreListCell.reuseIdentifier);
        
        let genreLayout = genreCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        genreLayout.sectionHeadersPinToVisibleBounds = true
        let genreHeaderSize = CGSize(width: genreCollectionView.bounds.width, height: 45)
        genreLayout.headerReferenceSize = genreHeaderSize
        
        sectionGenreTitles = getSectionTitles()
        setupGenresPerSection()
        
    }
    
    //Collection Views Pan Functions
    final func updateConstraintsMoveTo(for index: Int, progress: CGFloat) {
        _ = index == 0 ? updateConstraintsShowMoodCollectionView(progress: progress) : updateConstraintsShowGenreCollectionView(progress: progress)
    }
    
    fileprivate func updateConstraintsShowMoodCollectionView(progress: CGFloat) {
        let showProgress = progress
        let hideProgress = 1 - progress
        
        moodCollectionLeadingConstraint.constant = ( -moodCollectionView.frame.width * hideProgress ) + 8
        moodCollectionTrailingConstraint.constant = ( moodCollectionView.frame.width * hideProgress ) + 8
        
        genreCollectionLeadingConstraint.constant = ( genreCollectionView.frame.width * showProgress ) + 8
        genreCollectionTrailingConstraint.constant = ( -genreCollectionView.frame.width * showProgress ) + 8
        
        genreCollectionView.layoutIfNeeded()
        moodCollectionView.layoutIfNeeded()
    }
    
    fileprivate func updateConstraintsShowGenreCollectionView(progress: CGFloat) {
        let showProgress = progress
        let hideProgress = 1 - progress
        
        moodCollectionLeadingConstraint.constant = ( -moodCollectionView.frame.width * showProgress ) + 8
        moodCollectionTrailingConstraint.constant = ( moodCollectionView.frame.width * showProgress ) + 8
        
        genreCollectionLeadingConstraint.constant = ( genreCollectionView.frame.width * hideProgress ) + 8
        genreCollectionTrailingConstraint.constant = ( -genreCollectionView.frame.width * hideProgress ) + 8
        
        genreCollectionView.layoutIfNeeded()
        moodCollectionView.layoutIfNeeded()
    }
    
    final func toggleCollectionViews(for index: Int, progress: CGFloat? = 0) {
        if index == 0 {
            self.moodCollectionLeadingConstraint.constant = 8
            self.moodCollectionTrailingConstraint.constant = 8
            self.genreCollectionLeadingConstraint.constant =  self.genreCollectionView.frame.width + 8
            self.genreCollectionTrailingConstraint.constant =  -self.genreCollectionView.frame.width + 8
            
            UIView.animate(withDuration: 0.3, animations: {
                self.genreCollectionView.alpha = 0
                self.manageButton(for: self.moodCollectionView)
                self.moodCollectionView.alpha = 1
                self.mainControlView.layoutIfNeeded()
            }, completion: { (completed) in
                
            })
            closeChoiceMenu()
            isMoodSelected = true
        } else {
            self.moodCollectionLeadingConstraint.constant = -self.moodCollectionView.frame.width + 8
            self.moodCollectionTrailingConstraint.constant =  self.moodCollectionView.frame.width + 8
            self.genreCollectionLeadingConstraint.constant = 8
            self.genreCollectionTrailingConstraint.constant = 8
            
            UIView.animate(withDuration: 0.3, animations: {
                self.moodCollectionView.alpha = 0
                self.genreCollectionView.alpha = 1
                self.manageButton(for: self.genreCollectionView)
                self.mainControlView.layoutIfNeeded()
            }, completion: { (completed) in
                
            })
            if selectedSongsForGenre.count > 0 {
                toggleChoiceMenu(willOpen: true)
            }
            isMoodSelected = false
        }
    }
    
    //Collection Views Data
    final func getSectionTitles() -> [String] {
        return SpotifyGenres.getSectionTitles()
    }
    
    final func resetGenresPerSection() {
        sectionGenreTitles = SpotifyGenres.getSectionTitles()
        sectionGenres.removeAll()
        setupGenresPerSection()
        genreCollectionView.reloadData()
    }
    
    final func setupGenresPerSection() {
        if sectionGenres.first?.count == 0 {
            sectionGenres.removeFirst()
        }
        for mainGenre in sectionGenreTitles {
            var genres = SpotifyGenres.getGenres(for: mainGenre)
            
            genres = genres.sorted(by: { (genre1, genre2) -> Bool in
                return genre1.rawValue < genre2.rawValue
            })
            if genres.count > 0 {
                sectionGenres.append(genres)
            }
        }
    }
    
    fileprivate func manageSectionTitle(for value: String) {
        if !containsSectionTitle(for: value) {
            insertSectionTitle(for: value)
        }
    }
    
    fileprivate func containsSectionTitle(for value: String) -> Bool{
        if !sectionGenreTitles.contains(value) {
            return false
        }
        return true;
    }
    
    fileprivate func insertSectionTitle(for value: String) {
        var index = 0;
        for title in sectionGenreTitles {
            if value < title {
                sectionGenreTitles.insert(value, at: index)
            }
            index += 1
        }
    }
    
    fileprivate func getGenresForSection(section: Int) -> [SpotifyGenres] {
        let sectionTitle = sectionGenreTitles[section]
        var sectionGenres: [SpotifyGenres] = []
        for genre in genreList {
            guard sectionTitle == genre.rawValue.prefix(1).uppercased() else { break; }
            sectionGenres.append(genre)
        }
        return sectionGenres
    }
    
    final func getIndexPathForGenre(_ value: String) -> IndexPath? {
        let genreDict = SpotifyGenres.genreDictionary
        for genre in genreDict.keys {
            guard let genreValues = genreDict[genre], genreValues.contains(SpotifyGenres(rawValue: value)!), let genreIndex = sectionGenreTitles.index(of: genre) else { return nil }
            return IndexPath(row: 0, section: genreIndex)
        }
        return nil;
    }
    
    final func manageButton(for collectionView: UICollectionView) {
        if collectionView == moodCollectionView {
            UIView.animate(withDuration: 0.3, animations: {
                DispatchQueue.main.async {
                    self.searchButton.alpha = 0
                    guard self.isMoodCellSelected else { return }
                    self.searchButton.alpha = 1
                }
                
            }) { (isCompleted) in
                DispatchQueue.main.async {
                    self.searchButtonHeightConstraint.constant = 35
                    self.searchButton.setTitle("Get Songs!", for: .normal)
                }
                
            }
        } else if collectionView == genreCollectionView {
            UIView.animate(withDuration: 0.3, animations: {
                DispatchQueue.main.async {
                    self.searchButton.alpha = 1
                    if self.selectedSongsForGenre.count == 0 {
                        self.searchButtonHeightConstraint.constant = 35
                        self.searchButton.setTitle("Random it up!", for: .normal)
                    } else {
                        self.searchButtonHeightConstraint.constant = 0
                        self.searchButton.setTitle("Get Songs!", for: .normal)
                    }
                    self.view.layoutIfNeeded()
                }
                
            })
        }
    }
    
    //Collection Views View functions
    final func cleanCellsLayer(for collectionView: UICollectionView) {
        var section = 0;
        let sections = collectionView == moodCollectionView ? sectionMoodTitles : sectionGenreTitles
        for title in sections {
            guard let cell = collectionView.cellForItem(at: IndexPath(row: 0, section: section)) as? MoodGenreListCell, title != "" else { return }
            cell.listCollectionView.collectionViewLayout.invalidateLayout()
            section += 1;
        }
    }
    
    final func invalidateCellsLayout(for collectionView: UICollectionView) {
        collectionView.collectionViewLayout.invalidateLayout()
        cleanCellsLayer(for: collectionView)
    }
    
    final func reloadCellsData(for collectionView: UICollectionView) {
        var section = 0;
        let sections = collectionView == moodCollectionView ? sectionMoodTitles : sectionGenreTitles
        collectionView.reloadData()
        //To confirm reloadData for main collection view is finished.
        DispatchQueue.main.async {
            for title in sections {
                guard title != "", let cell = collectionView.cellForItem(at: IndexPath(row: 0, section: section)) as? MoodGenreListCell else { return }
                cell.listCollectionView.reloadData()
                section += 1;
            }
        }
    }
    
    final func getNusicListCell(for collectionView: UICollectionView, indexPath: IndexPath) -> MoodGenreListCell? {
        guard let moodCellList = collectionView.cellForItem(at: IndexPath(row: 0, section: indexPath.section)) as? MoodGenreListCell else { return nil }
        return moodCellList
    }
    
    final func getNusicCell(for collectionView: UICollectionView, indexPath: IndexPath) -> MoodGenreCell? {
        guard let cellList = getNusicListCell(for: collectionView, indexPath: indexPath), let cell = cellList.listCollectionView.cellForItem(at: IndexPath(row: indexPath.row, section: 0)) as? MoodGenreCell else { return nil }
        return cell
    }
}

extension SongPickerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cellList = cell as? MoodGenreListCell, let elementCell = getNusicCell(for: cellList.listCollectionView, indexPath: indexPath), let nusicType = cellList.nusicType else { return }
        cellList.delegate?.willDisplayCell(cell: elementCell, nusicType: nusicType, section: indexPath.section, indexPath: IndexPath(row: indexPath.row, section: 0))
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == self.moodCollectionView {
            if let selectedIndexPath = selectedIndexPathForMood {
                moodCollectionView.delegate?.collectionView!(moodCollectionView, didDeselectItemAt: selectedIndexPath)
                
                if selectedIndexPath == indexPath {
                    return;
                }
            }
            let moodCellIndexPath = IndexPath(row: 0, section: indexPath.section)
            if let moodListCell = moodCollectionView.cellForItem(at: moodCellIndexPath) as? MoodGenreListCell {
                moodCollectionView.scrollToItem(at: IndexPath(row: 0, section: indexPath.section), at: .centeredVertically, animated: true)
                moodListCell.listCollectionView.scrollToItem(at: IndexPath(row: indexPath.row, section: 0), at: .centeredHorizontally, animated: true)
            }
            
            if let moodCell = getNusicCell(for: collectionView, indexPath: indexPath) {
                selectedIndexPathForMood = indexPath
                moodCell.selectCell()
                
                self.selectedSongsForMood = self.fetchedSongsForMood.filter({ $0.key == moodCell.moodGenreLabel.text })
            }
            let dyad = sectionMoods[indexPath.section][indexPath.row]
            let emotion = Emotion(basicGroup: dyad)
            self.moodObject = NusicMood()
            self.moodObject?.emotions = [emotion]
            self.moodObject?.userName = self.spotifyHandler.auth.session.canonicalUsername!
            self.selectedSongsForGenre.removeAll()
            
            isMoodCellSelected = true
            manageButton(for: moodCollectionView)
            
        } else {
            //Get genre from section genre for section and row.
            let genreCellIndexPath = IndexPath(row: 0, section: indexPath.section)
            guard let genreCell = genreCollectionView.cellForItem(at: genreCellIndexPath) as? MoodGenreListCell else { return }
            let selectedGenre = sectionGenres[indexPath.section][indexPath.row].rawValue
            listMenuView.insertChosenGenre(value: selectedGenre)
            sectionGenres[indexPath.section].remove(at: indexPath.row)
            genreCell.items = sectionGenres[indexPath.section].map({$0.rawValue})
            let selectedIndexPath = IndexPath(row: indexPath.row, section: 0)
            if let selectedCell = genreCell.listCollectionView.cellForItem(at: selectedIndexPath) as? MoodGenreCell {
                selectedSongsForGenre[(selectedCell.moodGenreLabel?.text)!] = selectedCell.trackList
            }
            
            if sectionGenres[indexPath.section].count == 0 {
                sectionGenres.remove(at: indexPath.section)
                sectionGenreTitles.remove(at: indexPath.section)
                genreCollectionView.reloadData()
            }
            genreCell.listCollectionView.performBatchUpdates({
                var indexSet = IndexSet()
                indexSet.insert(0)
                genreCell.listCollectionView.deleteItems(at: [selectedIndexPath])
                genreCell.listCollectionView.reloadSections(indexSet)
            }, completion: nil)
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        guard let cell = getNusicCell(for: collectionView, indexPath: indexPath) else { return }
        isMoodCellSelected = false
        moodObject = nil
        cell.deselectCell()
        cell.isSelected = false
        selectedIndexPathForMood = nil
        manageButton(for: moodCollectionView);
        
    }
    
}

extension SongPickerViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == moodCollectionView {
            return sectionMoodTitles.count
        } else {
            return sectionGenreTitles.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader, let headerCell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CollectionViewHeader.reuseIdentifier, for: indexPath) as? CollectionViewHeader {
            if collectionView == genreCollectionView {
                headerCell.configure(label: sectionGenreTitles[indexPath.section]);
            } else {
                headerCell.configure(label: sectionMoodTitles[indexPath.section]);
            }
            
            return headerCell
        } else {
            fatalError("Unknown reusable kind element");
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "moodGenreListCell", for: indexPath) as! MoodGenreListCell
        if collectionView == self.moodCollectionView {
            let moods = sectionMoods[indexPath.section].map({ $0.rawValue })
            cell.configure(for: moods, section: indexPath.section, nusicType: .mood)
            
        } else {
            let genres = sectionGenres[indexPath.section].map({ $0.rawValue })
            cell.configure(for: genres, section: indexPath.section, nusicType: .genre);
        }
        cell.delegate = self
//        cell.layoutIfNeeded()
        return cell
        
    }
    
}

extension SongPickerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height/2 - layout.headerReferenceSize.height)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == moodCollectionView {
            return 0
        }
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

extension SongPickerViewController: MoodGenreListCellDelegate {
    final func willDisplayCell(cell: MoodGenreCell, nusicType: NusicTypeSearch, section: Int, indexPath: IndexPath) {
        DispatchQueue.main.async {
            guard let label = cell.moodGenreLabel.text, label != "" else { return }
            switch nusicType {
            case .genre:
                self.willDisplayGenreCell(cell: cell, label: label, section: section, indexPath: indexPath)
            case .mood:
                self.willDisplayMoodCell(cell: cell, label: label, section: section, indexPath: indexPath)
            }
        }
    }
    
    final func didSelect(nusicType: NusicTypeSearch, section:Int, indexPath:IndexPath) {
        let currentIndexPath = IndexPath(row: indexPath.row, section: section)
        switch nusicType {
        case .genre:
            self.collectionView(genreCollectionView, didSelectItemAt: currentIndexPath)
        case .mood:
            self.collectionView(moodCollectionView, didSelectItemAt: currentIndexPath)
        }
        
    }
    
    final func willDisplayGenreCell(cell: MoodGenreCell, label: String, section: Int, indexPath: IndexPath) {
        if let tracks = self.fetchedSongsForGenre[label] {
            cell.trackList = tracks
            cell.imageList = tracks.flatMap({ $0.thumbNail })
        } else {
            let genre = self.sectionGenres[section][indexPath.row]
            let dict = ["\(genre.rawValue.lowercased())":1]
            let moodObject = NusicMood(emotions: [.init(basicGroup: .unknown)], date: Date(), associatedGenres: [String]())
            self.spotifyHandler.fetchRecommendations(for: .genres, numberOfSongs: 5, market: self.user?.territory, moodObject: moodObject, selectedGenreList: dict) { (tracks, error) in
                guard error == nil else { error?.presentPopup(for: self); return; }
                cell.trackList = tracks
                cell.addImages(urlList: tracks.map({ $0.thumbNailUrl }))
                self.fetchedSongsForGenre[label] = tracks
            }
        }
    }
    
    final func willDisplayMoodCell(cell: MoodGenreCell, label: String, section: Int, indexPath: IndexPath) {
        if let selectedMood = moodObject?.emotions.first?.basicGroup.rawValue, label == selectedMood {
            DispatchQueue.main.async {
                cell.selectCell()
            }
        }
        if let tracks = self.fetchedSongsForMood[label]  {
            cell.trackList = tracks
            cell.imageList = tracks.flatMap({ $0.thumbNail })
        } else {
            if section < self.sectionMoods.count && self.sectionMoods[section].count > 0, self.nusicUser != nil {
                let mood = self.sectionMoods[section][indexPath.row]
                let moodObject = NusicMood(emotions: [.init(basicGroup: mood)], date: Date())
                FirebaseDatabaseHelper.fetchTrackFeatures(for: (self.nusicUser.userName), moodObject: moodObject, fetchTrackFeaturesHandler: { (trackFeatures) in
                    self.spotifyHandler.fetchRecommendations(for: .genres, numberOfSongs: 5, market: self.user?.territory, moodObject: moodObject, preferredTrackFeatures: trackFeatures!, selectedGenreList: nil) { (tracks, error) in
                        guard error == nil else { error?.presentPopup(for: self); return; }
                        cell.trackList = tracks
                        cell.addImages(urlList: tracks.map({ $0.thumbNailUrl }))
                        self.fetchedSongsForMood[label] = tracks
                    }
                })
            }
        }
    }
}
