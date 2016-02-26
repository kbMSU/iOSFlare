//
//  PhoneNumber.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 2/26/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import Foundation
import Contacts

class PhoneNumber {
    var digits : String
    var countryCode : String?
    var hasFlare : Bool
    
    init(number: CNPhoneNumber) {
        hasFlare = false
        countryCode = nil
        digits = ""
        for c : Character in number.stringValue.characters {
            if c > "0" && c < "9" {
                digits.append(c)
            }
        }
    }
}
