//
//  SPTransitionDelegate.swift
//  Newsic
//
//  Created by Miguel Alcantara on 14/11/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

extension SongPickerViewController : UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {
    
    func setupTransitionDelegate() {
        self.navigationController?.delegate = self;
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
    
}

