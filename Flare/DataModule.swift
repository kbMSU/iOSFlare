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
    
    static var myCountryCode : String = "" {
        didSet {
            
        }
    }
    
    static var myPhoneNumber : String = "" {
        didSet {
            
        }
    }
    
    static var haveAskedToAllowFriendsToFind : Bool = false {
        didSet {
            
        }
    }
    
    static var canAllowFriendsToFind : Bool = false {
        didSet {
            
        }
    }
    
    static var haveAskedToFindFriendsWithFlare : Bool = false {
        didSet {
            
        }
    }
    
    static var canFindFriendsWithFlare : Bool = false {
        didSet {
            
        }
    }
    
    static var haveVerifiedPhoneNumber : Bool = false {
        didSet {
            
        }
    }
    
    static var canSendCloudMessage : Bool = false {
        didSet {
            
        }
    }
}
