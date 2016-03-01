//
//  LoadingScreenViewController.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 2/24/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import UIKit

class LoadingScreenViewController: UIViewController, ContactModuleDelegate {
    
    var contactsModule : ContactsModule?
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        DataModule.setup()
        
        contactsModule = ContactsModule(delegate: self)
        if contactsModule!.isAuthorized() {
            loadContacts()
        } else {
            moveToMapScene()
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
            moveToMapScene()
        case .Unauthorized,.None:
            moveToMapScene()
        }
    }
    
    // MARK: Functions
    
    func loadContacts() {
        contactsModule!.authorizeContacts()
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
