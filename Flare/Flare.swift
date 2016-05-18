//
//  Flare.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 5/12/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import Foundation

struct FlareKeys {
    static let numberKey = "number"
    static let nameKey = "name"
    static let typeKey = "type"
    static let messageKey = "message"
    static let timeStampKey = "timeStamp"
    static let contactIdKey = "contactId"
    static let latitudeKey = "latitude"
    static let longitudeKey = "longitude"
}

class Flare : NSObject, NSCoding {
    
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
    var id : String
    
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
        self.id = "\(name)_\(timeStamp)"
    }
    
    func loadFromContact() {
        if let id = contactId {
            let contact = DataModule.findContactForId(id)
            if contact == nil {
                return
            }
            name = "\(contact!.firstName) \(contact!.lastName)"
            contactId = contact!.id
            image = contact!.image!
        } else {
            let contact = DataModule.findContactForNumber(phoneNumber)
            if contact == nil {
                return
            }
            name = "\(contact!.firstName) \(contact!.lastName)"
            contactId = contact!.id
            image = contact!.image!
        }
    }
    
    required convenience init(coder aDecoder : NSCoder) {
        let number = aDecoder.decodeObjectForKey(FlareKeys.numberKey) as! String
        let name = aDecoder.decodeObjectForKey(FlareKeys.nameKey) as! String
        let type = aDecoder.decodeIntForKey(FlareKeys.typeKey)
        let message = aDecoder.decodeObjectForKey(FlareKeys.messageKey) as! String
        let timeStamp = aDecoder.decodeObjectForKey(FlareKeys.timeStampKey) as! NSDate
        let contactId = aDecoder.decodeObjectForKey(FlareKeys.contactIdKey) as? String
        let latitude = aDecoder.decodeObjectForKey(FlareKeys.latitudeKey) as? String
        let longitude = aDecoder.decodeObjectForKey(FlareKeys.longitudeKey) as? String
        
        let flareType = FlareType(rawValue: type)!
        
        self.init(phoneNumber:number,name:name,type:flareType,message:message,timeStamp:timeStamp,contactId:contactId,image:nil,latitude:latitude,longitude:longitude)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(phoneNumber, forKey: FlareKeys.numberKey)
        aCoder.encodeObject(name, forKey: FlareKeys.nameKey)
        aCoder.encodeInt(type.rawValue, forKey: FlareKeys.typeKey)
        aCoder.encodeObject(message, forKey: FlareKeys.messageKey)
        aCoder.encodeObject(timeStamp, forKey: FlareKeys.timeStampKey)
        aCoder.encodeObject(contactId, forKey: FlareKeys.contactIdKey)
        aCoder.encodeObject(latitude, forKey: FlareKeys.latitudeKey)
        aCoder.encodeObject(longitude, forKey: FlareKeys.longitudeKey)
    }
}