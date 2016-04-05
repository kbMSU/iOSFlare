//
//  SlideOutModule.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 4/5/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import Foundation
import UIKit

class SlideOutModule {
    static let instance = SlideOutModule()
    private init() {}
    
    static var slideOutManager : MainContainerViewController?
    
    static func slideOut() {
        slideOutManager!.slideOut()
    }
}