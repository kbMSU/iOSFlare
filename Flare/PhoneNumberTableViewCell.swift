//
//  PhoneNumberTableViewCell.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 5/14/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import UIKit

class PhoneNumberTableViewCell: UITableViewCell {
    
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var hasFlareImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
