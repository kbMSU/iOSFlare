//
//  Contact.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 2/26/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import Foundation
import Contacts

class Contact {
    var firstName : String
    var lastName : String
    var hasFlare : Bool
    var phoneNumbers : [PhoneNumber]
    var image : NSData?
    
    init(contact: CNContact) {
        firstName = contact.givenName
        lastName = contact.familyName
        hasFlare = false
        image = contact.thumbnailImageData
        phoneNumbers = [PhoneNumber]()
        for phone: CNLabeledValue in contact.phoneNumbers {
            phoneNumbers.append(PhoneNumber(number: phone.value as! CNPhoneNumber))
        }
    }
}
