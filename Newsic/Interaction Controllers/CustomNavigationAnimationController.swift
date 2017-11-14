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
    var slideDirection: UISwipeGestureRecognizerDirection;
    
    init(direction: UISwipeGestureRecognizerDirection) {
        slideDirection = direction
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
//
//    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//        let containerView = transitionContext.containerView
//        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
//        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
//        let toView = toViewController.view
//        let fromView = fromViewController.view
//        let direction: CGFloat = reverse ? -1 : 1
//        let const: CGFloat = -0.005
//
//        let toViewAnchorPoint = direction == 1 ? CGPoint(x: 0, y: 0.5) : CGPoint(x: 1, y: 0.5)
//        let fromViewAnchorPoint = direction == 1 ? CGPoint(x: 1, y: 0.5) : CGPoint(x: 0, y: 0.5)
//        toView?.layer.anchorPoint = toViewAnchorPoint
//        fromView?.layer.anchorPoint = fromViewAnchorPoint
//
//        var viewFromTransform: CATransform3D = CATransform3DMakeRotation(direction * CGFloat(CGFloat.pi / 2), 0.0, 1.0, 0.0)
//        var viewToTransform: CATransform3D = CATransform3DMakeRotation(-direction * CGFloat(CGFloat.pi / 2), 0.0, 1.0, 0.0)
//        viewFromTransform.m34 = const
//        viewToTransform.m34 = const
//
//        containerView.transform = CGAffineTransform(translationX: direction * containerView.frame.size.width / 2.0, y: 0)
//        toView?.layer.transform = viewToTransform
//        containerView.addSubview(toView!)
//
//        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
//            containerView.transform = CGAffineTransform(translationX: -direction * containerView.frame.size.width / 2.0, y: 0)
//            fromView?.layer.transform = viewFromTransform
//            toView?.layer.transform = CATransform3DIdentity
//        }, completion: {
//            finished in
//            containerView.transform = CGAffineTransform.identity
//            fromView?.layer.transform = CATransform3DIdentity
//            toView?.layer.transform = CATransform3DIdentity
//            fromView?.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
//            toView?.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
//
//            if (transitionContext.transitionWasCancelled) {
//                toView?.removeFromSuperview()
//            } else {
//                fromView?.removeFromSuperview()
//            }
//            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
//        })
//    }

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
