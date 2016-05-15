//
//  AddGroupViewController.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 4/15/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import UIKit

class AddGroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    // MARK: Constants

    let cellIdentifier = "ContactTableViewCell"

    // MARK: Variables
    
    var unfilteredContacts = [Contact]()
    var contacts = [Contact]()
    var selectedContacts = [Contact]()
    var currentContact : Contact?
    var currentIndexPath : NSIndexPath?
    var popoverStoryboard = UIStoryboard(name: "Popover", bundle: nil)
    
    // MARK: Outlets
    
    @IBOutlet weak var searchContactsTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var contactsTableView: UITableView!
    @IBOutlet weak var clearButton: UIBarButtonItem!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchContactsTextField.delegate = self
        contactsTableView.delegate = self
        contactsTableView.dataSource = self
        
        searchContactsTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        
        loadContacts()
        
        updateSaveButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
        
    // MARK: Phone number popover delegate
    
    override func phoneNumberSelected(number: PhoneNumber) {
        currentContact!.primaryPhone = number
        currentContact!.isSelected = true
        selectedContacts.append(currentContact!)
        contactsTableView.reloadRowsAtIndexPaths([currentIndexPath!], withRowAnimation: .None)
        contactsSelected()
    }
    
    // MARK: Text Field Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChange(textField: UITextField) {
        if textField == searchContactsTextField {
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
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        if textField == searchContactsTextField {
            contacts.removeAll()
            contacts.appendContentsOf(unfilteredContacts)
            contactsTableView.reloadData()
        }
        return true
    }
    
    // MARK: Table View Delegate/Data Source
    
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
        
        currentContact = nil
        currentIndexPath = nil
        
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
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ConfirmGroupSegue" {
            let destination = segue.destinationViewController as! SaveGroupViewController
            destination.contacts = [Contact]()
            destination.contacts.appendContentsOf(selectedContacts)
        }
    }
    
    // MARK: Actions
    
    @IBAction func clearAction(sender: UIBarButtonItem) {
        for contact in selectedContacts {
            contact.isSelected = false
        }
        selectedContacts.removeAll()
        noContactsSelected()
        contactsTableView.reloadData()
    }
    
    // MARK: Helper Methods
    
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

        contactsTableView.reloadData()
    }
    
    func contactsSelected() {
        clearButton.enabled = true
        updateSaveButton()
    }
    
    func noContactsSelected() {
        clearButton.enabled = false
        updateSaveButton()
    }
    
    func updateSaveButton() {
        saveButton.hidden = selectedContacts.isEmpty
    }
}
