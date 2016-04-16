//
//  ContactsModule.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 2/26/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import Foundation
import Contacts
import UIKit

class ContactsModule {
    
    private let contactsStore = CNContactStore()
    private let keys = [CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey,CNContactThumbnailImageDataKey,CNContactIdentifierKey]
    
    private var delegate : ContactModuleDelegate?

    init() {
        
    }
    
    init(delegate : ContactModuleDelegate) {
        self.delegate = delegate
    }
    
    func isAuthorized() -> Bool {
        return CNContactStore.authorizationStatusForEntityType(.Contacts) == .Authorized
    }
    
    func authorizeContacts() {
        dispatch_async(GCDModule.GlobalUtilityQueue) {
            if CNContactStore.authorizationStatusForEntityType(.Contacts) != .Authorized {
                self.contactsStore.requestAccessForEntityType(.Contacts, completionHandler: {(access,error) -> Void in
                    if access {
                        self.getContacts()
                    } else {
                        self.sendResponseToDelegate(ErrorTypes.Unauthorized)
                    }
                })
            } else {
                self.getContacts()
            }
        }
    }
    
    func getContacts() {
        do {
            let containers = try contactsStore.containersMatchingPredicate(nil)
            var contacts = [CNContact]()
            for container in containers {
                let fetchPredicate = CNContact.predicateForContactsInContainerWithIdentifier(container.identifier)
                let containerResults = try contactsStore.unifiedContactsMatchingPredicate(fetchPredicate, keysToFetch: keys)
                contacts.appendContentsOf(containerResults)
            }
            for contact in contacts {
                if contact.phoneNumbers.isEmpty {
                    continue
                }
                DataModule.contacts.append(Contact(contact: contact))
            }
            sendResponseToDelegate(ErrorTypes.None)
        } catch {
            print(error)
            sendResponseToDelegate(ErrorTypes.Error)
        }
    }
    
    private func sendResponseToDelegate(response : ErrorTypes) {
        if delegate == nil {
            return
        }
        
        dispatch_async(GCDModule.GlobalMainQueue) {
            self.delegate!.retreiveResult(response)
        }
    }
}
