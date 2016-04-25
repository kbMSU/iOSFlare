//
//  SelectGroupViewController.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 4/24/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import UIKit
import MessageUI

class SelectGroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, BackendModuleDelegate, MFMessageComposeViewControllerDelegate, UITextFieldDelegate {
    
    // MARK: Constants
    
    let cellIdentifier = "ContactTableViewCell"
    
    // MARK: Variables
    
    var group : Group!
    var contacts = [Contact]()
    var selectedContacts = [Contact]()
    var location : CLLocation?
    var backendModule : BackendModule?
    var result : SendFlareResult?
    
    // MARK: Outlets
    
    @IBOutlet var contactsTableView: UITableView!
    @IBOutlet var messageTextField: UITextField!
    @IBOutlet var sendFlareButton: UIButton!
    @IBOutlet var titleItem: UINavigationItem!
    @IBOutlet var overlayView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        titleItem.title = group.name
        contacts.appendContentsOf(group.contacts)
        selectedContacts.appendContentsOf(contacts)
        
        for contact in contacts {
            contact.isSelected = true
        }
        
        backendModule = BackendModule(delegate: self)
        contactsTableView.delegate = self
        contactsTableView.dataSource = self
        messageTextField.delegate = self
        
        location = DataModule.currentLocation
        
        doneBeingBusy()
    }
    
    // MARK: Actions
    
    @IBAction func sendFlareAction(sender: UIButton) {
        if location == nil {
            displayError("We could not get your location")
            return
        }
        
        isBusy()
        var message = messageTextField.text
        if message == nil || message == "" {
            message = DataModule.defaultFlareMessage
        }
        var numbers = [PhoneNumber]()
        for contact in selectedContacts {
            numbers.append(contact.primaryPhone)
        }
        
        backendModule?.sendFlare(numbers, message: message!, location: location!, sender: self)
    }
    
    // MARK: TextField Delegate
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
    
    // MARK: TableView Delegate/DataSource
    
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
        if !contactAtRow.hasFlare {
            cell.hasFlareImageView.hidden = true
            cell.hasFlareImageWidthConstraint.constant = 0
        } else {
            cell.hasFlareImageView.hidden = false
            cell.hasFlareImageWidthConstraint.constant = CGFloat(cell.hasFlareImageDimension)
        }
        cell.contactImageView.image = contactAtRow.image
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ContactTableViewCell
        let contactAtRow = contacts[indexPath.row]
        
        if contactAtRow.isSelected {
            let index = selectedContacts.indexOf({(selected) -> Bool in
                return selected.id == contactAtRow.id
            })
            selectedContacts.removeAtIndex(index!)
            
            contactAtRow.isSelected = false
            cell.selectedSwitch.on = false
        } else {
            if contactAtRow.phoneNumbers.count > 1 {
                let alert = UIAlertController(title: "Choose number", message: "This contact has multiple phone numbers, please choose a number to flare to", preferredStyle: .ActionSheet)
                let image = UIImage(named: "fireRedIcon")
                for number in contactAtRow.phoneNumbers {
                    let action = UIAlertAction(title: number.digits, style: .Default, handler: {(action) -> Void in
                        contactAtRow.primaryPhone = number
                        contactAtRow.isSelected = true
                        cell.selectedSwitch.on = true
                        self.selectedContacts.append(contactAtRow)
                        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                        self.contactsSelected()
                    })
                    if number.hasFlare {
                        action.setValue(image, forKey: "image")
                    }
                    alert.addAction(action)
                }
                alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
                alert.view.tintColor = Constants.flareRedColor
                presentViewController(alert, animated: true, completion: nil)
            } else {
                contactAtRow.isSelected = true
                cell.selectedSwitch.on = true
                self.selectedContacts.append(contactAtRow)
            }
            
        }
        
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        
        if selectedContacts.isEmpty {
            noContactsSelected()
        } else {
            contactsSelected()
        }
    }
    
    // MARK: Helpers
    
    func finishedFlare() {
        doneBeingBusy()
        
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
            contactsTableView.reloadData()
            
            let alert = UIAlertController(title: "Something went wrong", message: "We couldn't flare some of the people. The ones we could flare have been removed from your selection", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
            
        }
        else {
            navigationController?.popToRootViewControllerAnimated(true)
        }
        
        result = nil
    }
    
    func displayError(message : String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func contactsSelected() {
        sendFlareButton.hidden = false
    }
    
    func noContactsSelected() {
        sendFlareButton.hidden = true
    }
    
    func isBusy() {
        overlayView.hidden = false
        sendFlareButton.enabled = false
    }
    
    func doneBeingBusy() {
        overlayView.hidden = true
        sendFlareButton.enabled = true
    }
}
