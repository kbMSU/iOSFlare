//
//  SettingsViewController.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 4/27/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, ContactModuleDelegate, BackendModuleDelegate {
    
    // MARK: Variables
    
    var contactModule : ContactsModule!
    var backendModule : BackendModule!
    var reverse = false

    // MARK: Outlets
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var findFriendsSwitch: UISwitch!
    @IBOutlet weak var allowFriendsToFindYouSwitch: UISwitch!
    @IBOutlet weak var smsSwitch: UISwitch!
    @IBOutlet weak var cloudMessageSwitch: UISwitch!
    
    @IBOutlet weak var findFriendsBusyIndicator: UIActivityIndicatorView!
    @IBOutlet weak var friendsCanFindYouBusyIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var phoneNumberCell: UITableViewCell!
    @IBOutlet weak var defaultsCell: UITableViewCell!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contactModule = ContactsModule(delegate: self)
        backendModule = BackendModule(delegate: self)
        
        phoneNumberLabel.text = DataModule.myCountryCode+DataModule.myPhoneNumber
        findFriendsSwitch.on = DataModule.canFindFriendsWithFlare
        allowFriendsToFindYouSwitch.on = DataModule.canAllowFriendsToFind
        smsSwitch.on = !DataModule.canSendCloudMessage
        cloudMessageSwitch.on = DataModule.canSendCloudMessage
        
        findFriendsBusyIndicator.hidden = true
        friendsCanFindYouBusyIndicator.hidden = true
        
        smsSwitch.addTarget(self, action: #selector(smsSwitchChanged), forControlEvents: .ValueChanged)
        cloudMessageSwitch.addTarget(self, action: #selector(cloudMessageSwitchChanged), forControlEvents: .ValueChanged)
        
        findFriendsSwitch.addTarget(self, action: #selector(findFriendsSwitchChanged), forControlEvents: .ValueChanged)
        allowFriendsToFindYouSwitch.addTarget(self, action: #selector(allowFriendsToFindSwitchChanged), forControlEvents: .ValueChanged)
    }
    
    override func viewDidAppear(animated: Bool) {
        // In case the phone number was updated
        phoneNumberLabel.text = DataModule.myCountryCode+DataModule.myPhoneNumber
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Contact Module Delegate
    
    func retreiveResult(result: ErrorTypes) {
        switch result {
        case .Error:
            displayMessage("Error", message: "We could not get your contacts")
        case .Unauthorized:
            displayMessage("Permission Denied", message: "You denied us permision to check your contacts")
        case .None:
            backendModule.findFriendsWithFlare()
        }
    }
    
    // MARK: Backend Module Delegate
    
    func unregisterSuccess() {
        doneBeingBusy()
        DataModule.canAllowFriendsToFind = false
        
        var found = false
        for contact in DataModule.contacts {
            for number in contact.phoneNumbers {
                if number.digits.containsString(DataModule.myCountryCode+DataModule.myPhoneNumber) {
                    number.hasFlare = false
                    contact.hasFlare = false
                    found = true
                    break
                }
            }
            if found {
                break
            }
        }
    }
    
    func unregisterError(error: ErrorType) {
        doneBeingBusy()
        DataModule.canAllowFriendsToFind = true

        displayMessage("Error", message: "Something went wrong trying to unregister")
        
        reverse = true
        allowFriendsToFindYouSwitch.on = true
    }
    
    func registrationSuccess() {
        doneBeingBusy()
        DataModule.canAllowFriendsToFind = true
        
        var found = false
        for contact in DataModule.contacts {
            for number in contact.phoneNumbers {
                if number.digits.containsString(DataModule.myCountryCode+DataModule.myPhoneNumber) {
                    number.hasFlare = true
                    contact.hasFlare = true
                    found = true
                    break
                }
            }
            if found {
                break
            }
        }
    }
    
    func registrationError(error: ErrorType) {
        doneBeingBusy()
        DataModule.canAllowFriendsToFind = false

        displayMessage("Error", message: "Something went wrong while registering")
        
        reverse = true
        allowFriendsToFindYouSwitch.on = false
    }
    
    func findFriendsWithFlareSuccess() {
        doneBeingBusy()
        DataModule.canFindFriendsWithFlare = true
    }
    
    func findFriendsWithFlareError(error: ErrorType) {
        doneBeingBusy()
        DataModule.canFindFriendsWithFlare = false
        
        displayMessage("Error", message: "Something went wrong checking your contacts")
        
        reverse = true
        findFriendsSwitch.on = false
    }
    
    // MARK: Actions
    
    @IBAction func cancelAction(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Helpers
    
    func smsSwitchChanged() {
        if smsSwitch.on {
            DataModule.canSendCloudMessage = false
            if cloudMessageSwitch.on {
                cloudMessageSwitch.setOn(false, animated: true)
            }
        } else {
            DataModule.canSendCloudMessage = true
            if !cloudMessageSwitch.on {
                cloudMessageSwitch.setOn(true, animated: true)
            }
        }
    }
    
    func cloudMessageSwitchChanged() {
        if cloudMessageSwitch.on {
            DataModule.canSendCloudMessage = true
            if smsSwitch.on {
                smsSwitch.setOn(false, animated: true)
            }
        } else {
            DataModule.canSendCloudMessage = false
            if !smsSwitch.on {
                smsSwitch.setOn(true, animated: true)
            }
        }
    }
    
    func findFriendsSwitchChanged() {
        if reverse {
            reverse = false
            return
        }
        
        findFriendsBusyIndicator.hidden = false
        isBusy()
        if findFriendsSwitch.on {
            if !contactModule.isAuthorized() || DataModule.contacts.isEmpty {
                contactModule.authorizeContacts()
            } else {
                backendModule.findFriendsWithFlare()
            }
        } else {
            DataModule.canFindFriendsWithFlare = false
            for contact in DataModule.contacts where contact.hasFlare {
                contact.hasFlare = false
                for number in contact.phoneNumbers where number.hasFlare {
                    number.hasFlare = false
                }
            }
            doneBeingBusy()
        }
    }
    
    func allowFriendsToFindSwitchChanged() {
        if reverse {
            reverse = false
            return
        }
        
        friendsCanFindYouBusyIndicator.hidden = false
        isBusy()
        if allowFriendsToFindYouSwitch.on {
            backendModule.register()
        } else {
            backendModule.unregister()
        }
    }
    
    func isBusy() {
        smsSwitch.enabled = false
        cloudMessageSwitch.enabled = false
        findFriendsSwitch.enabled = false
        allowFriendsToFindYouSwitch.enabled = false
        cancelButton.enabled = false
        
        phoneNumberCell.userInteractionEnabled = false
        defaultsCell.userInteractionEnabled = false
    }
    
    func doneBeingBusy() {
        smsSwitch.enabled = true
        cloudMessageSwitch.enabled = true
        findFriendsSwitch.enabled = true
        allowFriendsToFindYouSwitch.enabled = true
        cancelButton.enabled = true
        
        phoneNumberCell.userInteractionEnabled = true
        defaultsCell.userInteractionEnabled = true
        
        findFriendsBusyIndicator.hidden = true
        friendsCanFindYouBusyIndicator.hidden = true
    }
    
    func displayMessage(title:String,message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
}
