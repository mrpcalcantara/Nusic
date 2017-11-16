//
//  CustomInteractionController.swift
//  Newsic
//
//  Created by Miguel Alcantara on 14/11/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

class CustomInteractionController: UIPercentDrivenInteractiveTransition {
    
    
    var navigationController: UINavigationController!
    var shouldCompleteTransition = false
    var transitionInProgress = false
    var completionSeed: CGFloat {
        return 1 - percentComplete
    }
    
    func attachToViewController(viewController: UIViewController) {
        navigationController = viewController.navigationController
        setupGestureRecognizer(view: viewController.view)
    }
    
    private func setupGestureRecognizer(view: UIView) {
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:))))
    }
    
    @objc func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        let viewTranslation = gestureRecognizer.translation(in: gestureRecognizer.view!.superview!)
        print("viewTranslation = \(viewTranslation)")
        switch gestureRecognizer.state {
        case .began:
            transitionInProgress = true
            navigationController.popViewController(animated: true)
            print("began")
        case .changed:
            let progress = abs(Float(viewTranslation.x / 200.0))
            let const = CGFloat(fminf(fmaxf(progress, 0.0), 1.0))
            print("changed, const = \(const)")
            shouldCompleteTransition = const > 0.9
            update(const)
            
        case .cancelled, .ended:
            transitionInProgress = false
            print("ended")
            if !shouldCompleteTransition || gestureRecognizer.state == .cancelled {
                self.cancel()
            } else {
                self.finish()
            }
        default:
            print("Swift switch must be exhaustive, thus the default")
        }
    }
}
