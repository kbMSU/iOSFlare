//
//  Group.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 4/14/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import Foundation

struct GroupKeys {
    static let nameKey = "name"
    static let contactsKey = "contacts"
}

class Group: NSObject, NSCoding {
    
    static let ArchiveURL = Constants.DocumentsDirectory.URLByAppendingPathComponent("groups")
    
    var name : String
    var contacts : [Contact]
    
    init(name:String,contacts:[Contact]) {
        self.name = name
        self.contacts = contacts
    }
    
    required convenience init(coder aDecoder:NSCoder) {
        let name = aDecoder.decodeObjectForKey(GroupKeys.nameKey) as! String
        let contacts = aDecoder.decodeObjectForKey(GroupKeys.contactsKey) as! [Contact]
        self.init(name: name,contacts: contacts)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: GroupKeys.nameKey)
        aCoder.encodeObject(contacts, forKey: GroupKeys.contactsKey)
    }
}