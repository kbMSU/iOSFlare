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
    static let idKey = "id"
}

class Group: NSObject, NSCoding {
    
    static let ArchiveURL = Constants.DocumentsDirectory.URLByAppendingPathComponent("groups")
    
    var name : String
    var contacts : [Contact]
    var id : String
    
    init(name:String,contacts:[Contact]) {
        self.name = name
        self.contacts = contacts
        
        let currentDateTime = NSDate()
        self.id = name+" : \(currentDateTime)"
    }
    
    init(name:String,contacts:[Contact],id:String) {
        self.name = name
        self.contacts = contacts
        self.id = id
    }
    
    func loadFromContacts() {
        for contact in contacts {
            contact.loadFromContact()
        }
    }
    
    required convenience init(coder aDecoder:NSCoder) {
        let name = aDecoder.decodeObjectForKey(GroupKeys.nameKey) as! String
        let contacts = aDecoder.decodeObjectForKey(GroupKeys.contactsKey) as! [Contact]
        let id = aDecoder.decodeObjectForKey(GroupKeys.idKey) as! String
        self.init(name: name,contacts: contacts,id: id)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: GroupKeys.nameKey)
        aCoder.encodeObject(contacts, forKey: GroupKeys.contactsKey)
        aCoder.encodeObject(id, forKey: GroupKeys.idKey)
    }
}