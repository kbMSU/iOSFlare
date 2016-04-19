//
//  GroupsListViewController.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 4/14/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import UIKit

class GroupsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: Constants
    let cellIdentifier = "GroupTableViewCell"
    
    // MARK: Variables
    
    var groups : [Group]!
    var selectedGroup : Group?
    
    // MARK: Outlets
    
    @IBOutlet weak var groupsTableView: UITableView!
    @IBOutlet weak var noGroupsTextView: UILabel!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        groups = DataModule.groups ?? [Group]()
        
        updateGroupsCount()
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
            contactsString += contact.firstName
        }
        cell.groupMembersLabel.text = contactsString
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedGroup = groups[indexPath.row]
        
        // Group has been selected
    }
    
    // MARK: Navigation
    
    @IBAction func unwindBackToGroupsList(sender : UIStoryboardSegue) {
        if DataModule.groups.count != groups.count {
            groups = DataModule.groups
            updateGroupsCount()
            groupsTableView.reloadData()
        }
    }
    
    // MARK: Action
    
    @IBAction func cancelAction(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Helper Methods
    
    func updateGroupsCount() {
        if groups == nil || groups?.count == 0 {
            groupsTableView.hidden = true
            noGroupsTextView.hidden = false
        } else {
            groupsTableView.hidden = false
            noGroupsTextView.hidden = true
        }
    }
}
