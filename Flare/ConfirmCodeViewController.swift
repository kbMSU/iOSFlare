//
//  ConfirmCodeViewController.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 3/4/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import UIKit

class ConfirmCodeViewController: UIViewController, UITextFieldDelegate {

    var verificationCode : String?
    var countryCode : String?
    var phoneNumber : String?
    
    @IBOutlet weak var enterCodeTextField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        enterCodeTextField.delegate = self
        
        enterCodeTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        
        confirmButton.enabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidChange(textField: UITextField) {
        if let code = textField.text where code != "" {
            confirmButton.enabled = true
        } else {
            confirmButton.enabled = false
        }
    }
    
    @IBAction func confirmClickAction(sender: UIButton) {
        if let code = enterCodeTextField.text where code == verificationCode {
            DataModule.haveVerifiedPhoneNumber = true
            DataModule.myCountryCode = countryCode!
            DataModule.myPhoneNumber = phoneNumber!
            performSegueWithIdentifier("CodeConfirmedSegue", sender: nil)
        } else {
            let alert = UIAlertController(title: "Invalid", message: "The code you entered was incorrect", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .Destructive, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
}
