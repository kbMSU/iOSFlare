//
//  SlideOutViewController.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 4/3/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import UIKit

class SlideOutViewController: UIViewController {
    
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

    // MARK: Actions
    
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
}
