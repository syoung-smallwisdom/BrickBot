//
//  UIApplication+BrickBot.swift
//  BrickBot
//
//  Created by Shannon Young on 10/5/15.
//  Copyright © 2015 Smallwisdom. All rights reserved.
//

import UIKit

extension UIApplication {
    public static func isSimulator() -> Bool {
        return TARGET_IPHONE_SIMULATOR == 1
    }
}
