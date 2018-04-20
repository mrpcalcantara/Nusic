//
//  OnboardingViewController.swift
//  Newsic
//
//  Created by Miguel Alcantara on 19/04/2018.
//  Copyright © 2018 Miguel Alcantara. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    @IBInspectable var showPageControl: Bool = false
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    
    weak var nusicDelegate: NusicPageViewControllerDelegate?
    var pageViewController: OnboardingPageViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl.currentPageIndicatorTintColor = NusicDefaults.foregroundThemeColor
        pageControl.pageIndicatorTintColor = NusicDefaults.whiteColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let pageViewController = segue.destination as? OnboardingPageViewController {
            pageViewController.nusicDelegate = self
            self.pageViewController = pageViewController
        }
    }
 
    @IBAction func pageControlClicked(_ sender: UIPageControl) {
        print(sender.currentPage)
        pageViewController?.scrollToViewController(for: sender.currentPage)
    }
    
}

extension OnboardingViewController: NusicPageViewControllerDelegate {
    
    func nusicPageViewController(nusicPageViewController: UIPageViewController,
                                 didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }
    
    func nusicPageViewController(nusicPageViewController: UIPageViewController,
                                 didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
    }
    
}

