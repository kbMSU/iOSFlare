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
        defaultFlareMessage = defaults.stringForKey("defaultFlareMessage") ?? "Can you meet me here ?"
        defaultDeclineMessage = defaults.stringForKey("defaultDeclineMessage") ?? "Sorry, i can't make it"
        defaultAcceptMessage = defaults.stringForKey("defaultAcceptMessage") ?? "I'm on my way"
        
        //NSKeyedArchiver.archiveRootObject(groups, toFile: Group.ArchiveURL.path!)
        
        if let savedGroups = NSKeyedUnarchiver.unarchiveObjectWithFile(Group.ArchiveURL.path!) as? [Group] {
            groups += savedGroups
        }
    }
    
    static var contacts = [Contact]()
    static var groups = [Group]()
    static var didLoadFromNotification = false
    static var notificationInfo : NotificationInfo?
    static var currentLocation : CLLocation?
    
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
    
    static var defaultFlareMessage : String = "" {
        didSet {
            defaults.setObject(defaultFlareMessage, forKey: "defaultFlareMessage")
        }
    }
    
    static var defaultDeclineMessage : String = "" {
        didSet {
            defaults.setObject(defaultDeclineMessage, forKey: "defaultDeclineMessage")
        }
    }
    
    static var defaultAcceptMessage : String = "" {
        didSet {
            defaults.setObject(defaultAcceptMessage, forKey: "defaultAcceptMessage")
        }
    }
    
    static func addGroup(group : Group) {
        groups.append(group)
        NSKeyedArchiver.archiveRootObject(groups, toFile: Group.ArchiveURL.path!)
    }
    
    static func removeGroup(group : Group) {
        var index : Int = -1
        for i in 0 ..< groups.count {
            if groups[i].id == group.id {
                index = i
                break
            }
        }
        if index != -1 {
            groups.removeAtIndex(index)
            NSKeyedArchiver.archiveRootObject(groups, toFile: Group.ArchiveURL.path!)
        }
    }
}
