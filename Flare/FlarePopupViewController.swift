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
        
        switch flare.type {
        case .IncomingFlare:
            messageLabel.text = "\(flare.name) has sent you a flare"
        case .OutgoingFlare:
            messageLabel.text = "You sent \(flare.name) a flare"
            viewButton.hidden = true
            viewButtonHeight.constant = 0
        case .IncomingResponse:
            messageLabel.text = "\(flare.name) says \"\(flare.message)\""
            viewButton.hidden = true
            viewButtonHeight.constant = 0
        case .OutgoingResponse:
            messageLabel.text = "You told \(flare.name) that \"\(flare.message)\""
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
