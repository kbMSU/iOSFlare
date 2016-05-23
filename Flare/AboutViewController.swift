//
//  AboutViewController.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 5/8/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var appImageView: UIImageView!
    @IBOutlet weak var versionLabel: UILabel!

    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = "Version \(version)"
        } else {
            versionLabel.text = "Version Unknown"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Actions

    @IBAction func DismissAction(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func privacyPolicyAction(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://flare.shoresideapps.com/privacy/")!)
    }
}
