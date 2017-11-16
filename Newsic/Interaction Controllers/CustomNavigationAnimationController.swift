//
//  CustomNavigationAnimationController.swift
//  Newsic
//
//  Created by Miguel Alcantara on 14/11/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

class CustomNavigationAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    var reverse: Bool = false
    var slideDirection: UISwipeGestureRecognizerDirection = .up
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let finalFrameForVC = transitionContext.finalFrame(for: toViewController)
        let containerView = transitionContext.containerView
        let bounds = UIScreen.main.bounds
        let rectOffset = CGRect(origin: finalFrameForVC.origin, size: finalFrameForVC.size)
        var offsetDirection = self.slideDirection == .right ? rectOffset.offsetBy(dx: bounds.size.width, dy: 0) : rectOffset.offsetBy(dx: -bounds.size.width, dy: 0)

        if reverse {
            offsetDirection.origin.x = offsetDirection.origin.x * -1
        }
        toViewController.view.frame = offsetDirection
        containerView.addSubview(toViewController.view)

        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: .curveLinear, animations: {
            fromViewController.view.alpha = 0.5
            toViewController.view.frame = finalFrameForVC
        }, completion: {
            finished in
            transitionContext.completeTransition(true)
            fromViewController.view.alpha = 1.0
        })
    }
    
}
