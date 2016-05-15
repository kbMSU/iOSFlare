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
            // If it has a presented view controller then it could either be a modal full screen or a popup or an alert
            if let _ = presented as? PopupViewController {
                return base
            } else if let _ = presented as? UIAlertController {
                return base
            } else {
                return topViewController(presented)
            }
        }
        return base
    }
}

