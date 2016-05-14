//
//  PhoneNumberSelectionViewController.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 5/14/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import UIKit

class PhoneNumberSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Constants
    
    let cellIdentifier = "PhoneNumberCell"

    // MARK: Variables
    
    var phoneNumbers = [PhoneNumber]()
    var selectedPhoneNumber : PhoneNumber?
    var delegate : PhoneNumberPopoverDelegate!
    
    // MARK: Outlets 
    
    @IBOutlet weak var phoneNumberTableView: UITableView!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneNumberTableView.delegate = self
        phoneNumberTableView.dataSource = self
        
        view.layer.borderColor = UIColor.lightGrayColor().CGColor
        view.layer.borderWidth = 0.3
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    // MARK: Table View Delegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return phoneNumbers.count
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! PhoneNumberTableViewCell
        let phoneNumber = phoneNumbers[indexPath.row]
        
        cell.hasFlareImageView.hidden = !phoneNumber.hasFlare
        cell.phoneNumberLabel.text = phoneNumber.digits
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedPhoneNumber = phoneNumbers[indexPath.row]
        delegate.phoneNumberSelected(selectedPhoneNumber!)
        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: Actions
    
    @IBAction func DismissAction(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
