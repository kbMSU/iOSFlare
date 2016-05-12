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
    static let imageKey = "image"
    static let typeKey = "type"
    static let messageKey = "message"
    static let timeStampKey = "timeStamp"
}

class Flare: NSObject, NSCoding {
    
    static let ArchiveURL = Constants.DocumentsDirectory.URLByAppendingPathComponent("flares")
    
    var name : String
    var image : UIImage
    var type : FlareType
    var message : String
    var timeStamp : NSDate
    
    init(name:String,image:UIImage,type:FlareType,message:String,timeStamp:NSDate) {
        self.name = name
        self.image = image
        self.type = type
        self.message = message
        self.timeStamp = timeStamp
    }
    
    required convenience init(coder aDecoder : NSCoder) {
        let name = aDecoder.decodeObjectForKey(FlareKeys.nameKey) as! String
        let image = aDecoder.decodeObjectForKey(FlareKeys.imageKey) as! UIImage
        let type = aDecoder.decodeIntForKey(FlareKeys.typeKey)
        let message = aDecoder.decodeObjectForKey(FlareKeys.messageKey) as! String
        let timeStamp = aDecoder.decodeObjectForKey(FlareKeys.timeStampKey) as! NSDate
        
        let flareType = FlareType(rawValue: type)!
        self.init(name:name,image:image,type:flareType,message:message,timeStamp:timeStamp)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: FlareKeys.nameKey)
        aCoder.encodeObject(image, forKey: FlareKeys.imageKey)
        aCoder.encodeInt(type.rawValue, forKey: FlareKeys.typeKey)
        aCoder.encodeObject(message, forKey: FlareKeys.messageKey)
        aCoder.encodeObject(timeStamp, forKey: FlareKeys.timeStampKey)
    }
}