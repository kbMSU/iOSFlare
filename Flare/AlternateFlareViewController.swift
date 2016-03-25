//
//  AlternateFlareViewController.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 3/17/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import UIKit

class AlternateFlareViewController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var smsSwitch: UISwitch!
    @IBOutlet weak var cloudSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        smsSwitch.addTarget(self, action: "smsSwitchChanged", forControlEvents: .ValueChanged)
        cloudSwitch.addTarget(self, action: "cloudSwitchChanged", forControlEvents: .ValueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Transition
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if smsSwitch.on {
            DataModule.canSendCloudMessage = false
        } else {
            DataModule.canSendCloudMessage = true
        }
    }
    
    // MARK: Helper methods
    
    func smsSwitchChanged() {
        if smsSwitch.on {
            if cloudSwitch.on {
                cloudSwitch.setOn(false, animated: true)
            }
        } else {
            if !cloudSwitch.on {
                cloudSwitch.setOn(true, animated: true)
            }
        }
    }
    
    func cloudSwitchChanged() {
        if cloudSwitch.on {
            if smsSwitch.on {
                smsSwitch.setOn(false, animated: true)
            }
        } else {
            if !smsSwitch.on {
                smsSwitch.setOn(true, animated: true)
            }
        }
    }}
