//
//  UIApplicationExtension.swift
//  Flare
//
//  Created by Karthik Balasubramanian on 4/12/16.
//  Copyright © 2016 Karthik Balasubramanian. All rights reserved.
//

import Foundation

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}

