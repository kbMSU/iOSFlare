//
//  SlideOutViewController.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 4/3/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import UIKit

class SlideOutViewController: UIViewController {
    
    var leftSwipeRecognizer : UISwipeGestureRecognizer!
        
    // MARK: Outlets
    
    @IBOutlet weak var profileButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let text = "+"+DataModule.myCountryCode+DataModule.myPhoneNumber
        profileButton.setTitle(text, forState: .Normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
