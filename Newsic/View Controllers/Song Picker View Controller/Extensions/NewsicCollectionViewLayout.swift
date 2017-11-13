//
//  NewsicCollectionViewLayout.swift
//  Newsic
//
//  Created by Miguel Alcantara on 18/10/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

class NewsicCollectionViewLayout: UICollectionViewLayout {
    
    var preferredSize = CGSize(width: 200, height: 200)
    
    private let centerDiff: CGFloat = 40
    private var numberOfItems = 0
    
    private var updateItems = [UICollectionViewUpdateItem]()
    
    override func prepare() {
        super.prepare()
        numberOfItems = collectionView?.numberOfItems(inSection: 0) ?? 0
    }
    
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
        self.updateItems = updateItems
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    
    override var collectionViewContentSize: CGSize {
        if let collectionView = collectionView {
            
            let width = max(collectionView.bounds.width + 1, preferredSize.width + CGFloat((numberOfItems - 1)) * centerDiff)
            let height = collectionView.bounds.height - 1
            
            return CGSize(width: width, height: height)
        }
        return CGSize.zero
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var allAttributes = [UICollectionViewLayoutAttributes]()
        for index in 0 ..< numberOfItems {
            
            let indexPath = IndexPath(item: index, section: 0)
            allAttributes.append(layoutAttributesForItem(at: indexPath)!)
        }
        return allAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        attributes.size = preferredSize
        let centerX = preferredSize.width / 2.0
        let centerY = collectionView!.bounds.height / 2.0 + CGFloat(indexPath.item) * centerDiff
        attributes.center = CGPoint(x: centerX, y: centerY)
        attributes.zIndex = indexPath.item
        
        return attributes
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = layoutAttributesForItem(at: itemIndexPath)
        
        for updateItem in updateItems {
            switch updateItem.updateAction {
            case .insert:
                if updateItem.indexPathAfterUpdate == itemIndexPath {
                    let translation = collectionView!.bounds.height
                    attributes?.transform = CGAffineTransform(translationX: 0, y: translation)
                    break
                }
            default:
                break
            }
        }
        
        return attributes
    }
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        for updateItem in updateItems {
            switch updateItem.updateAction {
            case .delete:
                if updateItem.indexPathBeforeUpdate == itemIndexPath {
                    let attributes = layoutAttributesForItem(at: itemIndexPath)
                    let translation = collectionView!.bounds.height
                    attributes?.transform = CGAffineTransform(translationX: 0, y: translation)
                    return attributes
                }
            case .move:
                if updateItem.indexPathBeforeUpdate == itemIndexPath {
                    return layoutAttributesForItem(at: updateItem.indexPathAfterUpdate!)
                }
            default:
                break
            }
        }
        let finalIndex = finalIndexForIndexPath(indexPath: itemIndexPath)
        let shiftedIndexPath = IndexPath(item: finalIndex, section: itemIndexPath.section)
        
        return layoutAttributesForItem(at: shiftedIndexPath)
    }
    
    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        updateItems.removeAll(keepingCapacity: true)
    }
    
    private func finalIndexForIndexPath(indexPath: IndexPath) -> Int {
        var newIndex = indexPath.item
        for updateItem in updateItems {
            switch updateItem.updateAction {
            case .insert:
                if updateItem.indexPathAfterUpdate!.item <= newIndex {
                    newIndex += 1
                }
            case .delete:
                if updateItem.indexPathBeforeUpdate!.item < newIndex {
                    newIndex -= 1
                }
            case .move:
                if updateItem.indexPathBeforeUpdate!.item < newIndex {
                    newIndex -= 1
                }
                if updateItem.indexPathAfterUpdate!.item <= newIndex {
                    newIndex += 1
                }
            default:
                break
            }
        }
        return newIndex
    }
    
}
