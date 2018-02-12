
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
    
    func setupCollectionCellViews() {
        
        let headerNib = UINib(nibName: CollectionViewHeader.className, bundle: nil)
//        let view = UINib(nibName: MoodViewCell.className, bundle: nil);
        let view = UINib(nibName: MoodGenreListCell.className, bundle: nil);
        
        genreCollectionView.delegate = self;
        genreCollectionView.dataSource = self;
        genreCollectionView.allowsMultipleSelection = true;
        genreCollectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CollectionViewHeader.reuseIdentifier)
        genreCollectionView.register(view, forCellWithReuseIdentifier: "moodGenreListCell");
//        genreCollectionView.setCollectionViewLayout(NusicCollectionViewLayout(), animated: true)
        
        let genreLayout = genreCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        genreLayout.sectionHeadersPinToVisibleBounds = true
        let genreHeaderSize = CGSize(width: genreCollectionView.bounds.width, height: 45)
        genreLayout.headerReferenceSize = genreHeaderSize
        
        sectionGenreTitles = getSectionTitles()
        setupGenresPerSection()
        
        moodCollectionView.delegate = self;
        moodCollectionView.dataSource = self;
        moodCollectionView.allowsMultipleSelection = false;
        moodCollectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CollectionViewHeader.reuseIdentifier)
        moodCollectionView.register(view, forCellWithReuseIdentifier: "moodGenreListCell");
//        moodCollectionView.register(view, forCellWithReuseIdentifier: MoodViewCell.reuseIdentifier);
        let moodLayout = moodCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        moodLayout.sectionHeadersPinToVisibleBounds = true
        let moodHeaderSize = CGSize(width: moodCollectionView.bounds.width, height: 45)
        moodLayout.headerReferenceSize = moodHeaderSize
        
        //Populate every section
//        setupGenresPerSection()
        
    }
    
    //Collection Views Pan Functions
    func updateConstraintsMoveTo(for index: Int, progress: CGFloat) {
        if index == 0 {
            updateConstraintsShowMoodCollectionView(progress: progress)
        } else {
            updateConstraintsShowGenreCollectionView(progress: progress)
        }
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
    
    func toggleCollectionViews(for index: Int, progress: CGFloat? = 0) {
        if index == 0 {
            self.moodCollectionLeadingConstraint.constant = 8
            self.moodCollectionTrailingConstraint.constant = 8
            self.genreCollectionLeadingConstraint.constant =  self.genreCollectionView.frame.width + 8
            self.genreCollectionTrailingConstraint.constant =  -self.genreCollectionView.frame.width + 8
            
            UIView.animate(withDuration: 0.3, animations: {
                self.genreCollectionView.alpha = 0
//                self.searchButton.alpha = self.isMoodCellSelected ? 1 : 0
                self.manageButton(for: self.moodCollectionView)
                self.moodCollectionView.alpha = 1
                self.mainControlView.layoutIfNeeded()
            }, completion: { (completed) in
                
            })
//            listMenuView.emptyGenres()
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
//            listMenuView.emptyMoods()
            if selectedSongsForGenre.count > 0 {
                toggleChoiceMenu(willOpen: true)
            }
            isMoodSelected = false
        }
    }
    
    //Collection Views Data
    func getSectionTitles() -> [String] {
        return SpotifyGenres.getSectionTitles()
    }
    
    func resetGenresPerSection() {
        sectionGenreTitles = SpotifyGenres.getSectionTitles()
        sectionGenres.removeAll()
        setupGenresPerSection()
        genreCollectionView.reloadData()
    }
    
    func setupGenresPerSection() {
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
            if let firstCharacter = genre.rawValue.first?.description.uppercased() {
                if firstCharacter == sectionTitle {
                    sectionGenres.append(genre)
                }
            }
        }
        return sectionGenres
    }
    
    func getIndexPathForGenre(_ value: String) -> IndexPath? {
        let genreDict = SpotifyGenres.genreDictionary
        for genre in genreDict.keys {
            if let genresValue = genreDict[genre] {
                if genresValue.contains(SpotifyGenres(rawValue: value)!) {
                    if let genreIndex = sectionGenreTitles.index(of: genre) {
                        return IndexPath(row: 0, section: genreIndex)
                    } else {
                        return nil
                    }
                    if sectionGenreTitles.index(of: genre) == nil {
                        sectionGenreTitles.append(genre);
                        sectionGenreTitles.sort()
                        
                    }
                    
                }
            }
        }
        return nil;
    }
    
    func manageButton(for collectionView: UICollectionView) {
        if collectionView == moodCollectionView {
            UIView.animate(withDuration: 0.3, animations: {
                DispatchQueue.main.async {
                    self.searchButton.alpha = 0
                    if self.isMoodCellSelected {
                        self.searchButton.alpha = 1
                    }
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
//                    self.searchButton.layoutIfNeeded()
                }
                
            })
        }
    }
    
    //Collection Views View functions
    func cleanCellsLayer(for collectionView: UICollectionView) {
        var section = 0;
        let sections = collectionView == moodCollectionView ? sectionMoodTitles : sectionGenreTitles
        for title in sections {
            if title != "" {
                if let cell = collectionView.cellForItem(at: IndexPath(row: 0, section: section)) as? MoodGenreListCell {
                    cell.listCollectionView.collectionViewLayout.invalidateLayout()
                }
            }
            section += 1;
        }
    }
    
    func invalidateCellsLayout(for collectionView: UICollectionView) {
        var section = 0;
        let sections = collectionView == moodCollectionView ? sectionMoodTitles : sectionGenreTitles
        collectionView.collectionViewLayout.invalidateLayout()
        for title in sections {
            if title != "" {
                if let cell = collectionView.cellForItem(at: IndexPath(row: 0, section: section)) as? MoodGenreListCell {
                    cell.listCollectionView.collectionViewLayout.invalidateLayout()
                }
            }
            section += 1;
        }
        
    }
    
    func reloadCellsData(for collectionView: UICollectionView) {
        var section = 0;
        let sections = collectionView == moodCollectionView ? sectionMoodTitles : sectionGenreTitles
        collectionView.reloadData()
        //To confirm reloadData for main collection view is finished.
        DispatchQueue.main.async {
            for title in sections {
                if title != "" {
                    if let cell = collectionView.cellForItem(at: IndexPath(row: 0, section: section)) as? MoodGenreListCell {
                        cell.listCollectionView.reloadData()
                    }
                }
                section += 1;
            }
        }
    }
    
    func getNusicListCell(for collectionView: UICollectionView, indexPath: IndexPath) -> MoodGenreListCell? {
        if let moodCellList = collectionView.cellForItem(at: IndexPath(row: 0, section: indexPath.section)) as? MoodGenreListCell {
            return moodCellList
        }
        return nil
    }
    
    func getNusicCell(for collectionView: UICollectionView, indexPath: IndexPath) -> MoodGenreCell? {
        if let cellList = getNusicListCell(for: collectionView, indexPath: indexPath) {
            if let cell = cellList.listCollectionView.cellForItem(at: IndexPath(row: indexPath.row, section: 0)) as? MoodGenreCell {
                return cell
            }
            return nil
        }
        return nil
    }
}

extension SongPickerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cellList = cell as? MoodGenreListCell, let elementCell = getNusicCell(for: cellList.listCollectionView, indexPath: indexPath), let nusicType = cellList.nusicType {
            cellList.delegate?.willDisplayCell(cell: elementCell, nusicType: nusicType, section: indexPath.section, indexPath: IndexPath(row: indexPath.row, section: 0))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == self.moodCollectionView {
            if let selectedIndexPath = selectedIndexPathForMood {
                moodCollectionView.delegate?.collectionView!(moodCollectionView, didDeselectItemAt: selectedIndexPath)
                
                if selectedIndexPath == indexPath {
                    return;
                }
            }
            
            if let moodCell = getNusicCell(for: collectionView, indexPath: indexPath) {
                selectedIndexPathForMood = indexPath
                moodCell.selectCell()
                self.selectedSongsForMood = self.fetchedSongsForMood.filter({ $0.key == moodCell.moodGenreLabel.text })
            }
            let dyad = sectionMoods[indexPath.section][indexPath.row]
//
            let emotion = Emotion(basicGroup: dyad, detailedEmotions: [], rating: 0)
            self.moodObject = NusicMood(emotions: [emotion], isAmbiguous: false, sentiment: 0.5, date: Date(), userName: spotifyHandler.auth.session.canonicalUsername, associatedGenres: [], associatedTracks: []);
            self.moodObject?.userName = self.spotifyHandler.auth.session.canonicalUsername!
            self.selectedSongsForGenre.removeAll()
            
            isMoodCellSelected = true
            manageButton(for: moodCollectionView)
//            cell.selectCell()
            
        } else {
            //Get genre from section genre for section and row.
            let selectedGenre = sectionGenres[indexPath.section][indexPath.row].rawValue
            listMenuView.insertChosenGenre(value: selectedGenre)
            sectionGenres[indexPath.section].remove(at: indexPath.row)
            if let genreCell = genreCollectionView.cellForItem(at: IndexPath(row: 0, section: indexPath.section)) as? MoodGenreListCell {
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
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        if let cell = getNusicCell(for: collectionView, indexPath: indexPath) {
            isMoodCellSelected = false
            moodObject = nil
            cell.deselectCell()
            cell.isSelected = false
            selectedIndexPathForMood = nil
            manageButton(for: moodCollectionView);
        }
        
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
        
        if kind == UICollectionElementKindSectionHeader {
            
            let headerCell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CollectionViewHeader.reuseIdentifier, for: indexPath) as! CollectionViewHeader
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
        cell.layoutIfNeeded()
        return cell
        
    }
    
}

extension SongPickerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
//        if collectionView == moodCollectionView {
//            //If iPad show 4 per row, otherwise only 2
//            cellsPerRow = UIDevice.current.userInterfaceIdiom == .pad ? 4 : 2
//            let sizeWidth = collectionView.frame.width/cellsPerRow
//            if let window = UIApplication.shared.keyWindow {
//                return CGSize(width: sizeWidth, height: window.frame.height/10);
//            } else {
//                return CGSize(width: sizeWidth, height: collectionView.frame.height/10);
//            }
//        }
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
    func willDisplayCell(cell: MoodGenreCell, nusicType: NusicTypeSearch, section: Int, indexPath: IndexPath) {
        DispatchQueue.main.async {
            if let label = cell.moodGenreLabel.text, label != "" {
                switch nusicType {
                case .genre:
                    self.willDisplayGenreCell(cell: cell, label: label, section: section, indexPath: indexPath)
                case .mood:
                    self.willDisplayMoodCell(cell: cell, label: label, section: section, indexPath: indexPath)
                }
            }
        }
        
    }
    
    func didSelect(nusicType: NusicTypeSearch, section:Int, indexPath:IndexPath) {
        let currentIndexPath = IndexPath(row: indexPath.row, section: section)
        switch nusicType {
        case .genre:
            self.collectionView(genreCollectionView, didSelectItemAt: currentIndexPath)
        case .mood:
            self.collectionView(moodCollectionView, didSelectItemAt: currentIndexPath)
        }
        
    }
    
    func willDisplayGenreCell(cell: MoodGenreCell, label: String, section: Int, indexPath: IndexPath) {
        if self.fetchedSongsForGenre.keys.contains(label)  {
            let tracks = self.fetchedSongsForGenre[label] as! [SpotifyTrack]
            cell.trackList = tracks
            cell.imageList = tracks.flatMap({ $0.thumbNail })
        } else {
//            print("fetching songs for genre: \(cell.moodGenreLabel.text)")
            let genre = self.sectionGenres[section][indexPath.row]
            let dict = ["\(genre.rawValue.lowercased())":1]
            let moodObject = NusicMood(emotions: [.init(basicGroup: .unknown, detailedEmotions: [], rating: 0)], isAmbiguous: false, sentiment: 0.5, date: Date(), associatedGenres: [], associatedTracks: [])
            self.spotifyHandler.fetchRecommendations(for: .genres, numberOfSongs: 5, market: self.user?.territory, moodObject: moodObject, selectedGenreList: dict) { (tracks, error) in
                if let error = error {
                    error.presentPopup(for: self)
                } else {
                    cell.trackList = tracks
                    cell.addImages(urlList: tracks.map({ $0.thumbNailUrl }))
                    self.fetchedSongsForGenre[label] = tracks
                }
            }
        }
    }
    
    func willDisplayMoodCell(cell: MoodGenreCell, label: String, section: Int, indexPath: IndexPath) {
        if let selectedMood = moodObject?.emotions.first?.basicGroup.rawValue {
            if label == selectedMood {
                DispatchQueue.main.async {
                    print("selecting cell with indexPath = \(section),\(indexPath.row), label = \(label)")
                    cell.selectCell()
                }
            }
        }
        if self.fetchedSongsForMood.keys.contains(label)  {
            let tracks = self.fetchedSongsForMood[label] as! [SpotifyTrack]
            cell.trackList = tracks
            cell.imageList = tracks.flatMap({ $0.thumbNail })
        } else {
            if section < self.sectionMoods.count && self.sectionMoods[section].count > 0 {
//                print("fetching songs for mood: \(cell.moodGenreLabel.text)")
                let mood = self.sectionMoods[section][indexPath.row]
                let moodObject = NusicMood(emotions: [.init(basicGroup: mood, detailedEmotions: [], rating: 0)], isAmbiguous: false, sentiment: 0.5, date: Date(), associatedGenres: [], associatedTracks: [])
                self.spotifyHandler.fetchRecommendations(for: .genres, numberOfSongs: 5, market: self.user?.territory, moodObject: moodObject, selectedGenreList: nil) { (tracks, error) in
                    if let error = error {
                        error.presentPopup(for: self)
                    } else {
                        cell.trackList = tracks
                        cell.addImages(urlList: tracks.map({ $0.thumbNailUrl }))
                        self.fetchedSongsForMood[label] = tracks
                    }
                }
            }
        }
    }
}
