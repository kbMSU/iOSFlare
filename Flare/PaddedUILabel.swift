//
//  PaddedUIButton.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 2/26/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import Foundation
import UIKit

class PaddedUILabel : UILabel {
    
    override func drawTextInRect(rect: CGRect) {
        let insets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets))
    }
    
}