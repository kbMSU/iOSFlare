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
    
    var leftEdgePanRecognizer : UIScreenEdgePanGestureRecognizer!
    var leftSwipeRecognizer : UISwipeGestureRecognizer!
    var mainViewTapRecognizer : UITapGestureRecognizer!
    
    // MARK: Outlets

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var slideOutView: UIView!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let maxX = UIScreen.mainScreen().bounds.width
        mainViewTranslation = maxX - remainingAfterAnimation
        
        leftEdgePanRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(leftEdgePan(_:)))
        leftEdgePanRecognizer.edges = .Left
        leftEdgePanRecognizer.maximumNumberOfTouches = 1
        view.addGestureRecognizer(leftEdgePanRecognizer)
        
        leftSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(leftSwipeWhenSlideOutShowing(_:)))
        
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
            let remainingTranslation = finalPosition - mainViewX
            var remainingTime = animationDuration/Double(mainViewTranslation)*Double(remainingTranslation)
            if mainViewX < 50 {
                finalPosition = 0
                remainingTime = 0.1
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
    
    func leftSwipeWhenSlideOutShowing(sender : UISwipeGestureRecognizer) {
        
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
    }
}
