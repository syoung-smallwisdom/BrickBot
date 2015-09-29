//
//  UIAlertController+BrickBot.swift
//  BrickBot
//
//  Created by Shannon Young on 9/28/15.
//  Copyright © 2015 Smallwisdom. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    static func showAlert(title title: String!, message: String!) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .Cancel) { action -> Void in})
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }

}
