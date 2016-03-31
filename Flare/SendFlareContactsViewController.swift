//
//  SendFlareContactsViewController.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 2/23/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import UIKit
import MapKit

class SendFlareContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, BackendModuleDelegate {

    // MARK: Constants
    let cellIdentifier = "ContactTableViewCell"
    
    // MARK: Variables
    var userLocation : CLLocation?
    var unfilteredContacts = [Contact]()
    var contacts = [Contact]()
    var selectedContacts = [Contact]()
    var backendModule : BackendModule?
    var initialized = false
    var timer : NSTimer?
    
    // MARK: Outlets
    @IBOutlet weak var contactsTableView: UITableView!
    @IBOutlet weak var searchContactsTextField: UITextField!
    @IBOutlet weak var doneSelectingButton: UIButton!
    @IBOutlet weak var clearButton: UIBarButtonItem!
    @IBOutlet weak var overlayView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        contactsTableView.dataSource = self
        contactsTableView.delegate = self
        
        searchContactsTextField.delegate = self
        
        searchContactsTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        
        loadContacts()
        
        backendModule = BackendModule(delegate: self)
        
        initialized = true
        
        if !DataModule.haveAskedToFindFriendsWithFlare {
            timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(askToFindFriendsWithFlare), userInfo: nil, repeats: false)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: TextField Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChange(textField: UITextField) {
        contacts.removeAll()
        if let text = textField.text where text != "" {
            contacts.appendContentsOf(unfilteredContacts.filter({(current) -> Bool in
                let fullName = current.firstName + " " + current.lastName
                let matchesName = fullName.lowercaseString.containsString(text.lowercaseString)
                var matchesNumber = false
                for number in current.phoneNumbers {
                    if number.digits.lowercaseString.containsString(text.lowercaseString) {
                        matchesNumber = true
                        break
                    }
                }
                return matchesName || matchesNumber
            }))
        } else {
            contacts.appendContentsOf(unfilteredContacts)
        }
        contactsTableView.reloadData()
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        contacts.removeAll()
        contacts.appendContentsOf(unfilteredContacts)
        contactsTableView.reloadData()
        return true
    }
    
    // MARK: TableView Delegate/Data Source
    
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
    
    // MARK: Backend module delegate
    
    func findFriendsWithFlareSuccess() {
        loadContacts()
        doneBeingBusy()
    }
    
    func findFriendsWithFlareError(error: ErrorType) {
        doneBeingBusy()
        let alert = UIAlertController(title: "", message: "We had a problem finding your friends on the cloud", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
        presentViewController(alert, animated: false, completion: nil)
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destination = segue.destinationViewController as? ConfirmFlareViewController
        if destination != nil {
            destination!.contacts.appendContentsOf(selectedContacts)
            destination!.location = userLocation
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "ConfirmFlareSegue" {
            if !DataModule.haveAskedToFindFriendsWithFlare {
                timer!.fire()
                return false
            }
        }
        return true
    }
    
    // MARK: Actions
    @IBAction func clearButtonAction(sender: UIBarButtonItem) {
        for contact in selectedContacts {
            contact.isSelected = false
        }
        selectedContacts.removeAll()
        noContactsSelected()
        contactsTableView.reloadData()
    }
    
    // MARK: Helper methods
    
    func loadContacts() {
        for contact in DataModule.contacts where contact.isSelected {
            contact.isSelected = false
        }
        
        unfilteredContacts.removeAll()
        contacts.removeAll()
        selectedContacts.removeAll()
        
        unfilteredContacts.appendContentsOf(DataModule.contacts.sort {
            return $0.firstName + " " + $0.lastName < $1.firstName + " " + $1.lastName
        })
        contacts.appendContentsOf(unfilteredContacts)
        
        noContactsSelected()
        
        if initialized {
            contactsTableView.reloadData()
        }
    }
    
    func askToFindFriendsWithFlare() {
        let alert = UIAlertController(title: "Find friends", message: "We can check if any of your friends have flare. This involves checking if your friends numbers are on our cloud. Do you mind if we do that ? You can still flare without this", preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: "Accept", style: .Default, handler: {(action) -> Void in
            self.isBusy()
            self.backendModule!.findFriendsWithFlare()
            DataModule.haveAskedToFindFriendsWithFlare = true
            DataModule.canFindFriendsWithFlare = true
        }))
        alert.addAction(UIAlertAction(title: "Decline", style: .Default, handler: {(action) -> Void in
            DataModule.haveAskedToFindFriendsWithFlare = true
            DataModule.canFindFriendsWithFlare = false
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func contactsSelected() {
        clearButton.enabled = true
        doneSelectingButton.hidden = false
        doneSelectingButton.enabled = true
    }
    
    func noContactsSelected() {
        clearButton.enabled = false
        doneSelectingButton.hidden = true
        doneSelectingButton.enabled = false
    }
    
    func isBusy() {
        doneSelectingButton.enabled = false
        overlayView.hidden = false
    }
    
    func doneBeingBusy() {
        doneSelectingButton.enabled = true
        overlayView.hidden = true
    }
}
