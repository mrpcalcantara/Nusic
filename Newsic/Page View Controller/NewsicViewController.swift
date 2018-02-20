//
//  NusicViewController.swift
//  UIPageViewController Post
//
//  Created by Jeffrey Burt on 2/3/16.
//  Copyright © 2016 Seven Even. All rights reserved.
//

import UIKit

class NusicViewController: UIViewController {
    
    
    @IBOutlet weak var containerView: UIView!
    
    var nusicPageViewController: NusicPageViewController? {
        didSet {
            nusicPageViewController?.nusicDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nusicPageViewController = segue.destination as? NusicPageViewController {
            self.nusicPageViewController = nusicPageViewController
        }
    }
    
    
}

extension NusicViewController: NusicPageViewControllerDelegate {
    
    func nusicPageViewController(nusicPageViewController: NusicPageViewController,
                                    didUpdatePageCount count: Int) {
        
    }
    
    func nusicPageViewController(nusicPageViewController: NusicPageViewController,
                                    didUpdatePageIndex index: Int) {
        
    }
    
}

