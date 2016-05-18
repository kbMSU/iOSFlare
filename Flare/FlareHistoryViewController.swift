//
//  FlareHistoryViewController.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 4/17/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import UIKit

class FlareHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Constants
    
    let identifier = "FlareTableViewCell"
    
    // MARK: Variables
    
    var flares : [Flare]!
    var incomingFlares = [Flare]()
    var outgoingFlares = [Flare]()
    var selectedFlare : Flare?
    
    // MARK: Outlets
    
    @IBOutlet weak var flareTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var flareTableView: UITableView!
    @IBOutlet weak var dismissButton: UIBarButtonItem!
    @IBOutlet weak var noFlaresToShowLabel: UILabel!
    @IBOutlet weak var clearButton: UIBarButtonItem!

    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        flares = DataModule.flares
        for flare in flares {
            if flare.type == .IncomingFlare || flare.type == .IncomingResponse {
                incomingFlares.append(flare)
            } else {
                outgoingFlares.append(flare)
            }
        }
        
        flareTableView.delegate = self
        flareTableView.dataSource = self
        
        flareTypeSegmentedControl.selectedSegmentIndex = 0
        
        if incomingFlares.isEmpty {
            noFlares()
        } else {
            hasFlares()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destination = segue.destinationViewController as! FlareViewController
        destination.flare = selectedFlare!
    }
    
    // MARK: TableView Delegate/Datasource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count : Int
        if flareTypeSegmentedControl.selectedSegmentIndex == 0 {
            count = incomingFlares.count
        } else {
            count = outgoingFlares.count
        }
        return count
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! FlareTableViewCell
        var flare : Flare!
        if flareTypeSegmentedControl.selectedSegmentIndex == 0 {
            flare = incomingFlares[indexPath.row]
        } else {
            flare = outgoingFlares[indexPath.row]
        }
        cell.flareImageView.image = flare.image
        cell.flareNameLabel.text = flare.name
        cell.flareMessageLabel.text = flare.message
        cell.loadDate(flare.timeStamp)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedFlare = flares[indexPath.row]
        performSegueWithIdentifier("SelectFlareSegue", sender: self)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        var flare : Flare
        if flareTypeSegmentedControl.selectedSegmentIndex == 0 {
            flare = incomingFlares[indexPath.row]
            incomingFlares.removeAtIndex(indexPath.row)
            if incomingFlares.isEmpty {
                noFlares()
            }
        } else {
            flare = outgoingFlares[indexPath.row]
            outgoingFlares.removeAtIndex(indexPath.row)
            if outgoingFlares.isEmpty {
                noFlares()
            }
        }
        if editingStyle == .Delete {
            DataModule.removeFlare(flare)
            flareTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    // MARK: Actions
    
    @IBAction func dismissAction(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func flareTypeChanged(sender: UISegmentedControl) {
        flareTableView.reloadData()
    }
    
    @IBAction func clearAction(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Confirm", message: "Are you sure you want to delete every saved flare ? This action is not reversible", preferredStyle: .Alert)
        let yesAction = UIAlertAction(title: "Yes", style: .Default, handler: {(_:UIAlertAction) -> Void in
            DataModule.removeAllFlares()
            self.flares = [Flare]()
            self.incomingFlares = [Flare]()
            self.outgoingFlares = [Flare]()
            self.flareTableView.reloadData()
            self.noFlares()
        })
        let noAction = UIAlertAction(title: "No", style: .Default, handler: nil)
        alert.addAction(noAction)
        alert.addAction(yesAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: Helper methods
    
    func hasFlares() {
        flareTableView.hidden = false
        noFlaresToShowLabel.hidden = true
        clearButton.enabled = true
    }
    
    func noFlares() {
        flareTableView.hidden = true
        noFlaresToShowLabel.hidden = false
        clearButton.enabled = false
    }
}
