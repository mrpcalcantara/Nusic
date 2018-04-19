//
//  OnboardingViewController.swift
//  Newsic
//
//  Created by Miguel Alcantara on 19/04/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import UIKit

class OnboardingPageViewController: UIPageViewController {
    
    weak var nusicDelegate: NusicPageViewControllerDelegate?
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        // The view controllers will be shown in this order
        return []
    }()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        setupPickerVC()
        setupShowSongVC()
        setupSongListVC()
        setupNusicWeeklyVC()
        // Do any additional setup after loading the view.
        nusicDelegate?.nusicPageViewController(nusicPageViewController: self, didUpdatePageCount: orderedViewControllers.count)
        setViewControllers([orderedViewControllers.first!], direction: .forward, animated: true, completion: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    final func scrollToViewController(for index: Int) {
        guard let firstViewController = viewControllers?.first, let currentIndex = orderedViewControllers.index(of: firstViewController) else { return }
        let direction: UIPageViewControllerNavigationDirection = index >= currentIndex ? .forward : .reverse
        guard index >= 0 && index < orderedViewControllers.count else { return }
        scrollToViewController(viewController: orderedViewControllers[index], direction: direction)
    }
    
    fileprivate func setupPickerVC() {
        let pickerVC = OnboardingGeneralViewController(nibName: OnboardingGeneralViewController.className, bundle: nil)
        guard let image = UIDevice.current.userInterfaceIdiom == .pad ? UIImage(named: "SongPicker-iPad") : UIImage(named: "SongPicker") else { return }
        pickerVC.configure(image: image, text: "Select a mood and the app will present you with a customized playlist according to your music tastes")
        orderedViewControllers.append(pickerVC)
    }
    
    fileprivate func setupNusicWeeklyVC() {
        let nusicWeeklyVC = OnboardingGeneralViewController(nibName: OnboardingGeneralViewController.className, bundle: nil)
        guard let image = UIDevice.current.userInterfaceIdiom == .pad ? UIImage(named: "NusicWeekly-iPad") : UIImage(named: "NusicWeekly") else { return }
        nusicWeeklyVC.configure(image: image, text: "Stay tuned for our weekly featured artist and listen to his or her top tracks listed on Spotify")
        orderedViewControllers.append(nusicWeeklyVC)
    }
    
    fileprivate func setupShowSongVC() {
        let playerVC = OnboardingGeneralViewController(nibName: OnboardingGeneralViewController.className, bundle: nil)
        guard let image = UIDevice.current.userInterfaceIdiom == .pad ? UIImage(named: "ShowSong-iPad") : UIImage(named: "ShowSong") else { return }
        playerVC.configure(image: image, text: "You can like or dislike a song by swiping right or left or clicking the thumbs up or thumbs down button on the player menu")
        orderedViewControllers.append(playerVC)
    }
    
    fileprivate func setupSongListVC() {
        let songListVC = OnboardingGeneralViewController(nibName: OnboardingGeneralViewController.className, bundle: nil)
        guard let image = UIDevice.current.userInterfaceIdiom == .pad ? UIImage(named: "SongList-iPad") : UIImage(named: "SongList") else { return }
        songListVC.configure(image: image, text: "Check your liked tracks so far as well as our daily suggested track, which is based on the tracks you liked the day before")
        orderedViewControllers.append(songListVC)
    }
    
}

extension OnboardingPageViewController : UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed, let vc = viewControllers?.first, let index = orderedViewControllers.index(of: vc) else { return }
        nusicDelegate?.nusicPageViewController(nusicPageViewController: self, didUpdatePageIndex: index)
    }
}

extension OnboardingPageViewController : UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else { return nil; }
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        guard nextIndex < orderedViewControllers.count else { return nil; }
        
        return orderedViewControllers[nextIndex]
    }
    
}
