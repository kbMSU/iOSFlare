//
//  Flare.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 5/12/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import Foundation

struct FlareKeys {
    static let nameKey = "name"
    static let typeKey = "type"
    static let messageKey = "message"
    static let timeStampKey = "timeStamp"
    static let contactIdKey = "contactId"
}

class Flare /*: NSObject, NSCoding*/ {
    
    static let ArchiveURL = Constants.DocumentsDirectory.URLByAppendingPathComponent("flares")
    
    var phoneNumber : String
    var name : String
    var image : UIImage
    var type : FlareType
    var message : String
    var timeStamp : NSDate
    var contactId : String?
    var latitude : String?
    var longitude : String?
    
    init(phoneNumber:String,name:String,type:FlareType,message:String,timeStamp:NSDate,contactId:String?=nil,image:UIImage?=nil,latitude:String?=nil,longitude:String?=nil) {
        self.phoneNumber = phoneNumber
        self.name = name
        self.type = type
        self.message = message
        self.timeStamp = timeStamp
        self.contactId = contactId
        self.latitude = latitude
        self.longitude = longitude
        
        self.image = image ?? UIImage(named: "defaultContactImage")!
    }
    
    /*func loadImage() {
        if contactId == nil {
            return
        }
        
        for contact in DataModule.contacts where contact.id == contactId! {
            image = contact.image!
        }
    }
    
    required convenience init(coder aDecoder : NSCoder) {
        let name = aDecoder.decodeObjectForKey(FlareKeys.nameKey) as! String
        let type = aDecoder.decodeIntForKey(FlareKeys.typeKey)
        let message = aDecoder.decodeObjectForKey(FlareKeys.messageKey) as! String
        let timeStamp = aDecoder.decodeObjectForKey(FlareKeys.timeStampKey) as! NSDate
        let contactId = aDecoder.decodeObjectForKey(FlareKeys.contactIdKey) as? String
        
        let flareType = FlareType(rawValue: type)!
        self.init(name:name,type:flareType,message:message,timeStamp:timeStamp,contactId:contactId)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: FlareKeys.nameKey)
        aCoder.encodeInt(type.rawValue, forKey: FlareKeys.typeKey)
        aCoder.encodeObject(message, forKey: FlareKeys.messageKey)
        aCoder.encodeObject(timeStamp, forKey: FlareKeys.timeStampKey)
        aCoder.encodeObject(contactId, forKey: FlareKeys.contactIdKey)
    }*/
}