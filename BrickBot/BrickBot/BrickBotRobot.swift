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
    func sendSerialData(data: NSData!)
}

enum BBControlFlag: UInt8 {
    case Remote = 0xF0
    case Autopilot = 0xF1
}

struct BrickBotRobotPosition {
    
    var steer: UInt8 = 0
    var dir: UInt8 = 0
    
    init(ballPosition: CGPoint) {
        let threshold = CGFloat(0.3)
        func roundPosition(pos: CGFloat) -> UInt8 {
            return (pos < -1 * threshold) ? 0 : (pos > threshold) ? 2 : 1;
        }
        self.steer = roundPosition(ballPosition.x)
        self.dir = roundPosition(ballPosition.y)
    }
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
    * Send a message to the robot with whether or not the autopilot (roving) mode should be ON. The 
    * autopilot is turned OFF by default when a BLE central device is connected to the peripheral.
    */
    func sendAutopilotOn(autopilotOn: Bool) {
        let data = NSData(bytes:[BBControlFlag.Autopilot.rawValue, autopilotOn ? 1 : 0] as [UInt8], length:2)
        self.sendSerialData(data)
    }
    
}
