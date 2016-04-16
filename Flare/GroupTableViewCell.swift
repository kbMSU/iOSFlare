//
//  GroupTableViewCell.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 4/14/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import UIKit

class GroupTableViewCell: UITableViewCell {
    
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupMembersLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
