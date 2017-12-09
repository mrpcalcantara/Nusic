//
//  MoodCollectionView.swift
//  Newsic
//
//  Created by Miguel Alcantara on 03/10/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation
import SwiftSpinner

extension SongPickerViewController {
    
    func setupCollectionViewTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(detectTap(_:)))
        //tapGestureRecognizer.delegate = self as! UIGestureRecognizervaregate
        
        //moodCollectionView.addGestureRecognizer(tapGestureRecognizer)
        //genreCollectionView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func detectTap(_ tapRecognizer: UITapGestureRecognizer? = nil) {
        let view = self.view
        let location = tapRecognizer?.location(in: self.view)
//        print("location in screen = \(location)")
        
        let moodView = genreCollectionView
        if let moodView = moodView {
            //                let location = touch?.location(in: moodView)
            //                if let location = location {
            //
            //                }
            let indexPath = moodView.indexPathForItem(at: location!)
            
            
            
            if let indexPath = indexPath {
                //moodView.delegate?.collectionView!(moodView, didSelectItemAt: indexPath)
                //print(location)
                let cell = genreCollectionView.cellForItem(at: indexPath) as! MoodViewCell
                
                if (cell.borderPathLayer?.path?.contains(location!))! {
                    print("Touched in indexPath \(indexPath.row)")
                } else {
                    print("Touched in indexPath \((indexPath.row)-1)")
                }
            }
        }
//
//        if view == moodCollectionView {
//            let moodView = moodCollectionView
//            if let moodView = moodView {
//                //                let location = touch?.location(in: moodView)
//                //                if let location = location {
//                //
//                //                }
//
//                let indexPath = moodView.indexPathForItem(at: location!)
//                if let indexPath = indexPath {
//                    moodView.delegate?.collectionView!(moodView, didSelectItemAt: indexPath)
//                    print(location)
//                }
//            }
//
//        }
        
        if view == genreCollectionView {
            let moodView = genreCollectionView
            if let moodView = moodView {
                let indexPath = moodView.indexPathForItem(at: location!)
                if let indexPath = indexPath {
                    moodView.delegate?.collectionView!(moodView, didSelectItemAt: indexPath)
                }
            }
        }
    }
    
    func setupCollectionCellViews() {
        
        let headerNib = UINib(nibName: "CollectionViewHeader", bundle: nil)
        let view = UINib(nibName: "MoodViewCell", bundle: nil);
        
        genreCollectionView.delegate = self;
        genreCollectionView.dataSource = self;
        genreCollectionView.allowsMultipleSelection = true;
        genreCollectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "collectionViewHeader")
        genreCollectionView.register(view, forCellWithReuseIdentifier: "moodCell");
        sectionTitles = getSectionTitles()
        setupGenresPerSection()
        
        let genreLayout = genreCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        genreLayout.sectionHeadersPinToVisibleBounds = true
        let genreHeaderSize = CGSize(width: genreCollectionView.bounds.width, height: 45)
        genreLayout.headerReferenceSize = genreHeaderSize
        
        moodCollectionView.delegate = self;
        moodCollectionView.dataSource = self;
        moodCollectionView.allowsMultipleSelection = false;
        moodCollectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "collectionViewHeader")
        moodCollectionView.register(view, forCellWithReuseIdentifier: "moodCell");
        let moodLayout = moodCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        moodLayout.sectionHeadersPinToVisibleBounds = true
        let moodHeaderSize = CGSize(width: moodCollectionView.bounds.width, height: 45)
        moodLayout.headerReferenceSize = moodHeaderSize
        
        
        
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
                self.searchButton.alpha = 0
                self.moodCollectionView.alpha = 1
                self.mainControlView.layoutIfNeeded()
            }, completion: { (completed) in
                
            })
            
            isMoodSelected = true
        } else {
            self.moodCollectionLeadingConstraint.constant = -self.moodCollectionView.frame.width + 8
            self.moodCollectionTrailingConstraint.constant =  self.moodCollectionView.frame.width + 8
            self.genreCollectionLeadingConstraint.constant = 8
            self.genreCollectionTrailingConstraint.constant = 8
            
            UIView.animate(withDuration: 0.3, animations: {
                self.moodCollectionView.alpha = 0
                self.genreCollectionView.alpha = 1
                self.searchButton.alpha = 1
                self.mainControlView.layoutIfNeeded()
            }, completion: { (completed) in
                
            })
            
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
    
    func setupGenresPerSection() {
        let count = sectionTitles.count - 1
        for section in 0...count {
            let genresForSection = getGenresForSection(section: section)
            if genresForSection.count > 0 {
                sectionGenres.insert(genresForSection, at: section)
            }
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
    
}

extension SongPickerViewController: UICollectionViewDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let newsicCell = cell as! MoodViewCell
        if let genre = newsicCell.moodLabel.text {
            if selectedGenres[genre.lowercased()] != nil {
                DispatchQueue.main.async {
                    newsicCell.selectCell()
                }
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.moodCollectionView {
            let dyad = EmotionDyad.allValues[indexPath.row]
            
//            SwiftSpinner.show("Loading...", animated: true);
            
            let emotion = Emotion(basicGroup: dyad, detailedEmotions: [], rating: 0)
            self.moodObject = NewsicMood(emotions: [emotion], isAmbiguous: false, sentiment: 0.5, date: Date(), userName: spotifyHandler.auth.session.canonicalUsername, associatedGenres: [], associatedTracks: []);
            self.moodObject?.userName = self.spotifyHandler.auth.session.canonicalUsername!
            self.moodObject?.saveData(saveCompleteHandler: { (reference, error) in  })
            self.selectedGenres.removeAll()
            passDataToShowSong()
            //self.performSegue(withIdentifier: "showVideoSegue", sender: self);
        } else {
            let cell = genreCollectionView.cellForItem(at: indexPath) as! MoodViewCell
            //Get genre from section genre for section and row.
            let selectedGenre = sectionGenres[indexPath.section-1][indexPath.row].rawValue.lowercased()
            selectedGenres.updateValue(1, forKey: selectedGenre);
            cell.selectCell()
//            print("current Path = \(cell.borderPathLayer?.path)")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == self.genreCollectionView {
            let cell = genreCollectionView.cellForItem(at: indexPath) as! MoodViewCell
            if let genre = cell.moodLabel.text {
                selectedGenres.removeValue(forKey: genre.lowercased());
                cell.deselectCell()
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = genreCollectionView.cellForItem(at: indexPath)
        //cell?.selectAnimation()
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = genreCollectionView.cellForItem(at: indexPath)
        //cell?.deselectAnimation()
    }
    
}

extension SongPickerViewController: UICollectionViewDataSource {
//    
//    func indexTitles(for collectionView: UICollectionView) -> [String]? {
//        if collectionView == genreCollectionView {
//            return sectionTitles;
//        } else {
//            return nil
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, indexPathForIndexTitle title: String, at index: Int) -> IndexPath {
//        print(index);
//        return IndexPath(row: 1, section: 1)
//    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == moodCollectionView {
            return 1
        } else {
            return sectionTitles.count + 1
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.moodCollectionView {
            return EmotionDyad.allValues.count
        } else {
            if section > 0 {
                return getGenresForSection(section: section-1).count
            } else {
                return 0
            }
            
//            return genreList.count;
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            
            let headerCell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "collectionViewHeader", for: indexPath) as! CollectionViewHeader
            if collectionView == genreCollectionView {
                if indexPath.section == 0 {
                    headerCell.configure(label: "Genres")
                } else {
                    headerCell.configure(label: sectionTitles[indexPath.section-1]);
                }
                
            } else {
                headerCell.configure(label: "Moods")
            }
            
//            sectionHeaderFrame = headerCell.sectionHeaderLabel.frame
//            sectionHeaderFrame = CGRect(x: 16, y: 8, width: 0, height: 0)
            return headerCell
        } else {
            fatalError("Unknown reusable kind element");
        }
    
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var isLastRow: Bool = false
        let cell: MoodViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "moodCell", for: indexPath) as! MoodViewCell;
//        print("indexPath.row = \(indexPath.row)")
        if collectionView == self.moodCollectionView {
            let mood = EmotionDyad.allValues[indexPath.row].rawValue
            cell.moodLabel.text = "\(mood)"
            isLastRow = indexPath.row == EmotionDyad.allValues.count - 1
        } else {
            let genres = sectionGenres[indexPath.section-1]
            let genre = genres[indexPath.row].rawValue
            cell.moodLabel.text = "\(genre)"
            isLastRow = indexPath.row == genres.count - 1
        }
        
        DispatchQueue.main.async {
            cell.configure(for: indexPath.row, offsetRect: self.sectionHeaderFrame, isLastRow: isLastRow);
            cell.layoutIfNeeded()
        }
        
        return cell;

    }
    
}

extension SongPickerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sizeWidth = collectionView.frame.width
            //- sectionInsets.left;
        return CGSize(width: sizeWidth, height: collectionView.frame.height/10);
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return sectionInsets;
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0;
    }
    
}
