
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
        let view = UINib(nibName: MoodViewCell.className, bundle: nil);
        let viewTEST = UINib(nibName: MoodGenreListCell.className, bundle: nil);
        
        genreCollectionView.delegate = self;
        genreCollectionView.dataSource = self;
        genreCollectionView.allowsMultipleSelection = true;
        genreCollectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CollectionViewHeader.reuseIdentifier)
        genreCollectionView.register(viewTEST, forCellWithReuseIdentifier: "moodGenreListCell");
//        genreCollectionView.setCollectionViewLayout(NusicCollectionViewLayout(), animated: true)
        
        let genreLayout = genreCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        genreLayout.sectionHeadersPinToVisibleBounds = true
        let genreHeaderSize = CGSize(width: genreCollectionView.bounds.width, height: 45)
        genreLayout.headerReferenceSize = genreHeaderSize
        
        sectionTitles = getSectionTitles()
        setupGenresPerSection()
        
        moodCollectionView.delegate = self;
        moodCollectionView.dataSource = self;
        moodCollectionView.allowsMultipleSelection = false;
        moodCollectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CollectionViewHeader.reuseIdentifier)
        moodCollectionView.register(view, forCellWithReuseIdentifier: MoodViewCell.reuseIdentifier);
        let moodLayout = moodCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        moodLayout.sectionHeadersPinToVisibleBounds = true
        let moodHeaderSize = CGSize(width: moodCollectionView.bounds.width, height: 45)
        moodLayout.headerReferenceSize = moodHeaderSize
        
        //Populate every section
//        setupGenresPerSection()
        
    }
    
    func showMoodCollectionView() {
        moodCollectionView.isHidden = false;
    }
    
    func showGenreCollectionView() {
        genreCollectionView.isHidden = false;
    }
    
    func hideMoodCollectionView() {
        moodCollectionView.isHidden = true;
    }
    
    func hideGenreCollectionView() {
        genreCollectionView.isHidden = true;
    }
    
    func updateConstraintsMoveTo(for index: Int, progress: CGFloat) {
        if index == 0 {
            updateConstraintsShowMoodCollectionView(progress: progress)
        } else {
            updateConstraintsShowGenreCollectionView(progress: progress)
        }
    }
    
    func updateConstraintsShowMoodCollectionView(progress: CGFloat) {
        let showProgress = progress
        let hideProgress = 1 - progress
        
        moodCollectionLeadingConstraint.constant = ( -moodCollectionView.frame.width * hideProgress ) + 8
        moodCollectionTrailingConstraint.constant = ( moodCollectionView.frame.width * hideProgress ) + 8
        
        genreCollectionLeadingConstraint.constant = ( genreCollectionView.frame.width * showProgress ) + 8
        genreCollectionTrailingConstraint.constant = ( -genreCollectionView.frame.width * showProgress ) + 8
        
        genreCollectionView.layoutIfNeeded()
        moodCollectionView.layoutIfNeeded()
    }
    
    func updateConstraintsShowGenreCollectionView(progress: CGFloat) {
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
            if selectedGenres.count > 0 {
                toggleChoiceMenu(willOpen: true)
            }
            isMoodSelected = false
        }
    }
    
    func getSectionTitles() -> [String] {
        var sectionTitles: [String] = []
        
        for value in genreList {
            if let character = value.rawValue.first?.description.uppercased() {
                if !sectionTitles.contains(character) {
                    sectionTitles.append(character)
                }
            }
        }
        return sectionTitles
    }
    
    func resetGenresPerSection() {
        sectionTitles = getSectionTitles()
        setupGenresPerSection()
        genreCollectionView.reloadData()
    }
    
    func setupGenresPerSection() {
        let count = sectionTitles.count - 1
        for section in 0...count {
            let genresForSection = getGenresForSection(section: section)
            if genresForSection.count > 0 {
                sectionGenres.insert(genresForSection, at: section)
            }
        }
    }
    
    func manageSectionTitle(for value: String) {
        if !containsSectionTitle(for: value) {
            insertSectionTitle(for: value)
        }
    }
    
    func containsSectionTitle(for value: String) -> Bool{
        if !sectionTitles.contains(value) {
            return false
        }
        return true;
    }
    
    func insertSectionTitle(for value: String) {
        var index = 0;
        for title in sectionTitles {
            if value < title {
                sectionTitles.insert(value, at: index)
            }
            index += 1
        }
    }
    
    func getGenresForSection(section: Int) -> [SpotifyGenres] {
        let sectionTitle = sectionTitles[section]
        var sectionGenres: [SpotifyGenres] = []
        for genre in genreList {
            if let firstCharacter = genre.rawValue.first?.description.uppercased() {
                if firstCharacter == sectionTitle {
                    sectionGenres.append(genre)
                }
            }
        }
        //        print("SECTION GENRES IN METHOD = \(sectionGenres.description)")
        return sectionGenres
    }
    
    func getIndexPathForGenre(_ value: String) -> IndexPath? {
        var section = 1
        for title in sectionTitles {
            if let firstCharacter = value.first?.description {
                if title.elementsEqual(firstCharacter) {
                    let genres = getGenresForSection(section: section-1)
                    if let row = genres.index(where: { (genre) -> Bool in
                        return genre.rawValue == value
                    }) {
                        return IndexPath(row: row, section: section)
                    }
                }
            }
            section += 1
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
                    if self.selectedGenres.count == 0 {
                        
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
}

extension SongPickerViewController: UICollectionViewDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == moodCollectionView {
            let nusicCell = cell as! MoodViewCell
            if let mood = nusicCell.moodLabel.text {
                if let selectedMood = moodObject?.emotions.first?.basicGroup.rawValue {
                    if mood == selectedMood {
                        DispatchQueue.main.async {
                            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.centeredVertically)
//                            nusicCell.isSelected = true
                            nusicCell.selectCell()
                        }
                    }
                }
            }
        } else if collectionView == genreCollectionView {
//            let nusicCell = cell as! MoodViewCell
//            if let genre = nusicCell.moodLabel.text {
//                if selectedGenres[genre.lowercased()] != nil {
//                    DispatchQueue.main.async {
////                        nusicCell.selectCell()
//                    }
//                }
//            }
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if collectionView == self.moodCollectionView {
            
            let cell = moodCollectionView.cellForItem(at: indexPath) as! MoodViewCell
            if let moodValue = moodObject?.emotions.first?.basicGroup.rawValue {
                if moodValue == cell.moodLabel.text {
                    collectionView.delegate?.collectionView!(collectionView, didDeselectItemAt: indexPath)
                    return false;
                } else {
                    return true;
                }
            }
        } else if collectionView == self.genreCollectionView {
            let cell = genreCollectionView.cellForItem(at: indexPath) as! MoodViewCell
            if let genre = cell.moodLabel.text {
                if selectedGenres[genre.lowercased()] != nil {
                    collectionView.delegate?.collectionView!(collectionView, didDeselectItemAt: indexPath)
                    return false;
                } else {
                    return true;
                }
            }
        }
        return true;
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == self.moodCollectionView {
            
            let cell = moodCollectionView.cellForItem(at: indexPath) as! MoodViewCell
            let dyad = moods[indexPath.row]
            
            let emotion = Emotion(basicGroup: dyad, detailedEmotions: [], rating: 0)
            self.moodObject = NusicMood(emotions: [emotion], isAmbiguous: false, sentiment: 0.5, date: Date(), userName: spotifyHandler.auth.session.canonicalUsername, associatedGenres: [], associatedTracks: []);
            self.moodObject?.userName = self.spotifyHandler.auth.session.canonicalUsername!
//            self.moodObject?.userName = "test.user"
            self.selectedGenres.removeAll()
            isMoodCellSelected = true
            manageButton(for: moodCollectionView)
            cell.selectCell()
            
        } else {
            //Get genre from section genre for section and row.
            let selectedGenre = sectionGenres[indexPath.section-1][indexPath.row].rawValue
            listMenuView.insertChosenGenre(value: selectedGenre)
            sectionGenres[indexPath.section-1].remove(at: indexPath.row)
            selectedGenres.updateValue(1, forKey: selectedGenre.lowercased());
            var indexSet = IndexSet()
            indexSet.insert(indexPath.section)
            collectionView.performBatchUpdates({
                collectionView.deleteItems(at: [indexPath])
                collectionView.reloadSections(indexSet)
            }, completion: { (isCompleted) in
                
            })
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? MoodViewCell {
            if collectionView == self.genreCollectionView {
                if let genre = cell.moodLabel.text {
                    selectedGenres.removeValue(forKey: genre.lowercased());
                    cell.deselectCell()
                }
            } else if collectionView == self.moodCollectionView {
                isMoodCellSelected = false
                moodObject = nil
                cell.deselectCell()
                manageButton(for: moodCollectionView);
            }
        }
        
    }
    
}

extension SongPickerViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == moodCollectionView {
            return 1
        } else {
            return sectionTitles.count + 1
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.moodCollectionView {
            return moods.count
        } else {
            if section > 0 {
//                return sectionGenres[section-1].count
//                return getGenresForSection(section: section-1).count
                return 1
            } else {
                return 0
            }
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            
            let headerCell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CollectionViewHeader.reuseIdentifier, for: indexPath) as! CollectionViewHeader
            if collectionView == genreCollectionView {
                if indexPath.section == 0 {
                    headerCell.configure(label: "Genres")
                } else {
                    headerCell.configure(label: sectionTitles[indexPath.section-1]);
                }
                
            } else {
                headerCell.configure(label: "Moods")
            }
            
            return headerCell
        } else {
            fatalError("Unknown reusable kind element");
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var isLastRow: Bool = false
        
        if collectionView == self.moodCollectionView {
            let cell: MoodViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: MoodViewCell.reuseIdentifier, for: indexPath) as! MoodViewCell;
            let mood = moods[indexPath.row].rawValue
            cell.moodLabel.text = "\(mood)"
            isLastRow = indexPath.row > moods.count - Int(cellsPerRow)-1
            cell.configure(for: indexPath.row, offsetRect: self.sectionHeaderFrame, isLastRow: isLastRow);
            cell.layoutIfNeeded()
            
            return cell;
        } else {
            let genres = sectionGenres[indexPath.section-1]
            let genre = genres[indexPath.row].rawValue
//            cell.moodLabel.text = "\(genre)"
            isLastRow = indexPath.row > genres.count - Int(cellsPerRow)-1
            print("showing indexPath: \(indexPath)")
            
            let cellTEST = collectionView.dequeueReusableCell(withReuseIdentifier: "moodGenreListCell", for: indexPath) as! MoodGenreListCell
            
            cellTEST.configure(for: genres, section: indexPath.section-1);
            cellTEST.delegate = self
            cellTEST.layoutIfNeeded()
            return cellTEST
            
        }
        
        
    }
    
}

extension SongPickerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == moodCollectionView {
            //If iPad show 4 per row, otherwise only 2
            cellsPerRow = UIDevice.current.userInterfaceIdiom == .pad ? 4 : 2
            let sizeWidth = collectionView.frame.width/cellsPerRow
            if let window = UIApplication.shared.keyWindow {
                return CGSize(width: sizeWidth, height: window.frame.height/10);
            } else {
                return CGSize(width: sizeWidth, height: collectionView.frame.height/10);
            }
        }
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height/5)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == genreCollectionView {
            return 16
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == genreCollectionView {
            return 8
        }
        return 0
    }
    
}

extension SongPickerViewController: MoodGenreListCellDelegate {
    func didSelect(section:Int, indexPath:IndexPath) {
        let currentIndexPath = IndexPath(row: indexPath.row, section: section+1)
        print("selected at indexPath : \(currentIndexPath)")
        self.collectionView(genreCollectionView, didSelectItemAt: currentIndexPath)
    }
}
