//
//  ContactTableViewCell.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 2/28/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    let hasFlareImageDimension = 32
    
    @IBOutlet weak var selectedSwitch: UISwitch!
    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var contactPrimaryPhoneLabel: UILabel!
    @IBOutlet weak var hasFlareImageView: UIImageView!
    
    @IBOutlet weak var hasFlareImageWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contactImageView.clipsToBounds = true
        contactImageView.layer.cornerRadius = contactImageView.frame.height/2
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
