//
//  ConfirmFlareViewController.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 2/29/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import UIKit
import MessageUI

class ConfirmFlareViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, BackendModuleDelegate, MFMessageComposeViewControllerDelegate {

    // MARK: Constants
    let cellIdentifier = "ContactTableViewCell"
    
    // MARK: Variables
    var contacts = [Contact]()
    var selectedContacts = [Contact]()
    var location : CLLocation?
    var backendModule : BackendModule?
    
    // MARK: Outlets
    @IBOutlet weak var contactTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        contactTableView.dataSource = self
        contactTableView.delegate = self
        
        contacts.sortInPlace {
            return $0.firstName + " " + $0.lastName < $1.firstName + " " + $1.lastName
        }
        for contact in contacts {
            contact.isSelected = true
        }
        selectedContacts.appendContentsOf(contacts)
        
        backendModule = BackendModule(delegate: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Table View DataSource/Delegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ContactTableViewCell
        let contactAtRow = contacts[indexPath.row]
        
        cell.selectedSwitch.on = contactAtRow.isSelected
        cell.contactNameLabel.text = contactAtRow.firstName + " " + contactAtRow.lastName
        cell.contactPrimaryPhoneLabel.text = contactAtRow.primaryPhone.digits
        cell.hasFlareImageView.hidden = !contactAtRow.hasFlare
        cell.contactImageView.image = contactAtRow.image
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ContactTableViewCell
        let contactAtRow = contacts[indexPath.row]
        
        contactAtRow.isSelected = !contactAtRow.isSelected
        cell.selectedSwitch.on = contactAtRow.isSelected
        if contactAtRow.isSelected {
            selectedContacts.append(contactAtRow)
        } else {
            let index = selectedContacts.indexOf({(selected) -> Bool in
                return selected.id == contactAtRow.id
            })
            selectedContacts.removeAtIndex(index!)
        }
        
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        
        if selectedContacts.isEmpty {
            noContactsSelected()
        } else {
            contactsSelected()
        }
    }
    
    // MARK: Actions
    
    @IBAction func sendClickAction(sender: UIButton) {
        var numbersWithFlare = [String]()
        var numbersWithoutFlare = [String]()
        
        for contact in selectedContacts {
            if contact.primaryPhone.hasFlare {
                numbersWithFlare.append(contact.primaryPhone.digits)
            } else {
                numbersWithoutFlare.append(contact.primaryPhone.digits)
            }
        }
        
        let latitude = "\(location!.coordinate.latitude)"
        let longitude = "\(location!.coordinate.longitude)"
        
        let flareMessage = messageTextField.text ?? "Flare"
        let noFlareMessage = flareMessage+" http://maps.google.com/?q="+latitude+","+longitude+"  "+"Sent from Flare"
        
        if numbersWithFlare.count != 0 {
            backendModule!.sendFlare(numbersWithFlare, message: flareMessage, location: location!)
        }
        
        if numbersWithoutFlare.count != 0 {
            if DataModule.canSendCloudMessage {
                backendModule!.sendTwilioMessage(numbersWithoutFlare, message: noFlareMessage)
            } else {
                let messageViewController = MFMessageComposeViewController()
                messageViewController.body = noFlareMessage
                messageViewController.recipients = numbersWithoutFlare
                messageViewController.messageComposeDelegate = self
                presentViewController(messageViewController, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: BackendModule Delegate
    
    func sendFlareSuccess() {
        
    }
    
    func sendFlareError(error: ErrorType) {
        
    }
    
    func sendTwilioMessageSuccess() {
        
    }
    
    func sendTwilioMessageError(error: ErrorType) {
        
    }
    
    // MARK: Message Delegate
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        switch result {
        case MessageComposeResultSent:
            break
        case MessageComposeResultCancelled:
            break
        case MessageComposeResultFailed:
            break
        default:
            break
        }
    }
    
    // MARK: Helper functions
    
    func noContactsSelected() {
        sendButton.hidden = true
        sendButton.enabled = false
    }
    
    func contactsSelected() {
        sendButton.hidden = false
        sendButton.enabled = true
    }
}
