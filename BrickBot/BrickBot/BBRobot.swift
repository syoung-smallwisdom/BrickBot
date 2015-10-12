//
//  BBRobot.swift
//
//  Created by Shannon Young on 9/23/15.
//  Copyright © 2015 Smallwisdom. All rights reserved.
//

import UIKit

public protocol BBMessageTransmitter {
    func sendSerialData(data: NSData!)
}

public protocol BBRobot: class, BBMessageTransmitter {
    var identifier: NSUUID! { get }
    var connected: Bool { get }
    var robotName: String? { get set }
    var motorCalibrationData: NSData? { get set }
    func setScratchBank(bank: Int, data: NSData!)
}

public let BBEmptyBank = NSData(bytes: [0], length: 1)
public let BBNameStringEncoding = NSUTF8StringEncoding

public enum BBScratchBank: Int {
    case SketchId = 1
    case RobotName = 2
    case MotorCalibration = 3
}

public enum BBControlFlag: UInt8 {
    case Remote = 0xF0
    case Autopilot = 0xF1
    case MotorCalibration = 0xF2
    case ResetCalibration = 0xF3
    case LeftMotorChanged = 0xF4
    case RightMotorChanged = 0xF5
}

public struct BBRobotMessagePacket {
    
    let robotUUID: NSUUID
    let data: NSData
    var received = false
    let timestamp: NSDate = NSDate()
    
    func isMatching(robotUUID: NSUUID, data: NSData) -> Bool {
        return robotUUID == self.robotUUID && data == self.data;
    }
    
    func isExpired() -> Bool {
        return (timestamp.timeIntervalSinceNow > 60) || (timestamp.timeIntervalSinceNow > 5 && !received);
    }
}

public extension BBRobot {
    
    /**
    * Returns the max length for a robot name.
    */
    var maxRobotNameLength: Int {
        return 20
    }
    
    /**
    * Save the robot name to the robot. This is different from the local save using the robotName setter.
    */
    func saveRobotName(robotName: String) {
        guard robotName.lengthOfBytesUsingEncoding(BBNameStringEncoding) <= maxRobotNameLength else {
            assertionFailure("Robot name is too long")
            return
        }
        print("saveRobotName:\(robotName)");
        let data = robotName.dataUsingEncoding(BBNameStringEncoding)
        self.setScratchBank(BBScratchBank.RobotName.rawValue, data: data)
        self.robotName = robotName
    }
    
    /**
    * Save the motor calibration data. This is different from a send in that a "send" sets it temporarily 
    * to the robot. This saves to the robot memory.
    */
    func saveMotorCalibration(calibration: BBMotorCalibration) {
        let bytes = calibration.bytes()
        print("saveMotorCalibration:\(bytes)");
        let data = NSData(bytes:bytes, length:bytes.count)
        self.setScratchBank(BBScratchBank.MotorCalibration.rawValue, data: data)
        self.motorCalibrationData = data
    }
    
}
