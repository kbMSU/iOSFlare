//
//  SendFlareContactsViewController.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 2/23/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import UIKit
import MapKit

class SendFlareContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    // MARK: Constants
    let cellIdentifier = "ContactTableViewCell"
    
    // MARK: Variables
    var userLocation : CLLocation?
    var unfilteredContacts = [Contact]()
    var contacts = [Contact]()
    var selectedContacts = [Contact]()
    
    // MARK: Outlets
    @IBOutlet weak var contactsTableView: UITableView!
    @IBOutlet weak var searchContactsTextField: UITextField!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        contactsTableView.dataSource = self
        contactsTableView.delegate = self
        
        searchContactsTextField.delegate = self
        
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
        
        doneButton.enabled = false
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
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
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
        return true
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
            selectedContacts.removeAtIndex(indexPath.row)
        }
        
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        
        if selectedContacts.isEmpty {
            doneButton.enabled = false
        } else {
            doneButton.enabled = true
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
