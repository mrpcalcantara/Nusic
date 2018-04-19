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
    var nusicWeeklyVC: UIViewController?
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
        nusicWeeklyVC = UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "NusicWeekly")
        
        if let sideMenuVC = sideMenuVC {
            orderedViewControllers.insert(sideMenuVC, at: 0)
        }
        
        if let nusicWeeklyVC = nusicWeeklyVC {
            orderedViewControllers.insert(nusicWeeklyVC, at: 1)
        }
        
        if let songPickerVC = songPickerVC {
            orderedViewControllers.insert(songPickerVC, at: 2)
        }
        
        
        
        
        
        //Disable delay in order to facilitate the scrubbing for the track
        for view in view.subviews {
            guard let myView = view as? UIScrollView else { break }
            myView.delaysContentTouches = false
        }

        if let image = UIImage(named: "BackgroundPattern") {
            backgroundImageView = UIImageView(frame: self.view.frame)
            backgroundImageView.contentMode = .scaleAspectFill
            backgroundImageView.image = image
            self.view.addSubview(backgroundImageView)
            self.view.sendSubview(toBack: backgroundImageView)
        }
        
        
        nusicDelegate?.nusicPageViewController(nusicPageViewController: self, didUpdatePageCount: orderedViewControllers.count)
        
        
    }
    
    @objc func addViewControllerToPageVC(viewController: UIViewController) {
        guard !orderedViewControllers.contains(viewController) else { return }
        orderedViewControllers.insert(viewController, at: orderedViewControllers.count)
        nusicDelegate?.nusicPageViewController(nusicPageViewController: self, didUpdatePageCount: orderedViewControllers.count)
    }
    
    @objc func removeViewControllerFromPageVC(viewController: UIViewController) {
        guard orderedViewControllers.contains(viewController), let index = orderedViewControllers.index(of: viewController) else { return }
        orderedViewControllers.remove(at: index)
        nusicDelegate?.nusicPageViewController(nusicPageViewController: self, didUpdatePageCount: orderedViewControllers.count)
    }
    
    /**
     Scrolls to the next view controller.
     */
    func scrollToNextViewController() {
        guard let visibleViewController = viewControllers?.first, let nextViewController = pageViewController(self, viewControllerAfter: visibleViewController) else { return }
        scrollToViewController(viewController: nextViewController)
    }
    
    /**
     Scrolls to the previous view controller.
     */
    func scrollToPreviousViewController() {
        guard let visibleViewController = viewControllers?.first, let previousViewController = pageViewController(self, viewControllerBefore: visibleViewController) else { return }
        scrollToViewController(viewController: previousViewController, direction: .reverse)
    }
    
    /**
     Scrolls to the view controller at the given index. Automatically calculates
     the direction.
     
     - parameter newIndex: the new index to scroll to
     */
    func scrollToViewController(index newIndex: Int) {
        guard let firstViewController = viewControllers?.first, let currentIndex = orderedViewControllers.index(of: firstViewController) else { return }
        let direction: UIPageViewControllerNavigationDirection = newIndex >= currentIndex ? .forward : .reverse
        let nextViewController = orderedViewControllers[newIndex]
        scrollToViewController(viewController: nextViewController, direction: direction)
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
