//
//  NewsicPageViewController.swift
//  UIPageViewController Post
//
//  Created by Jeffrey Burt on 12/11/15.
//  Copyright © 2015 Atomic Object. All rights reserved.
//

import UIKit

class NewsicPageViewController: UIPageViewController {
    
    weak var newsicDelegate: NewsicPageViewControllerDelegate?
    
    var songPickerVC: UIViewController?
    var sideMenuVC: UIViewController?
    var showSongVC: UIViewController?
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        // The view controllers will be shown in this order
//        return [self.newColoredViewController(color: "Green"),
//                self.newColoredViewController(color: "Red"),
//                self.newColoredViewController(color: "Blue")]
        return []
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        
        
        songPickerVC = UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "SongPicker")
        sideMenuVC = UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "SideMenu")
        showSongVC = UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "ShowSong")
        
        if let sideMenuVC = sideMenuVC {
            orderedViewControllers.insert(sideMenuVC, at: 0)
        }
        
        if let songPickerVC = songPickerVC {
            orderedViewControllers.insert(songPickerVC, at: 1)
        }
        
//        if let showSongVC = showSongVC {
//            orderedViewControllers.insert(showSongVC, at: 2)
//        }
        
//        self.navigationController?.pushViewController(songPicker, animated: true)
//        self.navigationController?.pushViewController(songPicker, animated: true)
        let initialViewController = orderedViewControllers[1]
        scrollToViewController(viewController: initialViewController)
//        if let initialViewController = orderedViewControllers.last {
//            scrollToViewController(viewController: initialViewController)
//        }
        
        newsicDelegate?.newsicPageViewController(newsicPageViewController: self, didUpdatePageCount: orderedViewControllers.count)
        
    }
    
    /**
     Scrolls to the next view controller.
     */
    func scrollToNextViewController() {
        if let visibleViewController = viewControllers?.first, let nextViewController = pageViewController(self, viewControllerAfter: visibleViewController) {
            scrollToViewController(viewController: nextViewController)
        }
    }
    
    /**
     Scrolls to the view controller at the given index. Automatically calculates
     the direction.
     
     - parameter newIndex: the new index to scroll to
     */
    func scrollToViewController(index newIndex: Int) {
        if let firstViewController = viewControllers?.first, let currentIndex = orderedViewControllers.index(of: firstViewController) {
            let direction: UIPageViewControllerNavigationDirection = newIndex >= currentIndex ? .forward : .reverse
            let nextViewController = orderedViewControllers[newIndex]
            scrollToViewController(viewController: nextViewController, direction: direction)
        }
    }
    
    private func newColoredViewController(color: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "\(color)ViewController")
    }
    
    /**
     Scrolls to the given 'viewController' page.
     
     - parameter viewController: the view controller to show.
     */
    private func scrollToViewController(viewController: UIViewController,
                                        direction: UIPageViewControllerNavigationDirection = .forward) {
//        if !(viewController is ShowSongViewController) {
//
//        }
//        self.pageViewController(self, willTransitionTo: [viewController])
//        self.pageViewController(self, viewControllerAfter: viewController)
        setViewControllers([viewController],
                           direction: direction,
                           animated: true,
                           completion: { (finished) -> Void in
                            // Setting the view controller programmatically does not fire
                            // any delegate methods, so we have to manually notify the
                            // 'newsicDelegate' of the new index.
                            self.notifyNewsicDelegateOfNewIndex()
                            
        })
    }
    
    /**
     Notifies '_newsicDelegate' that the current page index was updated.
     */
    private func notifyNewsicDelegateOfNewIndex() {
        if let firstViewController = viewControllers?.first, let index = orderedViewControllers.index(of: firstViewController) {
            newsicDelegate?.newsicPageViewController(newsicPageViewController: self, didUpdatePageIndex: index)
        }
    }
    
}

// MARK: UIPageViewControllerDataSource

extension NewsicPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        
        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        
        
        return orderedViewControllers[nextIndex]
    }
    
}


extension NewsicPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        notifyNewsicDelegateOfNewIndex()
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        print("transitioning to \(pendingViewControllers.first.debugDescription)")
        self.pageViewController(self, viewControllerAfter: pendingViewControllers.first!)
    }
    
}

protocol NewsicPageViewControllerDelegate: class {
    
    /**
     Called when the number of pages is updated.
     
     - parameter newsicPageViewController: the NewsicPageViewController instance
     - parameter count: the total number of pages.
     */
    func newsicPageViewController(newsicPageViewController: NewsicPageViewController,
                                    didUpdatePageCount count: Int)
    
    /**
     Called when the current index is updated.
     
     - parameter newsicPageViewController: the NewsicPageViewController instance
     - parameter index: the index of the currently visible page.
     */
    func newsicPageViewController(newsicPageViewController: NewsicPageViewController,
                                    didUpdatePageIndex index: Int)
    
}