//
//  SaveGroupViewController.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 4/22/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import UIKit

class SaveGroupViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, PhoneNumberPopoverDelegate {
    
    // MARK: Constants
    
    let cellIdentifier = "ContactTableViewCell"
    
    // MARK: Properties
    
    var contacts : [Contact]!
    var selectedContacts = [Contact]()
    var currentContact : Contact?
    var currentIndexPath : NSIndexPath?
    var popoverStoryboard = UIStoryboard(name: "Popover", bundle: nil)
    
    var isContactSelected = true
    
    // MARK: Outlets

    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var saveGroupButton: UIButton!
    @IBOutlet weak var contactsTableView: UITableView!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        selectedContacts.appendContentsOf(contacts)
        contactsTableView.delegate = self
        contactsTableView.dataSource = self
        
        groupNameTextField.delegate = self
        groupNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        
        updateSaveButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Popover presentation controller delegate
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    // MARK: Phone number popover delegate
    
    func phoneNumberSelected(number: PhoneNumber) {
        currentContact!.primaryPhone = number
        currentContact!.isSelected = true
        selectedContacts.append(currentContact!)
        contactsTableView.reloadRowsAtIndexPaths([currentIndexPath!], withRowAnimation: .None)
        contactsSelected()
    }
    
    // MARK: TextField Delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChange(textField: UITextField) {
        updateSaveButton()
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        updateSaveButton()
        return true
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

    // MARK: Actions
    
    @IBAction func saveGroupAction(sender: UIButton) {
        let name = groupNameTextField.text!
        let group = Group(name: name, contacts: selectedContacts)
        DataModule.addGroup(group)
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func cancelAction(sender: UIBarButtonItem) {
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // MARK: Helper Functions
    
    func contactsSelected() {
        isContactSelected = true
        updateSaveButton()
    }
    
    func noContactsSelected() {
        isContactSelected = false
        updateSaveButton()
    }
    
    func updateSaveButton() {
        let isNameEntered = groupNameTextField.text != nil && groupNameTextField.text != ""
        saveGroupButton.hidden = !(isNameEntered && isContactSelected)
    }
}
