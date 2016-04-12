//
//  FlareViewController.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 4/12/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import UIKit

class FlareViewController: UIViewController, ContactModuleDelegate, BackendModuleDelegate {
    
    // MARK: Variables
    
    var phoneNumber : String!
    var message : String!
    var type : String!
    var contactModule : ContactsModule!
    var backendModule : BackendModule!
    
    // MARK: Outlets

    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var flareTypeMessage: UILabel!
    @IBOutlet weak var flareMessage: UILabel!
    @IBOutlet weak var respondButton: UIButton!
    @IBOutlet weak var overlayView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set outlets
        contactName.text = phoneNumber
        contactImage.image = UIImage(named: "defaultContactImage")
        flareMessage.text = message
        if type == "flare" {
            flareTypeMessage.text = "has flared you"
        } else {
            respondButton.hidden = true
            flareTypeMessage.text = "has responded to your flare"
        }
        
        contactModule = ContactsModule(delegate: self)
        if !contactModule!.isAuthorized() {
            let alert = UIAlertController(title: "Permission", message: "We can see if the person who flared you is in your contacts. Can we check ?", preferredStyle: .Alert)
            let noAction = UIAlertAction(title: "No", style: .Default, handler: nil)
            let yesAction = UIAlertAction(title: "Yes", style: .Default, handler: {(action:UIAlertAction) -> Void in
                self.isBusy()
                self.contactModule!.authorizeContacts()
            })
            alert.addAction(noAction)
            alert.addAction(yesAction)
            presentViewController(alert, animated: false, completion: nil)
        } else {
            doneBeingBusy()
            checkContacts()
        }
        
        backendModule = BackendModule(delegate: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Contact Module Delegate
    
    func retreiveResult(result: ErrorTypes) {
        doneBeingBusy()
        
        if result == ErrorTypes.None {
            checkContacts()
        }
    }
    
    // MARK: Backend Module Delegate
    
    func sendFlareResponseSuccess() {
        doneBeingBusy()
        let alert = UIAlertController(title: "Sent", message: "Your response has been sent", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: {
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    func sendFlareResponseError(error: ErrorType) {
        doneBeingBusy()
        let alert = UIAlertController(title: "Error", message: "There was an error sending your response", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: Actions
    
    @IBAction func respondAction(sender: UIButton) {
        let alert = UIAlertController(title: "Response", message: "Are you going to your friends flare ?", preferredStyle: .Alert)
        let noAction = UIAlertAction(title: "No", style: .Default, handler: {(action:UIAlertAction) -> Void in
            self.isBusy()
            self.backendModule!.declineFlare(self.phoneNumber!, message: DataModule.defaultDeclineMessage)
        })
        let yesAction = UIAlertAction(title: "Yes", style: .Default, handler: {(action:UIAlertAction) -> Void in
            self.isBusy()
            self.backendModule!.acceptFlare(self.phoneNumber!, message: DataModule.defaultAcceptMessage)
        })
        alert.addAction(noAction)
        alert.addAction(yesAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func dismissAction(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: Helper Methods
    
    func checkContacts() {
        var matchingContact : Contact? = nil
        for contact in DataModule.contacts where contact.hasFlare {
            for phone in contact.phoneNumbers where phone.hasFlare {
                if phone.digits == phoneNumber {
                    matchingContact = contact
                    break
                }
            }
        }
        
        // Update the outlets
        if let contact = matchingContact {
            contactImage.image = contact.image
            contactName.text = contact.firstName+" "+contact.lastName
        }
    }
    
    func isBusy() {
        overlayView.hidden = false
        respondButton.enabled = false
        dismissButton.enabled = false
    }
    
    func doneBeingBusy() {
        overlayView.hidden = true
        respondButton.enabled = true
        dismissButton.enabled = true
    }
}
