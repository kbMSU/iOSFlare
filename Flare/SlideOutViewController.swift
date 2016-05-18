//
//  SlideOutViewController.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 4/3/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import UIKit
import MessageUI

class SlideOutViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    // MARK: Variables
    
    var leftSwipeRecognizer : UISwipeGestureRecognizer!
    var menuStoryboard : UIStoryboard!
        
    // MARK: Outlets
    
    @IBOutlet weak var numberLabel: UILabel!
    
    @IBOutlet weak var historyButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var groupsButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var settingsButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var aboutButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var feedbackButtonWidth: NSLayoutConstraint!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        menuStoryboard = UIStoryboard(name: "Menu", bundle: nil)
        
        let text = "+"+DataModule.myCountryCode+DataModule.myPhoneNumber
        numberLabel.text = text
        
        let maxWidth = UIScreen.mainScreen().bounds.width - 120
        feedbackButtonWidth.constant = maxWidth
        historyButtonWidth.constant = maxWidth
        groupsButtonWidth.constant = maxWidth
        settingsButtonWidth.constant = maxWidth
        aboutButtonWidth.constant = maxWidth
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Mail Composer Delegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: Actions
    
    @IBAction func flareHistoryAction(sender: UIButton) {
        let flareHistoryController = menuStoryboard.instantiateViewControllerWithIdentifier("FlareHistoryViewController")
        presentViewController(flareHistoryController, animated: true, completion: nil)
    }
    
    @IBAction func groupsAction(sender: UIButton) {
        let groupsController = menuStoryboard.instantiateViewControllerWithIdentifier("GroupsViewController")
        presentViewController(groupsController, animated: true, completion: nil)
    }
    
    @IBAction func settingsAction(sender: UIButton) {
        let groupsController = menuStoryboard.instantiateViewControllerWithIdentifier("SettingsViewController")
        presentViewController(groupsController, animated: true, completion: nil)
    }
    
    @IBAction func aboutAction(sender: UIButton) {
        let aboutController = menuStoryboard.instantiateViewControllerWithIdentifier("AboutViewController")
        presentViewController(aboutController, animated: true, completion: nil)
    }
    
    @IBAction func feedbackAction(sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["support@shoresideapps.com"])
            mail.setSubject("Feedback")
            mail.setMessageBody("I have some feedback on the flare iOS app", isHTML: false)
            presentViewController(mail, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Setup Required", message: "This device is not set up to send emails", preferredStyle: .Alert)
            let action = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
            alert.addAction(action)
            presentViewController(alert, animated: true, completion: nil)
        }
    }
}
