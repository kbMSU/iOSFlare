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

        appImageView.image = UIImage(named: "AppIcon")
        if let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = version
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
}
