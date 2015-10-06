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
}

public extension BBMessageTransmitter {
    
    /**
    * Send a message to the robot with the current position (Forward/Reverse/Left/Right) and whether
    * or not the remote is turned on. This is sent as a 2 Byte message where the first byte is the
    * "control" and the second byte is the struct defining the data. Swift does not play nicely with
    * C structs and so I am using bit shifting to build the data struct. syoung 09/28/2015
    */
    func sendBallPosition(ballPosition: CGPoint, remoteOn: Bool) {
        if (remoteOn) {
            sendPosition(BBRobotPosition(ballPosition: ballPosition))
        }
        else {
            sendPosition(nil)
        }
    }
    
    func sendPosition(position: BBRobotPosition?) {
        let controlByte = position?.rawValue ?? 0
        let data = NSData(bytes:[BBControlFlag.Remote.rawValue, controlByte] as [UInt8], length:2)
        print("sendPosition:\(data)");
        self.sendSerialData(data)
    }
    
    /**
    * Send a message to the robot with the motor calibration data. This is *not* automatically saved
    * to the robot, but will dynamically update the calibration values on the robot.
    */
    func sendMotorCalibration(calibration: BBMotorCalibration) {
        var bytes = calibration.bytes()
        print("motorCalibration:\(bytes)");
        bytes.insert(BBControlFlag.MotorCalibration.rawValue, atIndex: 0)
        let data = NSData(bytes:bytes, length:bytes.count)
        print("sendMotorCalibration:\(data)");
        self.sendSerialData(data)
    }
    
    /**
    * Send a message to the robot to reset the calibration state
    */
    func sendResetCalibration() {
        let data = NSData(bytes:[BBControlFlag.ResetCalibration.rawValue] as [UInt8], length:1)
        print("sendResetCalibration:\(data)");
        self.sendSerialData(data)
    }
    
    /**
    * Send a message to the robot with whether or not the autopilot (roving) mode should be ON. The
    * autopilot is turned OFF by default when a BLE central device is connected to the peripheral.
    */
    func sendAutopilotOn(autopilotOn: Bool) {
        let data = NSData(bytes:[BBControlFlag.Autopilot.rawValue, autopilotOn ? 1 : 0] as [UInt8], length:2)
        print("sendAutopilotOn:\(data)");
        self.sendSerialData(data)
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
