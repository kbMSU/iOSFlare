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
    var result : SendFlareResult?
    
    // MARK: Outlets
    @IBOutlet weak var contactTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet var topLevelView: UIView!
    
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
        
        doneBeingBusy()
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
    
    // MARK: Backend Module delegate
    
    func sendFlareResult(result: SendFlareResult) {
        self.result = result
        
        if result.numbersToIMessage.isEmpty {
            finishedFlare()
        } else {
            let messageVc = MFMessageComposeViewController()
            messageVc.messageComposeDelegate = self
            messageVc.recipients = result.numbersToIMessage
            messageVc.body = result.message
            presentViewController(messageVc, animated: true, completion: nil)
        }
    }
    
    // MARK: Message Delegate
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        switch result {
        case MessageComposeResultSent,MessageComposeResultCancelled:
            finishedFlare()
        case MessageComposeResultFailed:
            self.result!.numbersFailedToSend.appendContentsOf(self.result!.numbersToIMessage)
            finishedFlare()
        default:
            finishedFlare()
        }
    }
    
    // MARK: Actions
    
    @IBAction func sendClickAction(sender: UIButton) {
        isBusy()
        
        let message = messageTextField.text ?? "Flare"
        var numbers = [PhoneNumber]()
        for contact in selectedContacts {
            numbers.append(contact.primaryPhone)
        }
        
        backendModule?.sendFlare(numbers, message: message, location: location!, sender: self)
    }
    
    // MARK: Helper functions
    
    func finishedFlare() {
        if result!.failed {
            let failedNumbers = result!.numbersFailedToSend
            var indexesToRemove = [Int]()
            for i in 0..<contacts.count {
                let contact = contacts[i]
                var matching : Contact?
                for failed in failedNumbers where contact.primaryPhone.digits == failed {
                    matching = contact
                }
                if matching == nil {
                    indexesToRemove.append(i)
                }
            }
            for index in indexesToRemove {
                contacts.removeAtIndex(index)
            }
            contactTableView.reloadData()
            
            let alert = UIAlertController(title: "Something went wrong", message: "We couldn't flare some of the people. The ones we could flare have been removed from your selection", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
            
        } else {
            let notification = UILocalNotification()
            notification.alertBody = "The flare has been sent !"
            notification.alertAction = "clear"
            notification.fireDate = NSDate()
            notification.soundName = UILocalNotificationDefaultSoundName
            notification.category = "Flare"
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
            
            navigationController?.popToRootViewControllerAnimated(true)
        }
        
        result = nil
    }
    
    func isBusy() {
        sendButton.enabled = false
        cancelButton.enabled = false
        overlayView.hidden = false
    }
    
    func doneBeingBusy() {
        sendButton.enabled = true
        cancelButton.enabled = true
        overlayView.hidden = true
    }
    
    func noContactsSelected() {
        sendButton.hidden = true
        sendButton.enabled = false
    }
    
    func contactsSelected() {
        sendButton.hidden = false
        sendButton.enabled = true
    }
}
