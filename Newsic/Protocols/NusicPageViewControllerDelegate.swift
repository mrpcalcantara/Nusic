//
//  NusicPageViewControllerDelegate.swift
//  Newsic
//
//  Created by Miguel Alcantara on 19/04/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import Foundation

protocol NusicPageViewControllerDelegate: class {
    
    /**
     Called when the number of pages is updated.
     
     - parameter nusicPageViewController: the UIPageViewController instance
     - parameter count: the total number of pages.
     */
    func nusicPageViewController(nusicPageViewController: UIPageViewController,
                                 didUpdatePageCount count: Int)
    
    /**
     Called when the current index is updated.
     
     - parameter nusicPageViewController: the UIPageViewController instance
     - parameter index: the index of the currently visible page.
     */
    func nusicPageViewController(nusicPageViewController: UIPageViewController,
                                 didUpdatePageIndex index: Int)
    
}
