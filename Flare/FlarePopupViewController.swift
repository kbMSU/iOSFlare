//
//  FlarePopupViewController.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 5/15/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import UIKit

class FlarePopupViewController: PopupViewController {

    // MARK: Variables
    
    var flare : Flare!
    
    // MARK: Outlets
    
    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var viewButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var viewButtonHeight: NSLayoutConstraint!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        contactImageView.image = flare.image
        if flare.type == .IncomingFlare || flare.type == .OutgoingFlare {
            messageLabel.text = "\(flare.name) has sent you a flare"
        } else {
            messageLabel.text = "\(flare.name) says \"\(flare.message)\""
            viewButton.hidden = true
            viewButtonHeight.constant = 0
        }
        
        contactImageView.clipsToBounds = true
        contactImageView.layer.cornerRadius = contactImageView.frame.height/2
    }
    
    // MARK: Actions
    
    @IBAction func viewAction(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: {
            UIApplication.topViewController()!.showFlare(self.flare)
        })
    }
}
