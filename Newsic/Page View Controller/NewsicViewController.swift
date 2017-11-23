//
//  NewsicViewController.swift
//  UIPageViewController Post
//
//  Created by Jeffrey Burt on 2/3/16.
//  Copyright © 2016 Seven Even. All rights reserved.
//

import UIKit

class NewsicViewController: UIViewController {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var containerView: UIView!
    
    var newsicPageViewController: NewsicPageViewController? {
        didSet {
            newsicPageViewController?.newsicDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    //
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        if let newsicPageViewController = segue.destination as? NewsicPageViewController {
    //            self.newsicPageViewController = newsicPageViewController
    //        }
    //    }
    
}

extension NewsicViewController: NewsicPageViewControllerDelegate {
    
    func newsicPageViewController(newsicPageViewController: NewsicPageViewController,
                                    didUpdatePageCount count: Int) {
        
    }
    
    func newsicPageViewController(newsicPageViewController: NewsicPageViewController,
                                    didUpdatePageIndex index: Int) {
        
    }
    
}

