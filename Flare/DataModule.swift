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
    
    static func setup() {
        
    }
    
    static var contacts = [Contact]()
    
    // LOOK INTO didSet FOR VAR
    
    private static var myNumber = "8147486472" // change default to nil
    static var myPhoneNumber : String {
        get {
            return myNumber
        }
        set {
            myNumber = newValue
            // save locally
        }
    }
    
    private static var askedToAllowFriendsToFind = false
    static var haveAskedToAllowFriendsToFind : Bool {
        get {
            return askedToAllowFriendsToFind
        }
        set {
            askedToAllowFriendsToFind = newValue
            // save locally
        }
    }
    
    private static var allowFriendsToFind = false
    static var canAllowFriendsToFind : Bool {
        get {
            return allowFriendsToFind
        }
        set {
            allowFriendsToFind = newValue
            // save locally
        }
    }
    
    private static var askedToFindFriendsWithFlare = false
    static var haveAskedToFindFriendsWithFlare : Bool {
        get {
            return askedToFindFriendsWithFlare
        }
        set {
            askedToFindFriendsWithFlare = newValue
            // save locally
        }
    }
    
    private static var findFriendsWithFlare = false
    static var canFindFriendsWithFlare : Bool {
        get {
            return findFriendsWithFlare
        }
        set {
            findFriendsWithFlare = newValue
            // save locally
        }
    }
    
    private static var verifiedPhoneNumber = false
    static var haveVerifiedPhoneNumber : Bool {
        get {
            return verifiedPhoneNumber
        }
        set {
            verifiedPhoneNumber = newValue
            // save locally
        }
    }
    
    private static var sendCloudMessage = true // Change default to false
    static var canSendCloudMessage : Bool {
        get {
            return sendCloudMessage
        } set {
            sendCloudMessage = newValue
            // save locally
        }
    }
}
