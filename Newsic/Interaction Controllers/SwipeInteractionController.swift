//
//  CustomInteractionController.swift
//  Nusic
//
//  Created by Miguel Alcantara on 14/11/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit

class SwipeInteractionController: UIPercentDrivenInteractiveTransition {
    
    var interactionInProgress = false
    var interactionWasCancelled = false
    
    private var shouldCompleteTransition = false
    private weak var viewController: UIViewController!
    
    init(viewController: UIViewController) {
        super.init()
        self.viewController = viewController
        prepareGestureRecognizer(in: viewController.view)
    }

    private func prepareGestureRecognizer(in view: UIView) {
        let gesture = UIScreenEdgePanGestureRecognizer(target: self,
                                                       action: #selector(handleGesture(_:)))
        gesture.edges = .left
        view.addGestureRecognizer(gesture)
    }
    
    @objc func handleGesture(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view!.superview!)
        let divisor = gestureRecognizer.view != nil ? gestureRecognizer.view!.frame.width : 200
        var progress = (translation.x / divisor )
        progress = CGFloat(fminf(fmaxf(Float(progress), 0.0), 1.0))
        switch gestureRecognizer.state {
        case .began:
            interactionInProgress = true
            viewController.dismiss(animated: true, completion: nil)
            interactionWasCancelled = false
        case .changed:
            shouldCompleteTransition = progress > 0.5
            update(progress)
        case .cancelled:
            interactionInProgress = false
            cancel()
        case .ended:
            interactionInProgress = false
            if shouldCompleteTransition {
                finish()
            } else {
                interactionWasCancelled = true
                cancel()
            }
        default:
            break
        }
    }
    
}
