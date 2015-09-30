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
    
    var robotName: String?
    
    var maxRobotNameLength: Int {
        return 10
    }
    
    var motorCalibration: BrickBotMotorCalibration?
    
    func saveRobotName(robotName: String) {
        print("\nsave \(robotName)")
        self.robotName = robotName
    }
    
    func saveMotorCalibration(calibration: BrickBotMotorCalibration) {
        print("\nsave \(calibration)")
        self.motorCalibration = calibration
    }
    
    func sendSerialData(data: NSData!) {
        print("\nsendSerialData \(data)", terminator: "");
    }

}
