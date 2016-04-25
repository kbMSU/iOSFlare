//
//  GroupsListViewController.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 4/14/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import UIKit

class GroupsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ContactModuleDelegate {

    // MARK: Constants
    
    let cellIdentifier = "GroupTableViewCell"
    
    // MARK: Variables
    
    var groups : [Group]!
    var selectedGroup : Group?
    var contactModule : ContactsModule!
    
    // MARK: Outlets
    
    @IBOutlet weak var groupsTableView: UITableView!
    @IBOutlet weak var noGroupsTextView: UILabel!
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var overlayView: UIView!
    @IBOutlet var addGroupButton: UIButton!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        groups = DataModule.groups ?? [Group]()
        groupsTableView.dataSource = self
        groupsTableView.delegate = self
        
        contactModule = ContactsModule(delegate: self)
        
        updateGroupsCount()
        
        doneBeingBusy()
    }
    
    override func viewDidAppear(animated: Bool) {
        groups = DataModule.groups
        updateGroupsCount()
        groupsTableView.reloadData()
        
        for contact in DataModule.contacts where contact.isSelected {
            contact.isSelected = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Table Delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! GroupTableViewCell
        let groupAtRow = groups[indexPath.row]
        
        cell.groupNameLabel.text = groupAtRow.name
        var contactsString = ""
        for contact in groupAtRow.contacts {
            if contactsString != "" {
                contactsString += ", "
            }
            contactsString += contact.firstName
        }
        cell.groupMembersLabel.text = contactsString
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedGroup = groups[indexPath.row]
        performSegueWithIdentifier("SelectGroupSegue", sender: self)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let group = groups[indexPath.row]
            DataModule.removeGroup(group)
            groups.removeAtIndex(indexPath.row)
            groupsTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            updateGroupsCount()
        }
    }
    
    // MARK: Contact Module Delegate
    
    func retreiveResult(result: ErrorTypes) {
        doneBeingBusy()
        switch result {
        case .None:
            performSegueWithIdentifier("AddGroupSegue", sender: self)
        case .Error:
            displayError("We could not get your contacts")
        case .Unauthorized:
            displayError("You did not give us permission to access your contacts")
        }
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SelectGroupSegue" {
            let destination = segue.destinationViewController as! SelectGroupViewController
            destination.group = selectedGroup
        }
    }
    
    // MARK: Action
    
    @IBAction func cancelAction(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func editAction(sender: UIBarButtonItem) {
        if groupsTableView.editing {
            groupsTableView.editing = false
            editButton.title = "Edit"
        } else {
            groupsTableView.editing = true
            editButton.title = "Done"
        }
    }
    
    @IBAction func addGroupAction(sender: UIButton) {
        if contactModule.isAuthorized() {
            if DataModule.contacts.isEmpty {
                getContacts()
            } else {
                performSegueWithIdentifier("AddGroupSegue", sender: self)
            }
        } else {
            authorizeContacts()
        }
    }
    
    // MARK: Helper Methods
    
    func displayError(message : String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func authorizeContacts() {
        let authorizeAlert = UIAlertController(title: "Permission Needed", message: "Can we access your contacts ? We need to do this to enable you add them to groups", preferredStyle: .ActionSheet)
        authorizeAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: {(UIAlertAction) -> Void in
            self.getContacts()
        }))
        authorizeAlert.addAction(UIAlertAction(title: "No", style: .Default, handler: nil))
        presentViewController(authorizeAlert, animated: true, completion: nil)
    }
    
    func getContacts() {
        isBusy()
        contactModule.authorizeContacts()
    }
    
    func updateGroupsCount() {
        if groups == nil || groups?.count == 0 {
            groupsTableView.hidden = true
            noGroupsTextView.hidden = false
            editButton.enabled = false
            editButton.title = "Edit"
            groupsTableView.editing = false
        } else {
            groupsTableView.hidden = false
            noGroupsTextView.hidden = true
            editButton.enabled = true
        }
    }
    
    func isBusy() {
        overlayView.hidden = false
        addGroupButton.enabled = false
    }
    
    func doneBeingBusy() {
        overlayView.hidden = true
        addGroupButton.enabled = true
    }
}
