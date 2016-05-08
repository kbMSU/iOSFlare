//
//  MainContainerViewController.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 4/4/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import Foundation
import UIKit

class MainContainerViewController: UIViewController {
    
    let remainingAfterAnimation = CGFloat(120)
    let animationDuration = 0.5
    
    var mainViewTranslation : CGFloat!
    var showingSlideOut = false
    var leftPanStartingPoint : CGPoint?
    
    var leftEdgePanRecognizer : UIScreenEdgePanGestureRecognizer!
    var leftSwipeRecognizer : UIPanGestureRecognizer!
    var mainViewTapRecognizer : UITapGestureRecognizer!
    
    // MARK: Outlets

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var slideOutView: UIView!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SlideOutModule.setSlideOutManager(self)
        
        let maxX = UIScreen.mainScreen().bounds.width
        mainViewTranslation = maxX - remainingAfterAnimation
        
        leftEdgePanRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(leftEdgePan(_:)))
        leftEdgePanRecognizer.edges = .Left
        leftEdgePanRecognizer.maximumNumberOfTouches = 1
        view.addGestureRecognizer(leftEdgePanRecognizer)
        
        leftSwipeRecognizer = UIPanGestureRecognizer(target: self, action: #selector(leftSwipeWhenSlideOutShowing(_:)))
        leftSwipeRecognizer.minimumNumberOfTouches = 1
        leftSwipeRecognizer.maximumNumberOfTouches = 1
        view.addGestureRecognizer(leftSwipeRecognizer)
        
        mainViewTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapMainViewWhenSlideOutShowing(_:)))
        mainViewTapRecognizer.numberOfTouchesRequired = 1
        mainViewTapRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(mainViewTapRecognizer)
        
        slideOutClosed()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
        closeSlideOut()
    }

    // MARK: Helper
    
    func leftEdgePan(sender : UIScreenEdgePanGestureRecognizer) {
        let senderX = sender.locationInView(self.view).x
        let mainViewX = mainView.frame.origin.x
        
        switch sender.state {
        case .Ended,.Cancelled,.Failed:
            if senderX > mainViewTranslation {
                return
            }
            
            var finalPosition = mainViewTranslation
            var remainingTranslation = finalPosition - mainViewX
            var remainingTime = animationDuration/Double(mainViewTranslation)*Double(remainingTranslation)
            if sender.velocityInView(self.view).x < 0 {
                finalPosition = 0
                remainingTranslation = mainViewX
                remainingTime = animationDuration/Double(mainViewTranslation)*Double(remainingTranslation)
                showingSlideOut = false
            } else {
                showingSlideOut = true
            }
            
            UIView.animateWithDuration(remainingTime, animations: {
                self.mainView.frame.origin.x = finalPosition
                }, completion: { (result: Bool) in
                    if self.showingSlideOut {
                        self.slideOutOpened()
                    } else {
                        self.slideOutClosed()
                    }
                }
            )
            
        default:
            isSliding()
            
            if senderX < 0 {
                mainView.frame.origin.x = 0
            } else if senderX < mainViewTranslation {
                mainView.frame.origin.x = senderX
            } else {
                mainView.frame.origin.x = mainViewTranslation
            }

        }
    }
    
    func leftSwipeWhenSlideOutShowing(sender : UIPanGestureRecognizer) {
        let point = sender.locationInView(self.view)
        
        if leftPanStartingPoint == nil {
            if point.x < mainViewTranslation {
                return
            }
            
            leftPanStartingPoint = point
        } else {
            switch sender.state {
            case .Ended,.Cancelled,.Failed:
                if point.x > leftPanStartingPoint!.x {
                    return
                }
                
                let currentX = mainView.frame.origin.x
                var destinationX = CGFloat(0)
                var distance = currentX - destinationX
                var time = animationDuration/Double(mainViewTranslation)*Double(distance)
                if sender.velocityInView(self.view).x > 0 {
                    destinationX = mainViewTranslation
                    distance = destinationX - currentX
                    time = animationDuration/Double(mainViewTranslation)*Double(distance)
                    showingSlideOut = true
                } else {
                    showingSlideOut = false
                }
                
                UIView.animateWithDuration(time, animations: {
                    self.mainView.frame.origin.x = destinationX
                    }, completion: { (result: Bool) in
                        if self.showingSlideOut {
                            self.slideOutOpened()
                        } else {
                            self.slideOutClosed()
                        }
                    }
                )
                
            default:
                isSliding()
                
                if point.x <= 0 {
                    mainView.frame.origin.x = 0
                    return
                }
                
                let distance = leftPanStartingPoint!.x - point.x
                if distance > 0 {
                    mainView.frame.origin.x = mainViewTranslation - distance
                } else {
                    mainView.frame.origin.x = mainViewTranslation
                }
            }
        }
    }
    
    func tapMainViewWhenSlideOutShowing(sender : UITapGestureRecognizer) {
        let senderX = sender.locationInView(self.view).x
        
        if senderX >= mainViewTranslation {
            isSliding()
            UIView.animateWithDuration(self.animationDuration, animations: {
                self.mainView.frame.origin.x = 0
                }, completion: { (result: Bool ) in
                    self.showingSlideOut = false
                    self.slideOutClosed()
                }
            )
        }
    }
    
    func slideOut() {
        isSliding()
        
        UIView.animateWithDuration(animationDuration, animations: {
            self.mainView.frame.origin.x = self.mainViewTranslation
            }, completion: { (result: Bool) in
                self.showingSlideOut = true
                self.slideOutOpened()
            }
        )
    }
    
    func closeSlideOut() {
        isSliding()
        
        UIView.animateWithDuration(animationDuration, animations: {
            self.mainView.frame.origin.x = 0
            }, completion: { (result: Bool) in
                self.showingSlideOut = false
                self.slideOutClosed()
            }
        )
    }
    
    func isSliding() {
        mainView.userInteractionEnabled = false
        slideOutView.userInteractionEnabled = false
    }
    
    func slideOutClosed() {
        mainView.userInteractionEnabled = true
        slideOutView.userInteractionEnabled = false
        
        leftEdgePanRecognizer.enabled = true
        leftSwipeRecognizer.enabled = false
        mainViewTapRecognizer.enabled = false
    }
    
    func slideOutOpened() {
        mainView.userInteractionEnabled = false
        slideOutView.userInteractionEnabled = true
        
        leftEdgePanRecognizer.enabled = false
        leftSwipeRecognizer.enabled = true
        mainViewTapRecognizer.enabled = true
        
        leftPanStartingPoint = nil
    }
}
