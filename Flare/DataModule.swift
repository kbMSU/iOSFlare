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

    static var contacts : [Contact] = [Contact]()
}
