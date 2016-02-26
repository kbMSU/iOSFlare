//
//  LoadingScreenViewController.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 2/24/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import UIKit

class LoadingScreenViewController: UIViewController, ContactModuleDelegate {

    // MARK: Properties
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        loadContacts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: CallBack
    
    func retreiveResult(result : ErrorTypes) {
        switch result {
        case .Error:
            displayMessage("There was a problem retreiving your contacts")
        case .Unauthorized,.None:
            moveToMapScene()
        }
    }
    
    // MARK: Functions
    
    func loadContacts() {
        let contactsModule = ContactsModule(delegate: self)
        contactsModule.authorizeContacts()
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
