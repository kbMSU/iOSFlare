//
//  EnterCodeViewController.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 5/3/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import UIKit

class EnterCodeViewController: UIViewController, BackendModuleDelegate, UITextFieldDelegate {
    
    // MARK: Variables
    
    var countryCode : String!
    var phoneNumber : String!
    var confirmationCode : String!
    
    var backendModule : BackendModule!
    
    // MARK: Outlets

    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var overlayView: UIView!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backendModule = BackendModule(delegate: self)
        
        codeTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        codeTextField.delegate = self
        
        doneBeingBusy()
        disableVerifyButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Text Field Delegate
    
    func textFieldDidChange(textField: UITextField) {
        if let code = textField.text where code != "" {
            enableVerifyButton()
        } else {
            disableVerifyButton()
        }
    }
 
    func textFieldShouldClear(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Backend Module Delegate
    
    func updateRegistrationSuccess() {
        doneBeingBusy()
        let alert = UIAlertController(title: "Success", message: "Your phone number has been successfully updated", preferredStyle: .Alert)
        let action = UIAlertAction(title: "Dismiss", style: .Default, handler: { (action:UIAlertAction) -> Void in
            DataModule.myCountryCode = self.countryCode
            DataModule.myPhoneNumber = self.phoneNumber
            self.navigationController?.popToRootViewControllerAnimated(true)
        })
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func updateRegistrationFailure(error: ErrorType?) {
        doneBeingBusy()
        displayError("Error", message: "Something went wrong updating your phone number")
    }
    
    // MARK: Actions
    
    @IBAction func verifyAction(sender: UIButton) {
        if let code = codeTextField.text where code == confirmationCode {
            isBusy()
            backendModule.updateRegistration(countryCode, newPhoneNumber: phoneNumber)
        } else {
            displayError("Invalid", message: "Your code you entered was incorrect")
        }
    }
    
    @IBAction func cancelAction(sender: UIBarButtonItem) {
        navigationController?.popToRootViewControllerAnimated(true)
    }

    // MARK: Helpers
    
    func displayError(title : String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func isBusy() {
        overlayView.hidden = false
        cancelButton.enabled = false
        disableVerifyButton()
    }
    
    func doneBeingBusy() {
        overlayView.hidden = true
        cancelButton.enabled = true
        enableVerifyButton()
    }
    
    func enableVerifyButton() {
        verifyButton.enabled = true
        verifyButton.tintColor = Constants.flareRedColor
    }
    
    func disableVerifyButton() {
        verifyButton.enabled = false
        verifyButton.tintColor = UIColor.grayColor()
    }
}
