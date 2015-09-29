//
//  SimulatedBrickBotRobot.swift
//  BrickBot
//
//  Created by Shannon Young on 9/28/15.
//  Copyright © 2015 Smallwisdom. All rights reserved.
//

import UIKit

class SimulatedBrickBotRobot: NSObject, BrickBotRobot {
    
    var identifier: NSUUID! = NSUUID()
    
    var connected: Bool = false
    
    func sendSerialData(data: NSData!) {
        print("sendSerialData \(data)", terminator: "");
    }

}
