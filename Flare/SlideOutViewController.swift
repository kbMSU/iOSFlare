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
    
    @IBOutlet weak var profileButton: UIButton!
    
    @IBOutlet weak var profileButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var historyButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var groupsButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var settingsButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var aboutButtonWidth: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        menuStoryboard = UIStoryboard(name: "Menu", bundle: nil)
        
        let text = "+"+DataModule.myCountryCode+DataModule.myPhoneNumber
        profileButton.setTitle(text, forState: .Normal)
        
        let maxWidth = UIScreen.mainScreen().bounds.width - 120
        profileButtonWidth.constant = maxWidth
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
}
