//
//  DataModule.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 2/26/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import Foundation

class DataModule {
    static let instance = DataModule()
    private init() {}
    
    static var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    static func setup() {
        
        //defaults.setBool(false, forKey: "haveVerifiedPhoneNumber")
        
        myCountryCode = defaults.stringForKey("myCountryCode") ?? ""
        myPhoneNumber = defaults.stringForKey("myPhoneNumber") ?? ""
        canAllowFriendsToFind = defaults.boolForKey("canAllowFriendsToFind")
        haveAskedToFindFriendsWithFlare = defaults.boolForKey("haveAskedToFindFriendsWithFlare")
        canFindFriendsWithFlare = defaults.boolForKey("canFindFriendsWithFlare")
        haveVerifiedPhoneNumber = defaults.boolForKey("haveVerifiedPhoneNumber")
        canSendCloudMessage = defaults.boolForKey("canSendCloudMessage")
    }
    
    static var contacts = [Contact]()
    
    static var myCountryCode : String = "" {
        didSet {
            defaults.setObject(myCountryCode, forKey: "myCountryCode")
        }
    }
    
    static var myPhoneNumber : String = "" {
        didSet {
            defaults.setObject(myPhoneNumber, forKey: "myPhoneNumber")
        }
    }
    
    static var canAllowFriendsToFind : Bool = false {
        didSet {
            defaults.setObject(canAllowFriendsToFind, forKey: "canAllowFriendsToFind")
        }
    }
    
    static var haveAskedToFindFriendsWithFlare : Bool = false {
        didSet {
            defaults.setBool(haveAskedToFindFriendsWithFlare, forKey: "haveAskedToFindFriendsWithFlare")
        }
    }
    
    static var canFindFriendsWithFlare : Bool = false {
        didSet {
            defaults.setBool(canFindFriendsWithFlare, forKey: "canFindFriendsWithFlare")
        }
    }
    
    static var haveVerifiedPhoneNumber : Bool = false {
        didSet {
            defaults.setBool(haveVerifiedPhoneNumber, forKey: "haveVerifiedPhoneNumber")
        }
    }
    
    static var canSendCloudMessage : Bool = false {
        didSet {
            defaults.setBool(canSendCloudMessage, forKey: "canSendCloudMessage")
        }
    }
}
