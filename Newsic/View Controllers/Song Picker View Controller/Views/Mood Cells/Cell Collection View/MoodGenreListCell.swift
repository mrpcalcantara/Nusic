//
//  MoodGenreListCell.swift
//  Newsic
//
//  Created by Miguel Alcantara on 29/01/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import UIKit

protocol MoodGenreListCellDelegate: class {
    func didSelect(nusicType: NusicTypeSearch, section:Int, indexPath:IndexPath)
    func willDisplayCell(cell: MoodGenreCell, nusicType: NusicTypeSearch, section: Int, indexPath: IndexPath)
    
}

class MoodGenreListCell: UICollectionViewCell {

    @IBOutlet weak var listCollectionView: UICollectionView!
    
    static let reuseIdentifier: String? = "moodGenreListCell"
    
    var items: [String]?
    weak var delegate: MoodGenreListCellDelegate?
    var section: Int?
    var cellSize: CGSize?
    var nusicType: NusicTypeSearch?
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    convenience init(frame: CGRect, items: [String], nusicType: NusicTypeSearch) {
        self.init(frame: frame)
        self.items = items
        self.nusicType = nusicType
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.layer.shouldRasterize = true;
        self.layer.rasterizationScale = UIScreen.main.scale
        self.section = nil
//        self.cellSize = nil
        self.items?.removeAll()
        if self.listCollectionView.numberOfItems(inSection: 0) > 0 {
            self.listCollectionView.scrollRectToVisible(CGRect.zero, animated: false)
        }
        self.listCollectionView.dataSource = nil
        self.listCollectionView.reloadData()
       
        
    }
    
    func configure(for items: [String], section: Int, nusicType: NusicTypeSearch) {
        let view = UINib(nibName: MoodGenreCell.className, bundle: nil);
        
        self.listCollectionView.backgroundColor = NusicDefaults.deselectedColor
        self.listCollectionView.delegate = self;
        self.listCollectionView.dataSource = self;
        self.listCollectionView.allowsMultipleSelection = false;
        self.listCollectionView.register(view, forCellWithReuseIdentifier: "moodGenreCell");
        let layout = ListCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal

        self.items = items
        self.section = section
        self.nusicType = nusicType
    }
}

extension MoodGenreListCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let nusicType = nusicType {
            delegate?.didSelect(nusicType: nusicType, section: section!, indexPath: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let nusicType = nusicType {
            if let cell = cell as? MoodGenreCell {
                delegate?.willDisplayCell(cell: cell, nusicType: nusicType, section: section!, indexPath: indexPath)
            }
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? MoodGenreCell {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
                cell.moodGenreLabel.alpha = 0
                cell.backgroundImage.alpha = cell.highlightedAlpha
            }, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? MoodGenreCell {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
                
                cell.moodGenreLabel.alpha = 1
                cell.backgroundImage.alpha = cell.unhighlightedAlpha
            }, completion: nil)
        }
    }
}

extension MoodGenreListCell: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let items = items {
            return items.count
        }
        return 0
    }
    
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        print("showing indexPath: \(indexPath)")
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "moodGenreCell", for: indexPath) as? MoodGenreCell {
            cell.configure(text: items![indexPath.row])
            
            cell.layoutIfNeeded()
            
//            delegate?.willDisplayCell(section: section!, indexPath: indexPath)
            return cell;
        }
        
        return UICollectionViewCell();
    }
    
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
}


extension MoodGenreListCell: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let cellsPerRow:CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 2 : 1
        var sizeWidth = collectionView.bounds.width - collectionView.bounds.width/(cellsPerRow*6)
        sizeWidth = sizeWidth * 0.7
        cellSize = CGSize(width: sizeWidth, height: collectionView.bounds.height - collectionView.bounds.height/6)
        return cellSize!
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if let cellSize = cellSize {
            let inset = (collectionView.frame.width - cellSize.width)/2
            return UIEdgeInsetsMake(0, inset, 0, inset)
        }
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
}
