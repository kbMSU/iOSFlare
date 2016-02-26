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
    
    private var delegate : ContactModuleDelegate

    init(delegate : ContactModuleDelegate) {
        self.delegate = delegate
    }
    
    func authorizeContacts() {
        dispatch_async(GCDModule.GlobalUtilityQueue) {
            if CNContactStore.authorizationStatusForEntityType(.Contacts) !=
                CNAuthorizationStatus.Authorized {
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
    
    private func getContacts() {
        do {
            let containers = try contactsStore.containersMatchingPredicate(nil)
            var contacts = [CNContact]()
            for container in containers {
                let fetchPredicate = CNContact.predicateForContactsInContainerWithIdentifier(container.identifier)
                let containerResults = try contactsStore.unifiedContactsMatchingPredicate(fetchPredicate, keysToFetch: keys)
                contacts.appendContentsOf(containerResults)
            }
            for c in contacts {
                DataModule.contacts.append(Contact(contact: c))
            }
            sendResponseToDelegate(ErrorTypes.None)
        } catch {
            sendResponseToDelegate(ErrorTypes.Error)
        }
    }
    
    private func sendResponseToDelegate(response : ErrorTypes) {
        dispatch_async(GCDModule.GlobalMainQueue) {
            self.delegate.retreiveResult(response)
        }
    }
}
