//
//  ConfirmFlareViewController.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 2/29/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import UIKit
import MessageUI

class ConfirmFlareViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, BackendModuleDelegate, MFMessageComposeViewControllerDelegate, UITextFieldDelegate, PhoneNumberPopoverDelegate {

    // MARK: Constants
    
    let cellIdentifier = "ContactTableViewCell"
    
    // MARK: Variables
    
    var contacts = [Contact]()
    var selectedContacts = [Contact]()
    var currentContact : Contact?
    var currentIndexPath : NSIndexPath?
    var location : CLLocation?
    var backendModule : BackendModule?
    var result : SendFlareResult?
    var popoverStoryboard = UIStoryboard(name: "Popover", bundle: nil)
    
    // MARK: Outlets
    
    @IBOutlet weak var contactTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet var topLevelView: UIView!
    
    // MARK: Lifecycle
    
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
        
        messageTextField.delegate = self
        
        backendModule = BackendModule(delegate: self)
        
        doneBeingBusy()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    // MARK: Phone number popover delegate
    
    func phoneNumberSelected(number: PhoneNumber) {
        currentContact!.primaryPhone = number
        currentContact!.isSelected = true
        selectedContacts.append(currentContact!)
        contactTableView.reloadRowsAtIndexPaths([currentIndexPath!], withRowAnimation: .None)
        contactsSelected()
    }
    
    // MARK: Text Field Delegate
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
        
        currentIndexPath = nil
        currentContact = nil
        
        if contactAtRow.isSelected {
            let index = selectedContacts.indexOf({(selected) -> Bool in
                return selected.id == contactAtRow.id
            })
            selectedContacts.removeAtIndex(index!)
            
            contactAtRow.isSelected = false
            cell.selectedSwitch.on = false
        } else {
            if contactAtRow.phoneNumbers.count > 1 {
                currentContact = contactAtRow
                currentIndexPath = indexPath
                
                let phoneNumberViewController = popoverStoryboard.instantiateViewControllerWithIdentifier("ChooseNumberViewController") as! PhoneNumberSelectionViewController
                phoneNumberViewController.phoneNumbers = contactAtRow.phoneNumbers
                phoneNumberViewController.modalPresentationStyle = .Popover
                phoneNumberViewController.preferredContentSize = CGSizeMake(200, 170)
                phoneNumberViewController.delegate = self
                
                let popoverController = phoneNumberViewController.popoverPresentationController
                popoverController?.permittedArrowDirections = .Any
                popoverController?.delegate = self
                popoverController?.sourceView = cell.contentView
                popoverController?.sourceRect = CGRectMake(cell.contentView.frame.midX, cell.contentView.frame.midY, 0, 0)
                
                presentViewController(phoneNumberViewController, animated: true, completion: nil)
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
    
    // MARK: Helper functions
    
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
            contactTableView.reloadData()
            
            let alert = UIAlertController(title: "Something went wrong", message: "We couldn't flare some of the people. The ones we could flare have been removed from your selection", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
            
        }
        else {
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
