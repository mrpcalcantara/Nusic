//
//  SongKolodaView.swift
//  Newsic
//
//  Created by Miguel Alcantara on 29/08/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//


import UIKit
import Koloda

let defaultTopOffset: CGFloat = 20
let defaultHorizontalOffset: CGFloat = 10
let defaultHeightRatio: CGFloat = 1.25
let backgroundCardHorizontalMarginMultiplier: CGFloat = 0.25
let backgroundCardScalePercent: CGFloat = 1.5

class SongKolodaView: KolodaView {
    
    override func frameForCard(at index: Int) -> CGRect {
        
        if index == 0 {
            let topOffset: CGFloat = defaultTopOffset
            let xOffset: CGFloat = defaultHorizontalOffset
            let width = (self.frame).width
            let height = (self.frame).height
            let yOffset: CGFloat = topOffset
            let frame = CGRect(x: 0, y: 0, width: width, height: height)
            
            return frame
        }
        
        else if index == 1 {
            let horizontalMargin = -self.bounds.width
            let width = self.bounds.width
            let height = width * defaultHeightRatio
            return CGRect(x: 0, y: -self.bounds.height-150, width: width, height: height)
        }
 
        return CGRect.zero
    }
 
}
