//
//  UIPageViewController.swift
//  Newsic
//
//  Created by Miguel Alcantara on 19/04/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import Foundation

extension UIPageViewController {

    /**
     Scrolls to the given 'viewController' page.
     
     - parameter viewController: the view controller to show.
     */
    final func scrollToViewController(viewController: UIViewController,
                                direction: UIPageViewControllerNavigationDirection = .forward) {
        setViewControllers([viewController],
                           direction: direction,
                           animated: true,
                           completion: nil)
    }
    
}
