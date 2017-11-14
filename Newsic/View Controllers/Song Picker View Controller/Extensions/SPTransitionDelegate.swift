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
    
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationControllerOperation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        //INFO: use UINavigationControllerOperation.push or UINavigationControllerOperation.pop to detect the 'direction' of the navigation
        
        class FadeAnimation: NSObject, UIViewControllerAnimatedTransitioning {
            func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
                return 0.5
            }
            
            func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
                let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
                if let vc = toViewController {
                    transitionContext.finalFrame(for: vc)
                    transitionContext.containerView.addSubview(vc.view)
                    vc.view.alpha = 0.0
                    UIView.animate(withDuration: self.transitionDuration(using: transitionContext),
                                   animations: {
                                    vc.view.alpha = 1.0
                    },
                                   completion: { finished in
                                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                    })
                } else {
                    NSLog("Oops! Something went wrong! 'ToView' controller is nill")
                }
            }
        }
        
        return FadeAnimation()
    }
}

