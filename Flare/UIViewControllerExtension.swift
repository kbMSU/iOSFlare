//
//  UIViewControllerExtension.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 5/15/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import Foundation

extension UIViewController : UIPopoverPresentationControllerDelegate {
    func showFlare(flare : Flare) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let flareViewController = storyboard.instantiateViewControllerWithIdentifier("FlareViewController") as! FlareViewController
        flareViewController.flare = flare
        
        presentViewController(flareViewController, animated: true, completion: nil)
    }
    
    func showFlarePopup(flare : Flare) {
        let storyboard = UIStoryboard(name: "Popover", bundle: nil)
        
        let flarePopup = storyboard.instantiateViewControllerWithIdentifier("ShowFlareViewController") as! FlarePopupViewController
        flarePopup.flare = flare
        flarePopup.modalPresentationStyle = .Popover
        flarePopup.preferredContentSize = CGSizeMake(view.frame.width*0.75, 200)
        
        let popoverPresentationController = flarePopup.popoverPresentationController
        popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        popoverPresentationController?.delegate = self
        popoverPresentationController?.sourceView = view
        popoverPresentationController?.sourceRect = CGRectMake(view.frame.midX, view.frame.midY, 0, 0)
        
        presentViewController(flarePopup, animated: true, completion: nil)
    }
    
    public func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
}