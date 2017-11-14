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
        //tapGestureRecognizer.delegate = self as! UIGestureRecognizerDelegate
        
        //moodCollectionView.addGestureRecognizer(tapGestureRecognizer)
        //genreCollectionView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func detectTap(_ tapRecognizer: UITapGestureRecognizer? = nil) {
        let view = self.view
        let location = tapRecognizer?.location(in: self.view)
        print("location in screen = \(location)")
        
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
//                let location = touch?.location(in: moodView)
//                if let location = location {
//
//                }
                
                let indexPath = moodView.indexPathForItem(at: location!)
                if let indexPath = indexPath {
                    let cell = genreCollectionView.cellForItem(at: indexPath) as! MoodViewCell
                    
                    moodView.delegate?.collectionView!(moodView, didSelectItemAt: indexPath)
                    print(location)
                }
            }
        }
    }
    
    func setupCollectionCellViews() {
        moodCollectionView.delegate = self;
        moodCollectionView.dataSource = self;
        moodCollectionView.allowsMultipleSelection = false;
        
        genreCollectionView.delegate = self;
        genreCollectionView.dataSource = self;
        genreCollectionView.allowsMultipleSelection = true;
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
    
    func toggleCollectionViews(for index: Int) {
        if index == 0 {
            showMoodCollectionView();
            hideGenreCollectionView();
            searchButton.isHidden = true;
            isMoodSelected = true
        } else {
            showGenreCollectionView();
            hideMoodCollectionView();
            searchButton.isHidden = false;
            isMoodSelected = false
        }
    }
}

extension SongPickerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.moodCollectionView {
            let cell = moodCollectionView.cellForItem(at: indexPath)
            cell?.animateSelection();
            self.searchButton.isUserInteractionEnabled = true;
            let dyad = EmotionDyad.allValues[indexPath.row]
            
            SwiftSpinner.show("Loading...", animated: true);
            
            let emotion = Emotion(basicGroup: dyad, detailedEmotions: [], rating: 0)
            self.moodObject = NewsicMood(emotions: [emotion], isAmbiguous: false, sentiment: 0.5, date: Date(), userName: spotifyHandler.auth.session.canonicalUsername, associatedGenres: [], associatedTracks: []);
            self.moodObject?.userName = self.spotifyHandler.auth.session.canonicalUsername!
            self.moodObject?.saveData(saveCompleteHandler: { (reference, error) in  })
            self.performSegue(withIdentifier: "showVideoSegue", sender: self);
        } else {
            let cell = genreCollectionView.cellForItem(at: indexPath) as! MoodViewCell
            selectedGenres.updateValue(1, forKey: genreList[indexPath.row].rawValue.lowercased());
            cell.selectCell()
            //print("current Path = \(cell.borderPathLayer?.path)")
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
        cell?.selectAnimation()
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = genreCollectionView.cellForItem(at: indexPath)
        cell?.deselectAnimation()
    }
}

extension SongPickerViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.moodCollectionView {
            return EmotionDyad.allValues.count
        } else {
            return genreList.count;
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let view = UINib(nibName: "MoodViewCell", bundle: nil);
        var cell: MoodViewCell;
        if collectionView == self.moodCollectionView {
            collectionView.register(view, forCellWithReuseIdentifier: "moodCell");
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "moodCell", for: indexPath) as! MoodViewCell
            //cell.backgroundColor = UIColor.lightGray;
            let mood = EmotionDyad.allValues[indexPath.row].rawValue
            cell.moodLabel.text = "\(mood)"
        } else {
            collectionView.register(view, forCellWithReuseIdentifier: "genreCell");
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "genreCell", for: indexPath) as! MoodViewCell
            //cell.backgroundColor = UIColor.gray;
            let genre = genreList[indexPath.row].rawValue
            cell.moodLabel.text = "\(genre)"
            if selectedGenres[genre] != nil {
                DispatchQueue.main.async {
                    let pathSublayer = cell.layer.sublayers!.first as! CAShapeLayer
                    pathSublayer.fillColor = UIColor.green.withAlphaComponent(0.2).cgColor
                }
                
            } else {
                //cell.backgroundColor = UIColor.lightGray
            }
            
        }
        //cell.layer.borderColor = UIColor.black.cgColor
        //cell.layer.borderWidth = 0.3
        DispatchQueue.main.async {
            cell.configure(for: indexPath.row);
            cell.layer.zPosition = 0
            cell.layoutIfNeeded()
        }

        
        return cell;
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
}

extension SongPickerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sizeWidth = collectionView.frame.width
            //- sectionInsets.left;
        return CGSize(width: sizeWidth/2, height: collectionView.frame.height/6);
    }
    /*
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets;
    }
    */
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0;
    }
    
    /*
 
     func drawPathForEven(view:UIView, width:CGFloat, height:CGFloat, index: Int) -> UIBezierPath {
     let initialWidth = width;
     let initialHeight = height
     let initialX:CGFloat = 0
     let initialY:CGFloat = height * 0.25;
     
     let bezierPath = UIBezierPath()
     bezierPath.move(to: CGPoint(x: initialX + 16, y: initialY));
     bezierPath.addLine(to: CGPoint(x: initialWidth - 16, y: initialY))
     bezierPath.addLine(to: CGPoint(x: initialWidth - 8, y: initialY+(initialHeight*0.25)))
     bezierPath.addLine(to: CGPoint(x: (initialWidth*0.5) + 12, y: initialY+(initialHeight*0.25)))
     bezierPath.addLine(to: CGPoint(x: (initialWidth*0.5) - 12, y: initialY+(initialHeight*0.75)))
     //bezierPath.addLine(to: CGPoint(x: initialX + 16, y: initialY+height))
     bezierPath.addLine(to: CGPoint(x: initialX + 8, y: initialY+(initialHeight*0.75)))
     bezierPath.addLine(to: CGPoint(x: initialX + 8, y: initialY+(initialHeight*0.25)))
     bezierPath.close()
     
     return bezierPath
     }
     
     func drawPathForOdd(width:CGFloat, height:CGFloat, index: Int) -> UIBezierPath {
     let initialWidth = width;
     let initialHeight = height
     let initialX:CGFloat = 0
     let initialY:CGFloat = height * -0.25 ;
     
     let bezierPath = UIBezierPath();
     bezierPath.move(to: CGPoint(x: initialX + 8, y: initialY+(initialHeight*0.75)))
     bezierPath.addLine(to: CGPoint(x: (initialWidth*0.5) - 12, y: initialY+(initialHeight*0.75)))
     bezierPath.addLine(to: CGPoint(x: (initialWidth*0.5) + 12, y: initialY+(initialHeight*0.25)))
     //bezierPath.addLine(to: CGPoint(x: width - 16, y: initialY))
     bezierPath.addLine(to: CGPoint(x: initialWidth - 8, y: initialY+(initialHeight*0.25)))
     bezierPath.addLine(to: CGPoint(x: initialWidth - 8, y: initialY+(initialHeight*0.75)))
     bezierPath.addLine(to: CGPoint(x: initialWidth - 16, y: initialY+(initialHeight)))
     bezierPath.addLine(to: CGPoint(x: initialX + 16, y: initialY+(initialHeight)))
     bezierPath.close()
     
     return bezierPath
     }
     */
    
    func drawPath(width:CGFloat, height:CGFloat) -> UIBezierPath {
        let width = width;
        let height = height;
        let initialX:CGFloat = 0
        let initialY:CGFloat = 0
        
        let bezierPath = UIBezierPath();
        bezierPath.move(to: CGPoint(x: initialX + 24, y: initialY))
        bezierPath.addLine(to: CGPoint(x: width - 24, y: initialY))
        bezierPath.addLine(to: CGPoint(x: width - 8, y: height*0.25))
        bezierPath.addLine(to: CGPoint(x: width - 8, y: height*0.75))
        bezierPath.addLine(to: CGPoint(x: width - 24, y: height))
        bezierPath.addLine(to: CGPoint(x: initialX + 24, y: height))
        bezierPath.addLine(to: CGPoint(x: initialX + 8, y: height*0.75))
        bezierPath.addLine(to: CGPoint(x: initialX + 8, y: height*0.25))
        bezierPath.close()
        
        return bezierPath
    }
}

extension SongPickerViewController {
    
}


