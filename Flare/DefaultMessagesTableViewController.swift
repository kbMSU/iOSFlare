//
//  DefaultMessagesTableViewController.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 5/2/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import UIKit

class DefaultMessagesTableViewController: UITableViewController, UITextFieldDelegate {
    
    // MARK: Outlets
    
    @IBOutlet weak var flareMessageTextField: UITextField!
    @IBOutlet weak var flareUpdateButton: UIButton!
    @IBOutlet weak var flareLabel: UILabel!
    
    @IBOutlet weak var acceptTextField: UITextField!
    @IBOutlet weak var acceptUpdateButton: UIButton!
    @IBOutlet weak var acceptLabel: UILabel!
    
    @IBOutlet weak var declineTextField: UITextField!
    @IBOutlet weak var declineUpdateButton: UIButton!
    @IBOutlet weak var declineLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        flareLabel.text = "\" \(DataModule.defaultFlareMessage) \""
        acceptLabel.text = "\" \(DataModule.defaultAcceptMessage) \""
        declineLabel.text = "\" \(DataModule.defaultDeclineMessage) \""
        
        flareMessageTextField.delegate = self
        acceptTextField.delegate = self
        declineTextField.delegate = self
        
        flareUpdateButton.enabled = false
        flareUpdateButton.tintColor = UIColor.grayColor()
        
        acceptUpdateButton.enabled = false
        acceptUpdateButton.tintColor = UIColor.grayColor()
        
        declineUpdateButton.enabled = false
        declineUpdateButton.tintColor = UIColor.grayColor()
        
        flareMessageTextField.addTarget(self, action: #selector(flareFieldDidChange), forControlEvents: .EditingChanged)
        acceptTextField.addTarget(self, action: #selector(acceptFieldDidChange), forControlEvents: .EditingChanged)
        declineTextField.addTarget(self, action: #selector(declineFieldDidChange), forControlEvents: .EditingChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: TextField Delegates
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: Actions
    
    @IBAction func messageUpdateAction(sender: UIButton) {
        DataModule.defaultFlareMessage = flareMessageTextField.text!
        flareLabel.text = "\" \(DataModule.defaultFlareMessage) \""
        flareMessageTextField.text = ""
    }
    
    @IBAction func acceptUpdateAction(sender: UIButton) {
        DataModule.defaultAcceptMessage = acceptTextField.text!
        acceptLabel.text = "\" \(DataModule.defaultAcceptMessage) \""
        acceptTextField.text = ""
    }
    
    @IBAction func declineUpdateAction(sender: UIButton) {
        DataModule.defaultDeclineMessage = declineTextField.text!
        declineLabel.text = "\" \(DataModule.defaultDeclineMessage) \""
        declineTextField.text = ""
    }
    
    // MARK: Text Field Helpers
    
    func flareFieldDidChange() {
        if let text = flareMessageTextField.text where text != "" {
            flareUpdateButton.enabled = true
            flareUpdateButton.tintColor = Constants.flareRedColor
        } else {
            flareUpdateButton.enabled = false
            flareUpdateButton.tintColor = UIColor.grayColor()
        }
    }
    
    func acceptFieldDidChange() {
        if let text = acceptTextField.text where text != "" {
            acceptUpdateButton.enabled = true
            acceptUpdateButton.tintColor = Constants.flareRedColor
        } else {
            acceptUpdateButton.enabled = false
            acceptUpdateButton.tintColor = UIColor.grayColor()
        }
    }
    
    func declineFieldDidChange() {
        if let text = declineTextField.text where text != "" {
            declineUpdateButton.enabled = true
            declineUpdateButton.tintColor = Constants.flareRedColor
        } else {
            declineUpdateButton.enabled = false
            declineUpdateButton.tintColor = UIColor.grayColor()
        }
    }
}
