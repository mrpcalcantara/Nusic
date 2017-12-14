//
//  TransitionAnimation.swift
//  Newsic
//
//  Created by Miguel Alcantara on 30/11/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

extension SongPickerViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {
            return PresentAnimationController(originFrame: self.view.frame, interactionController: nil)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let showSongVC = dismissed as? ShowSongViewController else {
            return nil
        }
//        return DismissAnimationController(destinationFrame: self.view.frame, interactionController: showSongVC.swipeInteractionController)
        return DismissAnimationController(destinationFrame: self.view.frame, interactionController: nil)
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning? {
            guard let animator = animator as? DismissAnimationController,
                let interactionController = animator.interactionController,
                interactionController.interactionInProgress
                else {
                    return nil
            }
            return interactionController
    }

    
}
