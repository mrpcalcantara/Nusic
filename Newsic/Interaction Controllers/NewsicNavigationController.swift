//
//  NusicNavigationController.swift
//  Nusic
//
//  Created by Miguel Alcantara on 15/11/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

class NusicNavigationController: UINavigationController, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate {

    //Transition Delegate
    var customNavigationAnimationController = CustomNavigationAnimationController()
    let customInteractionController = CustomInteractionController()
    
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        configure()
    }
    
    private func configure() {
        transitioningDelegate = self   // for presenting the original navigation controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return customInteractionController.transitionInProgress ? customInteractionController : nil
    }
    
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationControllerOperation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if operation == .push {
            customInteractionController.attachToViewController(viewController: toVC)
        }
        
        customNavigationAnimationController.reverse = operation == .pop
        return customNavigationAnimationController
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
