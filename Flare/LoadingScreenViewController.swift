//
//  LoadingScreenViewController.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 2/24/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import UIKit

class LoadingScreenViewController: UIViewController, ContactModuleDelegate, BackendModuleDelegate {
    
    var backendModule : BackendModule?
    var contactsModule : ContactsModule?
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        DataModule.setup()
        
        backendModule = BackendModule(delegate: self)
        
        contactsModule = ContactsModule(delegate: self)
        if contactsModule!.isAuthorized() {
            loadContacts()
        } else {
            verifyPhoneNumber()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: ContactModuleDelegate
    
    func retreiveResult(result : ErrorTypes) {
        switch result {
        case .Error:
            displayMessage("There was a problem getting your contacts")
            verifyPhoneNumber()
        case .Unauthorized,.None:
            findFriendsWithFlare()
        }
    }
    
    // MARK: Functions
    
    func loadContacts() {
        contactsModule!.authorizeContacts()
    }
    
    func findFriendsWithFlare() {
        if !DataModule.canFindFriendsWithFlare {
            verifyPhoneNumber()
            return
        }
        
        // Find friends with flare
        backendModule!.findFriendsWithFlare()
        
        // Then verify phone number
        verifyPhoneNumber()
    }
    
    func verifyPhoneNumber() {
        if DataModule.haveVerifiedPhoneNumber {
            allowFriendsToFindYou()
            return
        }
        
        // Verify phone number, then register
        performSegueWithIdentifier("VerifyPhoneNumberSegue", sender: nil)
    }
    
    func allowFriendsToFindYou() {
        if !DataModule.canAllowFriendsToFind {
            moveToMapScene()
            return
        }
        
        // Allow friends to find you
        
        // Then move to map scene
    }
    
    func moveToMapScene() {
        performSegueWithIdentifier("DoneLoadingSegue", sender: nil)
    }
    
    func displayMessage(message : String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }

}
