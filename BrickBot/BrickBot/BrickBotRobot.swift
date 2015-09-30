//
//  BrickBotRobot.swift
//  BrickBot
//
//  Created by Shannon Young on 9/23/15.
//  Copyright © 2015 Smallwisdom. All rights reserved.
//

import UIKit

protocol BrickBotRobot {
    var identifier: NSUUID! { get }
    var connected: Bool { get }
    var robotName: String? { get }
    var maxRobotNameLength: Int { get }
    func saveRobotName(robotName: String)
    func saveMotorCalibration(calibration: BrickBotMotorCalibration)
    func sendSerialData(data: NSData!)
}

let RobotNameScratchBank = 1
let MotorCalibrationScratchBank = 2
let emptyBank = NSData(bytes: [0], length: 1)

enum BBControlFlag: UInt8 {
    case Remote = 0xF0
    case Autopilot = 0xF1
    case MotorCalibration = 0xF2
    case ResetCalibration = 0xF3
}

struct BrickBotRobotPosition: Equatable {

    var steer: UInt8 = 0
    var dir: UInt8 = 0
    
    init(ballPosition: CGPoint) {
        let threshold = CGFloat(0.3)
        func roundPosition(pos: CGFloat) -> UInt8 {
            return (pos < -1 * threshold) ? 0 : (pos > threshold) ? 2 : 1
        }
        self.steer = roundPosition(ballPosition.x)
        self.dir = roundPosition(ballPosition.y)
    }
}

func == (lhs: BrickBotRobotPosition, rhs: BrickBotRobotPosition) -> Bool {
    return lhs.steer == rhs.steer && lhs.dir == rhs.dir
}

enum BrickBotMotorCalibrationState: Int {
    case ForwardLeft = 0, ForwardStraight = 1, ForwardRight = 2, Count
}

struct BrickBotMotorCalibration: Equatable {
    
    var calibrationStates:[CGFloat] = [-0.5, 0, 0.5]
    
    init() {
        // default value already set
    }
    
    init(data: NSData?) {
        // Check that the data is valid
        if let data = data where (data.length != emptyBank) { // bank returns a zero if not set
            let bytes = Array(UnsafeBufferPointer(start: UnsafePointer<UInt8>(data.bytes), count: data.length))
            for (var ii=0; ii < calibrationStates.count && ii < bytes.count; ii++) {
                calibrationStates[ii] = (CGFloat(bytes[ii]) - 100)/100
            }
        }
    }
    
    func bytes() -> [UInt8] {
        var bytes: [UInt8] = []
        for calibration in calibrationStates {
            bytes += [UInt8(calibration * 100 + 100)]
        }
        return bytes
    }
}

func == (lhs: BrickBotMotorCalibration, rhs: BrickBotMotorCalibration) -> Bool {
    return lhs.calibrationStates == rhs.calibrationStates
}

extension BrickBotRobot {
    
    /**
    * Send a message to the robot with the current position (Forward/Reverse/Left/Right) and whether
    * or not the remote is turned on. This is sent as a 2 Byte message where the first byte is the 
    * "control" and the second byte is the struct defining the data. Swift does not play nicely with 
    * C structs and so I am using bit shifting to build the data struct. syoung 09/28/2015
    */
    func sendBallPosition(ballPosition: CGPoint, remoteOn: Bool) {

        let robotPosition = BrickBotRobotPosition(ballPosition: ballPosition)
        let controlByte = remoteOn ? (robotPosition.steer | robotPosition.dir << 2 | 1 << 4) : 0;

        let data = NSData(bytes:[BBControlFlag.Remote.rawValue, controlByte] as [UInt8], length:2)
        self.sendSerialData(data)
    }
    
    /**
    * Send a message to the robot with the motor calibration data. This is *not* automatically saved
    * to the robot, but will dynamically update the calibration values on the robot.
    */
    func sendMotorCalibration(calibration: BrickBotMotorCalibration) {
        var bytes = calibration.bytes()
        bytes.insert(BBControlFlag.MotorCalibration.rawValue, atIndex: 0)
        let data = NSData(bytes:bytes, length:bytes.count)
        self.sendSerialData(data)
    }
    
    /**
    * Send a message to the robot to reset the calibration state
    */
    func sendResetCalibration() {
        let data = NSData(bytes:[BBControlFlag.ResetCalibration.rawValue] as [UInt8], length:1)
        self.sendSerialData(data)
    }
    
    /**
    * Send a message to the robot with whether or not the autopilot (roving) mode should be ON. The 
    * autopilot is turned OFF by default when a BLE central device is connected to the peripheral.
    */
    func sendAutopilotOn(autopilotOn: Bool) {
        let data = NSData(bytes:[BBControlFlag.Autopilot.rawValue, autopilotOn ? 1 : 0] as [UInt8], length:2)
        self.sendSerialData(data)
    }
    
}
