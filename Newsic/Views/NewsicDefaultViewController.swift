//
//  NewsicDefaultViewController.swift
//  Newsic
//
//  Created by Miguel Alcantara on 15/11/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

class NewsicDefaultViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage(named: "BackgroundPattern")
        if let image = image {
            let backgroundPattern = UIColor(patternImage: image)
            self.view.backgroundColor = backgroundPattern
        }
        let containerEffect = UIBlurEffect(style: .dark)
        let containerView = UIVisualEffectView(effect: containerEffect)
        containerView.alpha = 0.25
        containerView.frame = self.view.bounds
        containerView.tag = 111 // Blur Effect view Tag
        containerView.isUserInteractionEnabled = false // Edit: so that subview simply passes the event through to the button
        
        self.view.addSubview(containerView)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
