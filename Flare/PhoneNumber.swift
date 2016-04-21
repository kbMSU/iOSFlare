//
//  PhoneNumber.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 2/26/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import Foundation
import Contacts

struct PhoneNumberKeys {
    static let digitsKey = "digits"
    static let hasFlareKey = "hasFlare"
}

class PhoneNumber: NSObject, NSCoding {
    static let ArchiveURL = Constants.DocumentsDirectory.URLByAppendingPathComponent("phoneNumber")

    var digits : String
    //var countryCode : String?
    var hasFlare : Bool
    
    init(number:String,flare:Bool) {
        digits = number
        hasFlare = flare
    }
    
    init(number: CNPhoneNumber) {
        hasFlare = false
        digits = ""
        
        for c : Character in number.stringValue.characters {
            if c >= "0" && c <= "9" {
                digits.append(c)
            }
        }
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let number = aDecoder.decodeObjectForKey(PhoneNumberKeys.digitsKey) as! String
        let flare = aDecoder.decodeBoolForKey(PhoneNumberKeys.hasFlareKey)
        self.init(number: number,flare: flare)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(digits, forKey: PhoneNumberKeys.digitsKey)
        aCoder.encodeBool(hasFlare, forKey: PhoneNumberKeys.hasFlareKey)
    }
}
