//
//  SlideOutViewController.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 4/3/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import UIKit

class SlideOutViewController: UIViewController {
    
    var leftSwipeRecognizer : UISwipeGestureRecognizer!
        
    // MARK: Outlets
    
    @IBOutlet weak var profileButton: UIButton!
    
    @IBOutlet weak var profileButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var historyButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var groupsButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var settingsButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var aboutButtonWidth: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
}
