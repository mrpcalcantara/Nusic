//
//  NusicPageViewController.swift
//  UIPageViewController Post
//
//  Created by Jeffrey Burt on 12/11/15.
//  Copyright © 2015 Atomic Object. All rights reserved.
//

import UIKit

class NusicPageViewController: UIPageViewController {
    
    weak var nusicDelegate: NusicPageViewControllerDelegate?
    
    var songPickerVC: UIViewController?
    var sideMenuVC: UIViewController?
    var showSongVC: UIViewController?
    var songListVC: UITabBarController?
    private var backgroundImageView: UIImageView!
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        // The view controllers will be shown in this order
        return []
    }()
    
    override func viewDidLayoutSubviews() {
        self.backgroundImageView?.frame = self.view.frame
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        
        songPickerVC = UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "SongPicker")
        showSongVC = UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "ShowSong")
        sideMenuVC = UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "SideMenu")
        songListVC = UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "SongList") as! UITabBarController
        
        if let sideMenuVC = sideMenuVC {
            orderedViewControllers.insert(sideMenuVC, at: 0)
        }
        
        if let songPickerVC = songPickerVC {
            orderedViewControllers.insert(songPickerVC, at: 1)
        }
        
        //Disable delay in order to facilitate the scrubbing for the track
        for view in view.subviews {
            if let myView = view as? UIScrollView {
                myView.delaysContentTouches = false
            }
        }

        if let image = UIImage(named: "BackgroundPattern") {
            backgroundImageView = UIImageView(frame: self.view.frame)
            backgroundImageView.contentMode = .scaleAspectFill
            backgroundImageView.image = image
            self.view.addSubview(backgroundImageView)
            self.view.sendSubview(toBack: backgroundImageView)
        }
        
        let initialViewController = orderedViewControllers[1]
        scrollToViewController(viewController: initialViewController)
        nusicDelegate?.nusicPageViewController(nusicPageViewController: self, didUpdatePageCount: orderedViewControllers.count)
        
        
    }
    
    @objc func addViewControllerToPageVC(viewController: UIViewController) {
        if !orderedViewControllers.contains(viewController) {
            orderedViewControllers.insert(viewController, at: orderedViewControllers.count)
            nusicDelegate?.nusicPageViewController(nusicPageViewController: self, didUpdatePageCount: orderedViewControllers.count)
        }
        
    }
    
    @objc func removeViewControllerFromPageVC(viewController: UIViewController) {
        if orderedViewControllers.contains(viewController) {
            if let index = orderedViewControllers.index(of: viewController) {
                orderedViewControllers.remove(at: index)
                nusicDelegate?.nusicPageViewController(nusicPageViewController: self, didUpdatePageCount: orderedViewControllers.count)
            }
        }
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
     Scrolls to the previous view controller.
     */
    func scrollToPreviousViewController() {
        if let visibleViewController = viewControllers?.first, let previousViewController = pageViewController(self, viewControllerBefore: visibleViewController) {
            scrollToViewController(viewController: previousViewController, direction: .reverse)
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
    func scrollToViewController(viewController: UIViewController,
                                        direction: UIPageViewControllerNavigationDirection = .forward) {
        setViewControllers([viewController],
                           direction: direction,
                           animated: true,
                           completion: nil)
    }
    
    /**
     Notifies '_nusicDelegate' that the current page index was updated.
     */
    private func notifyNusicDelegateOfNewIndex() {
        if let firstViewController = viewControllers?.first, let index = orderedViewControllers.index(of: firstViewController) {
            nusicDelegate?.nusicPageViewController(nusicPageViewController: self, didUpdatePageIndex: index)
        }
    }
    
}

// MARK: UIPageViewControllerDataSource

extension NusicPageViewController: UIPageViewControllerDataSource {
    
    func activateDataSource() {
        self.dataSource = self
    }
    
    func deactivateDataSource() {
        self.dataSource = nil
    }
    
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
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
}

extension NusicPageViewController : UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("started dragging")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scroll scroll")
    }
    
}

protocol NusicPageViewControllerDelegate: class {
    
    /**
     Called when the number of pages is updated.
     
     - parameter nusicPageViewController: the NusicPageViewController instance
     - parameter count: the total number of pages.
     */
    func nusicPageViewController(nusicPageViewController: NusicPageViewController,
                                    didUpdatePageCount count: Int)
    
    /**
     Called when the current index is updated.
     
     - parameter nusicPageViewController: the NusicPageViewController instance
     - parameter index: the index of the currently visible page.
     */
    func nusicPageViewController(nusicPageViewController: NusicPageViewController,
                                    didUpdatePageIndex index: Int)
    
}
