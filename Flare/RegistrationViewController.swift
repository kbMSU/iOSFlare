//
//  RegistrationViewController.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 3/4/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController, BackendModuleDelegate {

    var backendModule : BackendModule?
    
    // MARK: Outlets
    
    @IBOutlet var topLevelView: UIView!
    @IBOutlet weak var overlayView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backendModule = BackendModule(delegate: self)
        
        overlayView.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        navigationController?.navigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: BackendModule delegate
    
    func registrationSuccess() {
        doneBeingBusy()
        performSegueWithIdentifier("RegistrationCompleteSegue", sender: nil)
    }
    
    func registrationError(error: ErrorType) {
        doneBeingBusy()
        performSegueWithIdentifier("RegistrationCompleteSegue", sender: nil)
    }
    
    // MARK: Actions
    
    @IBAction func yesClickAction(sender: UIButton) {
        DataModule.canAllowFriendsToFind = true
        registerForFlare()
    }
    
    @IBAction func noClickAction(sender: UIButton) {
        performSegueWithIdentifier("RegistrationCompleteSegue", sender: nil)
    }
    
    // MARK: Helper methods
    
    func registerForFlare() {
        isBusy()
        backendModule!.register()
        doneBeingBusy()
    }
    
    func isBusy() {
        overlayView.hidden = false
        topLevelView.userInteractionEnabled = false
    }
    
    func doneBeingBusy() {
        overlayView.hidden = true
        topLevelView.userInteractionEnabled = true
    }
}
