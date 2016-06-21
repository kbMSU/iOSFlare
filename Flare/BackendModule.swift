//
//  BackendModule.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 3/1/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import Foundation
import Parse
import MessageUI

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
                
                // Save this installation
                installation.setObject(DataModule.myCountryCode, forKey: "CountryCode")
                installation.setObject(DataModule.myPhoneNumber, forKey: "Number")
                installation.setObject(fullPhone, forKey: "FullPhone")
                try installation.save()
                
                // Is a device already saved for this phone number 
                let query = PFQuery(className: "Device").whereKey("FullPhone", equalTo: fullPhone)
                let results = try query.findObjects()
                if results.isEmpty {
                    // If not, then we need to save this device
                    let newDevice = PFObject(className: "Device")
                    newDevice["DeviceType"] = "iOS"
                    newDevice["CountryCode"] = DataModule.myCountryCode
                    newDevice["Number"] = DataModule.myPhoneNumber
                    newDevice["FullPhone"] = fullPhone
                    try newDevice.save()
                } else {
                    let device = results[0]
                    let type = device["DeviceType"] as! String
                    if type != "iOS" {
                        device.setObject("iOS", forKey: "DeviceType")
                        try device.save()
                    }
                }
                
                dispatch_async(GCDModule.GlobalMainQueue) {
                    self.delegate.registrationSuccess()
                }
            } catch {
                dispatch_async(GCDModule.GlobalMainQueue) {
                    self.delegate.registrationError(error)
                }
            }
        }
    }
    
    func updateRegistration(newCountryCode : String, newPhoneNumber : String) {
        dispatch_async(GCDModule.GlobalUserInitiatedQueue) {
            var installationUpdated = false
            let installation = PFInstallation.currentInstallation()
            let fullPhone = newCountryCode + newPhoneNumber
            let oldPhone = DataModule.myCountryCode + DataModule.myPhoneNumber

            do {
                installation.setObject(newCountryCode, forKey: "CountryCode")
                installation.setObject(newPhoneNumber, forKey: "Number")
                installation.setObject(fullPhone, forKey: "FullPhone")
                try installation.save()
                
                installationUpdated = true
                
                let query = PFQuery(className: "Device").whereKey("FullPhone", equalTo: oldPhone)
                let results = try query.findObjects()
                if results.isEmpty {
                    installation.setObject(DataModule.myCountryCode, forKey: "CountryCode")
                    installation.setObject(DataModule.myPhoneNumber, forKey: "Number")
                    installation.setObject(oldPhone, forKey: "FullPhone")
                    try installation.save()
                    dispatch_async(GCDModule.GlobalMainQueue) {
                        self.delegate.updateRegistrationFailure(nil)
                    }
                    return
                } else {
                    let device = results[0]
                    device["CountryCode"] = newCountryCode
                    device["Number"] = newPhoneNumber
                    device["FullPhone"] = fullPhone
                    try device.save()
                }
                dispatch_async(GCDModule.GlobalMainQueue) {
                    self.delegate.updateRegistrationSuccess()
                }
            } catch {
                installation.setObject(DataModule.myCountryCode, forKey: "CountryCode")
                installation.setObject(DataModule.myPhoneNumber, forKey: "Number")
                installation.setObject(oldPhone, forKey: "FullPhone")
                if installationUpdated {
                    installation.saveInBackground()
                }
                dispatch_async(GCDModule.GlobalMainQueue) {
                    self.delegate.updateRegistrationFailure(error)
                }
            }
        }
    }
    
    func unregister() {
        dispatch_async(GCDModule.GlobalUserInitiatedQueue) {
            do {
                let query = PFQuery(className: "Device").whereKey("FullPhone", equalTo: DataModule.myCountryCode + DataModule.myPhoneNumber)
                let results = try query.findObjects()
                if !results.isEmpty {
                    for result in results {
                        try result.delete()
                    }
                }
                dispatch_async(GCDModule.GlobalMainQueue) {
                    self.delegate.unregisterSuccess()
                }
            } catch {
                dispatch_async(GCDModule.GlobalMainQueue) {
                    self.delegate.unregisterError(error)
                }
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
                
                
                dispatch_async(GCDModule.GlobalMainQueue) {
                    self.delegate.findFriendsWithFlareSuccess()
                }
            } catch {
                dispatch_async(GCDModule.GlobalMainQueue) {
                    self.delegate.findFriendsWithFlareError(error)
                }
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
                    return
                }
            }
            dispatch_async(GCDModule.GlobalMainQueue) {
                self.delegate.sendTwilioMessageSuccess()
            }
        }
    }
    
    func sendFlare(numbers : [PhoneNumber], message : String, location : CLLocation, sender : UIViewController) {
        let result = SendFlareResult()
        
        var numbersWithFlare = [PhoneNumber]()
        var numbersWithoutFlare = [String]()
        
        for number in numbers {
            if number.hasFlare {
                numbersWithFlare.append(number)
            } else {
                numbersWithoutFlare.append(number.digits)
            }
        }

        let latitude = "\(location.coordinate.latitude)"
        let longitude = "\(location.coordinate.longitude)"
        
        let noFlareMessage = message+" http://maps.google.com/?q="+latitude+","+longitude+"  "+"Sent from Flare"
        
        dispatch_async(GCDModule.GlobalUserInitiatedQueue) {
            if !numbersWithFlare.isEmpty {
                for number in numbersWithFlare {
                    do {
                        var params = [String : String]()
                        params["text"] = message
                        params["phone"] = DataModule.myPhoneNumber
                        params["latitude"] = latitude
                        params["longitude"] = longitude
                        params["to"] = number.digits
                        try PFCloud.callFunction("SendFlare", withParameters: params)
                        
                        let flare = Flare(phoneNumber: number.digits, name: number.digits, type: .OutgoingFlare, message: message, timeStamp: NSDate(), contactId: nil, image: nil, latitude: latitude, longitude: longitude)
                        flare.loadFromContact()
                        DataModule.addFlare(flare)
                    } catch {
                        result.failed = true
                        result.numbersFailedToSend.append(number.digits)
                        continue
                    }
                }
            }
            
            if !numbersWithoutFlare.isEmpty {
                if DataModule.canSendCloudMessage {
                    for number in numbersWithoutFlare {
                        do {
                            var params = [String : String]()
                            var to = number
                            if to.characters.count != DataModule.myPhoneNumber.characters.count {
                                to = "+" + to
                            }
                            params["to"] = to
                            params["message"] = noFlareMessage
                            try PFCloud.callFunction("SendTwilioMessage", withParameters: params)
                        } catch {
                            result.failed = true
                            result.numbersFailedToSend.append(number)
                            continue
                        }
                    }
                } else {
                    result.message = noFlareMessage
                    result.numbersToIMessage.appendContentsOf(numbersWithoutFlare)
                }
            }
            
            dispatch_async(GCDModule.GlobalMainQueue) {
                self.delegate.sendFlareResult(result)
            }
        }
    }
    
    func acceptFlare(to: String, message: String) {
        dispatch_async(GCDModule.GlobalUserInitiatedQueue) {
            do {
                var params = [String : String]()
                params["to"] = to
                params["text"] = message
                params["from"] = DataModule.myPhoneNumber
                try PFCloud.callFunction("AcceptFlare", withParameters: params)
                
                let flare = Flare(phoneNumber: to, name: to, type: .OutgoingResponse, message: message, timeStamp: NSDate())
                flare.loadFromContact()
                DataModule.addFlare(flare)
            } catch {
                dispatch_async(GCDModule.GlobalMainQueue) {
                    self.delegate.sendFlareResponseError(error)
                }
            }
            
            dispatch_async(GCDModule.GlobalMainQueue) {
                self.delegate.sendFlareResponseSuccess()
            }
        }
    }
    
    func declineFlare(to: String, message: String) {
        dispatch_async(GCDModule.GlobalUserInitiatedQueue) {
            do {
                var params = [String : String]()
                params["to"] = to
                params["text"] = message
                params["from"] = DataModule.myPhoneNumber
                try PFCloud.callFunction("DeclineFlare", withParameters: params)
                
                let flare = Flare(phoneNumber: to, name: to, type: .OutgoingResponse, message: message, timeStamp: NSDate())
                flare.loadFromContact()
                DataModule.addFlare(flare)
            } catch {
                dispatch_async(GCDModule.GlobalMainQueue) {
                    self.delegate.sendFlareResponseError(error)
                }
            }
            
            dispatch_async(GCDModule.GlobalMainQueue) {
                self.delegate.sendFlareResponseSuccess()
            }
        }
    }
}