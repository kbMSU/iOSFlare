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
    }
    
    // MARK: ContactModule delegate
    
    func retreiveResult(result : ErrorTypes) {
        switch result {
        case .Error:
            // If could not find contacts then no point trying to check for friends with flare
            displayMessage("There was a problem getting your contacts")
            verifyPhoneNumber()
        case .Unauthorized,.None:
            findFriendsWithFlare()
        }
    }
    
    // MARK: BackendModule delegate
    
    func registrationError(error: ErrorType) {
        moveToMapScene()
    }
    
    func registrationSuccess() {
        moveToMapScene()
    }
    
    // MARK: Functions
    
    func loadContacts() {
        contactsModule!.authorizeContacts()
    }
    
    func findFriendsWithFlare() {
        // If not allowed to find friends with flare then just verify phone number
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
        // If phone number is already verified then register with the cloud
        if DataModule.haveVerifiedPhoneNumber {
            allowFriendsToFindYou()
            return
        }
        
        // Verify phone number, then register
        performSegueWithIdentifier("VerifyPhoneNumberSegue", sender: nil)
    }
    
    func allowFriendsToFindYou() {
        // If we are not allowed to register with the cloud then just move to the map scene
        if !DataModule.canAllowFriendsToFind {
            moveToMapScene()
            return
        }
        
        // Allow friends to find you
        backendModule!.register()
    }
    
    func moveToMapScene() {
        performSegueWithIdentifier("DoneLoadingSegue", sender: nil)
    }
    
    func displayMessage(message : String, title : String = "") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }

}
