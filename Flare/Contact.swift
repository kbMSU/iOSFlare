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

struct ContactKeys {
    static let firstNameKey = "firstName"
    static let lastNameKey = "lastName"
    static let hasFlareKey = "hasFlare"
    static let phoneNumbersKey = "phoneNumbers"
    static let imageKey = "image"
    static let primaryPhoneKey = "primaryPhone"
    static let isSelectedKey = "isSelected"
    static let idKey = "id"
}

class Contact: NSObject, NSCoding {
    
    static let ArchiveURL = Constants.DocumentsDirectory.URLByAppendingPathComponent("contact")
    
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
    
    func loadFromContact() {
        if let contact = DataModule.findContactForId(id) {
            image = contact.image
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        firstName = aDecoder.decodeObjectForKey(ContactKeys.firstNameKey) as! String
        lastName = aDecoder.decodeObjectForKey(ContactKeys.lastNameKey) as! String
        hasFlare = aDecoder.decodeBoolForKey(ContactKeys.hasFlareKey)
        phoneNumbers = aDecoder.decodeObjectForKey(ContactKeys.phoneNumbersKey) as! [PhoneNumber]
        //image = aDecoder.decodeObjectForKey(ContactKeys.imageKey) as? UIImage
        primaryPhone = aDecoder.decodeObjectForKey(ContactKeys.primaryPhoneKey) as! PhoneNumber
        isSelected = aDecoder.decodeBoolForKey(ContactKeys.isSelectedKey)
        id = aDecoder.decodeObjectForKey(ContactKeys.idKey) as! String
        
        image = UIImage(named: "defaultContactImage")
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(firstName, forKey: ContactKeys.firstNameKey)
        aCoder.encodeObject(lastName, forKey: ContactKeys.lastNameKey)
        aCoder.encodeBool(hasFlare, forKey: ContactKeys.hasFlareKey)
        aCoder.encodeObject(phoneNumbers, forKey: ContactKeys.phoneNumbersKey)
        //aCoder.encodeObject(image, forKey: ContactKeys.imageKey)
        aCoder.encodeObject(primaryPhone, forKey: ContactKeys.primaryPhoneKey)
        aCoder.encodeBool(isSelected, forKey: ContactKeys.isSelectedKey)
        aCoder.encodeObject(id, forKey: ContactKeys.idKey)
    }
}
