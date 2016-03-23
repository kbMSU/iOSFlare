//
//  BackendModule.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 3/1/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import Foundation
import Parse

class BackendModule {
    
    var delegate : BackendModuleDelegate
    
    init(delegate : BackendModuleDelegate) {
        self.delegate = delegate
    }
    
    func register() {
        dispatch_async(GCDModule.GlobalUserInitiatedQueue) {
            do {
                let fullPhone = DataModule.myCountryCode + DataModule.myPhoneNumber
                let installation = PFInstallation.currentInstallation()
                
                // Are there already installations with this phone number
                let oldInstallations = try PFInstallation.query()!.whereKey("FullPhone", equalTo: fullPhone).findObjects()
                if !oldInstallations.isEmpty {
                    let old = oldInstallations[0]
                    // Is this installation a different object than this phone's installation ?
                    if installation.objectId != old.objectId {
                        // If it is, that means either we moved this phone number to a different phone or 
                        // we reinstalled on this phone. Either way, we have to delete the old installation
                        try old.delete()
                    }
                }
                
                // Save this installation
                installation.setObject(DataModule.myCountryCode, forKey: "CountryCode")
                installation.setObject(DataModule.myPhoneNumber, forKey: "Number")
                installation.setObject(fullPhone, forKey: "FullPhone")
                try installation.save()
                
                // Is a device already saved for this phone number 
                let query = PFQuery(className: "Device").whereKey("FullPhone", equalTo: DataModule.myCountryCode + DataModule.myPhoneNumber)
                let results = try query.findObjects()
                if results.isEmpty {
                    // If not, then we need to save this device
                    let newDevice = PFObject(className: "Device")
                    newDevice.setObject("iOS", forKey: "DeviceType")
                    newDevice.setObject(DataModule.myCountryCode, forKey: "CountryCode")
                    newDevice.setObject(DataModule.myPhoneNumber, forKey: "Number")
                    newDevice.setObject(fullPhone, forKey: "FullPhone")
                    try newDevice.save()
                } else {
                    let device = results[0]
                    if let type = device.objectForKey("DeviceType") as? String where type != "iOS" {
                        device.setObject("iOS", forKey: "DeviceType")
                        try device.save()
                    }
                }
                
                self.delegate.registrationSuccess()
            } catch {
                self.delegate.registrationError(error)
            }
        }
    }
    
    func findFriendsWithFlare() {
        dispatch_async(GCDModule.GlobalUserInitiatedQueue) {
            var numbers = [String]()
            for contact in DataModule.contacts {
                for phoneNUmber in contact.phoneNumbers {
                    numbers.append(phoneNUmber.digits)
                }
            }
            let numberQuery = PFQuery(className: "Device")
            numberQuery.whereKey("Number", containedIn: numbers)
            let fullPhoneQuery = PFQuery(className: "Device")
            fullPhoneQuery.whereKey("FullPhone", containedIn: numbers)
            var queries = [PFQuery]()
            queries.append(numberQuery)
            queries.append(fullPhoneQuery)
            
            do {
                let devices = try PFQuery.orQueryWithSubqueries(queries).findObjects()
                for contact in DataModule.contacts {
                    var hasFlare = false
                    for phoneNumber in contact.phoneNumbers {
                        var phoneNumberHasFlare = false
                        for device:PFObject in devices {
                            let phone = device.valueForKey("FullPhone") as! String
                            if phone.containsString(phoneNumber.digits) {
                                phoneNumberHasFlare = true
                                break
                            }
                        }
                        
                        if phoneNumberHasFlare {
                            phoneNumber.hasFlare = true
                            hasFlare = true
                        }
                    }
                    contact.hasFlare = hasFlare
                }
            }
            catch {
                dispatch_async(GCDModule.GlobalMainQueue) {
                    self.delegate.findFriendsWithFlareError(error)
                }
            }
            
            dispatch_async(GCDModule.GlobalMainQueue) {
                self.delegate.findFriendsWithFlareSuccess()
            }
        }
    }
    
    func sendTwilioMessage(numbers : [String], message : String) {
        dispatch_async(GCDModule.GlobalUserInitiatedQueue) {
            for number in numbers {
                do {
                    var params = [String : String]()
                    params["to"] = number
                    params["message"] = message
                    try PFCloud.callFunction("SendTwilioMessage", withParameters: params)
                } catch {
                    dispatch_async(GCDModule.GlobalMainQueue) {
                        self.delegate.sendTwilioMessageError(error)
                    }
                    continue
                }
            }
            dispatch_async(GCDModule.GlobalMainQueue) {
                self.delegate.sendTwilioMessageSuccess()
            }
        }
    }
    
    func sendFlare(numbers : [String], message : String, location : CLLocation) {
        let latitude = "\(location.coordinate.latitude)"
        let longitude = "\(location.coordinate.longitude)"
        
        dispatch_async(GCDModule.GlobalUserInitiatedQueue) {
            for number in numbers {
                do {
                    var params = [String : String]()
                    params["text"] = message
                    params["phone"] = DataModule.myPhoneNumber
                    params["latitude"] = latitude
                    params["longitude"] = longitude
                    params["to"] = number
                    try PFCloud.callFunction("SendFlare", withParameters: params)
                } catch {
                    dispatch_async(GCDModule.GlobalMainQueue) {
                        self.delegate.sendFlareError(error)
                    }
                }
            }
            dispatch_async(GCDModule.GlobalMainQueue) {
                self.delegate.sendFlareSuccess()
            }
        }
    }
}