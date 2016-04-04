//
//  SlideOutTransitionController.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 4/3/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import Foundation
import UIKit

class SlideOutTransitionController: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    
    var snapshot : UIView!
    var isPresenting : Bool = true
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting{
            presentSlideOut(transitionContext)
        } else{
            dismissNavigation(transitionContext)
        }
    }
    
    func presentSlideOut(transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView()
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let fromView = fromViewController!.view
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let toView = toViewController!.view
        
        let size = toView.frame.size
        var offSetTransform = CGAffineTransformMakeTranslation(size.width - 160, 0)
        offSetTransform = CGAffineTransformScale(offSetTransform, 0.8, 0.8)
        
        snapshot = fromView.snapshotViewAfterScreenUpdates(true)
        
        container!.addSubview(toView)
        container!.addSubview(snapshot)
        
        let duration = transitionDuration(transitionContext)
        
        UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: UIViewAnimationOptions.TransitionNone,
            animations: {
             self.snapshot.transform = offSetTransform
            },
            completion: { finished in
                transitionContext.completeTransition(true)
            }
        )
    }
    
    func dismissNavigation(transitionContext: UIViewControllerContextTransitioning) {
        let duration = transitionDuration(transitionContext)
        
        UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options:
            UIViewAnimationOptions.TransitionNone,
            animations: {
                self.snapshot.transform = CGAffineTransformIdentity
            },
            completion: { finished in
                transitionContext.completeTransition(true)
                self.snapshot.removeFromSuperview()
            }
        )
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        return self
    }
}