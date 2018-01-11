////
////  SPTransitionDelegate.swift
////  Nusic
////
////  Created by Miguel Alcantara on 14/11/2017.
////  Copyright © 2017 Miguel Alcantara. All rights reserved.
////
//
//import UIKit
//
//extension ShowSongViewController : UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {
//
//    func setupTransitionDelegate() {
////        self.delegate = self;
//        self.transitioningDelegate = self;
//    }
//
//    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//        //return customInteractionController.transitionInProgress ? customInteractionController : nil
//        return customInteractionController
//    }
//
//    func navigationController(_ navigationController: UINavigationController,
//                              animationControllerFor operation: UINavigationControllerOperation,
//                              from fromVC: UIViewController,
//                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//
//        if operation == .push {
//
//            customInteractionController.attachToViewController(viewController: toVC)
//        }
//
//        customNavigationAnimationController.reverse = operation == .pop
//        return customNavigationAnimationController
//    }
//    
//    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//        return customInteractionController
//    }
//
//    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//        return customInteractionController
//    }
//
//
//}
//
//
