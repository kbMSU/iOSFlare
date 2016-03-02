//
//  BackendModuleDelegate.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 3/1/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import Foundation

protocol BackendModuleDelegate {
    func findFriendsWithFlareSuccess()
    func findFriendsWithFlareError(error: ErrorType)
}

/*
Currently Swift ( 2.1 ) does not support optional protocol methods without having the objc marker.
But protocols with the tag cannot be used with classes that do not inherit from objc classes and 
also cannot be used with structs. To overcome this we are going to extend the protocol and have 
default implementations of the methods that are optional.
*/

extension BackendModuleDelegate {
    func findFriendsWithFlareSuccess() {}
    func findFriendsWithFlareError(error: ErrorType) {}
}