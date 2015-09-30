//
//  UIStoryboardSegue+BrickBot.swift
//  BrickBot
//
//  Created by Shannon Young on 10/2/15.
//  Copyright © 2015 Smallwisdom. All rights reserved.
//

import UIKit

extension UIStoryboardSegue {
    
    func destinationRootViewController() -> UIViewController {
        if let navVC = self.destinationViewController as? UINavigationController where navVC.viewControllers.count > 0 {
            return navVC.viewControllers[0]
        }
        else if let tabVC = self.destinationViewController as? UITabBarController,
            let selectedVC = tabVC.selectedViewController {
            return selectedVC
        }
        return self.destinationViewController
    }

}
