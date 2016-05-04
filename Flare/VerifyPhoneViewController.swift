//
//  VerifyPhoneViewController.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 3/3/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import UIKit

class VerifyPhoneViewController: UIViewController, UITextFieldDelegate, BackendModuleDelegate {
    
    var selectedCountry : (String,String)?
    var backendModule : BackendModule?
    var code : String?

    // MARK: Outlets
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet var topLevelView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        countryLabel.text = selectedCountry!.0
        
        phoneNumberTextField.delegate = self
        
        phoneNumberTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        
        backendModule = BackendModule(delegate: self)
        
        doneBeingBusy()
        disableVerifyButton()
    }
    
    override func viewDidAppear(animated: Bool) {
        navigationController?.navigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: TextField delegate
    
    func textFieldDidChange(textField: UITextField) {
        if let phone = textField.text where phone != "" {
            enableVerifyButton()
        } else {
            disableVerifyButton()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Actions
    
    @IBAction func verifyAction(sender: UIButton) {
        code = generateCode()
        isBusy()
        let numbers = ["+"+selectedCountry!.1+phoneNumberTextField.text!]
        let message = "Your flare verification code is "+code!
        backendModule!.sendTwilioMessage(numbers, message: message)
    }
    
    // MARK: BackendModule delegate
    
    func sendTwilioMessageSuccess() {
        doneBeingBusy()
        moveToEnterCodeScreen()
    }
    
    func sendTwilioMessageError(error: ErrorType) {
        doneBeingBusy()
        let alertView = UIAlertController(title: "Error", message: "There was an issue in verifying your phone number. Please try again", preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
        presentViewController(alertView, animated: true, completion: nil)
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SentCodeSegue" {
            let destination = segue.destinationViewController as! ConfirmCodeViewController
            destination.countryCode = selectedCountry!.1
            destination.phoneNumber = phoneNumberTextField.text
            destination.verificationCode = code
        } else {
            let destination = segue.destinationViewController as! EnterCodeViewController
            destination.countryCode = selectedCountry!.1
            destination.phoneNumber = phoneNumberTextField.text
            destination.confirmationCode = code
        }
    }
    
    // MARK: Helper functions
    
    func generateCode() -> String {
        let random = Int(arc4random_uniform(9000))
        let code = random + 1000
        return String(code)
    }
    
    func isBusy() {
        overlayView.hidden = false
        topLevelView.userInteractionEnabled = false
        disableVerifyButton()
    }
    
    func doneBeingBusy() {
        overlayView.hidden = true
        topLevelView.userInteractionEnabled = true
        enableVerifyButton()
    }
    
    func disableVerifyButton() {
        verifyButton.enabled = false
        verifyButton.tintColor = UIColor.grayColor()
    }
    
    func enableVerifyButton() {
        verifyButton.enabled = true
        verifyButton.tintColor = Constants.flareRedColor
    }
    
    func moveToEnterCodeScreen() {
        if DataModule.haveVerifiedPhoneNumber {
            performSegueWithIdentifier("ConfirmCodeSegue", sender: nil)
        } else {
            performSegueWithIdentifier("SentCodeSegue", sender: nil)
        }
    }
}
