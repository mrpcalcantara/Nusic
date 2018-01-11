//
//  CustomNavigationAnimationController.swift
//  Nusic
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
    
//    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//        // 1
//        guard let fromVC = transitionContext.viewController(forKey: .from),
//            let toVC = transitionContext.viewController(forKey: .to),
//            let snapshot = toVC.view.snapshotView(afterScreenUpdates: true)
//            else {
//                return
//        }
//
//        // 2
//        let containerView = transitionContext.containerView
//        let finalFrame = transitionContext.finalFrame(for: toVC)
//
//        // 3
//        snapshot.frame = originFrame
//        snapshot.layer.cornerRadius = CardViewController.cardCornerRadius
//        snapshot.layer.masksToBounds = true
//
//        // 1
//        containerView.addSubview(toVC.view)
//        containerView.addSubview(snapshot)
//        toVC.view.isHidden = true
//
//        // 2
//        AnimationHelper.perspectiveTransform(for: containerView)
//        snapshot.layer.transform = AnimationHelper.yRotation(.pi / 2)
//        // 3
//        let duration = transitionDuration(using: transitionContext)
//
//        // 1
//        UIView.animateKeyframes(
//            withDuration: duration,
//            delay: 0,
//            options: .calculationModeCubic,
//            animations: {
//                // 2
//                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/3) {
//                    fromVC.view.layer.transform = AnimationHelper.yRotation(-.pi / 2)
//                }
//
//                // 3
//                UIView.addKeyframe(withRelativeStartTime: 1/3, relativeDuration: 1/3) {
//                    snapshot.layer.transform = AnimationHelper.yRotation(0.0)
//                }
//
//                // 4
//                UIView.addKeyframe(withRelativeStartTime: 2/3, relativeDuration: 1/3) {
//                    snapshot.frame = finalFrame
//                    snapshot.layer.cornerRadius = 0
//                }
//        },
//            // 5
//            completion: { _ in
//                toVC.view.isHidden = false
//                snapshot.removeFromSuperview()
//                fromVC.view.layer.transform = CATransform3DIdentity
//                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
//        })
//
//    }
    
}
