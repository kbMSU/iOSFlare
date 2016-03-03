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
    
    func sendFlare(numbers : [PhoneNumber], message : String, location : CLLocation) {
        var numbersWithFlare = [String]()
        var numbersWithoutFlare = [String]()
        
        for number in numbers {
            if number.hasFlare {
                numbersWithFlare.append(number.digits)
            } else {
                numbersWithoutFlare.append(number.digits)
            }
        }
        
        let latitude = "\(location.coordinate.latitude)"
        let longitude = "\(location.coordinate.longitude)"
        
        dispatch_async(GCDModule.GlobalUserInitiatedQueue) {
            for number in numbersWithFlare {
                do {
                    var params = [String : String]()
                    params["text"] = message
                    params["phone"] = DataModule.myPhoneNumber
                    params["latitude"] = latitude
                    params["longitude"] = longitude
                    params["to"] = number
                    try PFCloud.callFunction("SendFlare", withParameters: params)
                } catch {
                    continue
                }
            }
        }
        
        let body = message+" http://maps.google.com/?q="+latitude+","+longitude+"  "+"Sent from Flare"
        if DataModule.canSendCloudMessage {
            sendTwilioMessage(numbersWithoutFlare, message: body)
        } else {
            // send sms
        }
    }
}