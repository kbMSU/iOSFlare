//
//  Contact.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 2/26/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import Foundation
import Contacts
import UIKit

class Contact {
    var firstName : String
    var lastName : String
    var hasFlare : Bool
    var phoneNumbers : [PhoneNumber]
    var image : UIImage?
    var primaryPhone : PhoneNumber
    var isSelected : Bool
    var id: String
    
    init(contact: CNContact) {
        firstName = contact.givenName
        lastName = contact.familyName
        hasFlare = false
        isSelected = false
        if let imageData = contact.thumbnailImageData {
            image = UIImage(data: imageData)
        } else {
            image = UIImage(named: "defaultContactImage")
        }
        phoneNumbers = [PhoneNumber]()
        for phone in contact.phoneNumbers {
            phoneNumbers.append(PhoneNumber(number: phone.value as! CNPhoneNumber))
        }
        primaryPhone = phoneNumbers[0]
        id = contact.identifier
    }
}
