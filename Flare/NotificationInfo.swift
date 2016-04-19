//
//  NotificationInfo.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 4/12/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import Foundation

class NotificationInfo {
    
    var phoneNumber : String
    var message : String
    var type : String
    var latitude : String?
    var longitude : String?
    
    init(number:String,text:String,pushType:String) {
        phoneNumber = number
        message = text
        type = pushType
    }
}