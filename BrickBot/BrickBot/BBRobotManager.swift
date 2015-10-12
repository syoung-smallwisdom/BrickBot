//
//  BBRobotManager.swift
//
//  Created by Shannon Young on 9/15/15.
//  Copyright © 2015 Smallwisdom. All rights reserved.
//

import UIKit

// Swift: Because this is a delegate, we need to make it a class so that
// it can be weak and thus avoid a retain loop. syoung 10/6/2015
public protocol BBRobotManagerDelegate: class {
    func didConnectRobot(robotManager: BBRobotManager, robot: BBRobot)
    func didDisconnectRobot(robotManager: BBRobotManager, robot: BBRobot)
    func didTimeoutDiscovery(robotManager: BBRobotManager)
}

public protocol BBRobotManager: class {
    
    /**
    * Use a simply delegate pattern to manage who handles the UI/UX
    */
    var delegate: BBRobotManagerDelegate? { get set }
    
    /**
    * Pointer to the currently connected robot that you are controlling
    */
    var connectedRobot: BBRobot? { get }
    
    /**
    * Dictionary of all the robots that have been found by this manager
    */
    var discoveredRobots: [NSUUID: BBRobot] { get }
    
    /**
    * Message cache used to check if a message has already been sent and only resend if timeout
    */
    var messageCache: [BBControlFlag: BBRobotMessagePacket] { get set }
    
    /**
    * Connect to the robot manager and start searching for robots. By current design,
    * this will automatically connect to the robot if one is found.
    */
    func connect()
    
    /**
    * Disconnect from all robots and stop searching
    */
    func disconnect()
    
    /**
    * In the case where multiple robots are discovered, connect to this one, specifically.
    */
    func connectRobot(robot: BBRobot)
    
    /**
    * In the case where multiple robots are discovered, connect to the next one in the list.
    */
    func connectNextAvailableRobot()
    
    /**
    * Read the motor calibration data for the currently connected robot
    */
    func readMotorCalibration(completion:(BBMotorCalibration?) ->())
    
}


public extension BBRobotManager {
    
    /**
    * Send a message that is just the control flag
    */
    func sendMessage(msgFlag: BBControlFlag) {
        sendMessage(msgFlag, bytes: nil)
    }
    
    func sendMessage(msgFlag: BBControlFlag, bytes: [UInt8]?) {
        
        // Check that there is a connected bean.
        guard let robot = connectedRobot else { return }
        
        // Create the data packet
        let bytes:[UInt8] = [msgFlag.rawValue] + (bytes ?? [])
        let data = NSData(bytes: bytes, length: bytes.count)
        
        // Check to see if this message has already been sent and is *not* expired
        if let msg = messageCache[msgFlag] where msg.isMatching(robot.identifier, data: data) && !msg.isExpired() {
            return;
        }
        
        // Save the message to the cache
        messageCache[msgFlag] = BBRobotMessagePacket(robotUUID: robot.identifier, data: data, received: false)
        print("sendMessage: \(data)")
        robot.sendSerialData(data)
    }
    
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
        self.sendMessage(.Remote, bytes: [controlByte])
    }
    
    /**
    * Send a message to the robot with the motor calibration data. This is *not* automatically saved
    * to the robot, but will dynamically update the calibration values on the robot.
    */
    func sendMotorCalibration(calibration: BBMotorCalibration) {
        self.sendMessage(.MotorCalibration, bytes: calibration.bytes())
    }
    
    /**
    * Send a message to the robot to reset the calibration state
    */
    func sendResetCalibration() {
        self.sendMessage(.ResetCalibration, bytes: nil)
    }
    
    /**
    * Send a message to the robot with whether or not the autopilot (roving) mode should be ON. The
    * autopilot is turned OFF by default when a BLE central device is connected to the peripheral.
    */
    func sendAutopilotOn(autopilotOn: Bool) {
        self.sendMessage(.Autopilot, bytes: [autopilotOn ? 1 : 0])
    }
    
    /**
    * Received response from the robot manager
    */
    func didReceiveMessageResponse(robot: BBRobot, data: NSData) {
        
        // Get the bytes
        var bytes = [UInt8](count: data.length, repeatedValue: 0)
        data.getBytes(&bytes, length:data.length)
        
        if let controlByte = bytes.first, let msgFlag = BBControlFlag(rawValue: controlByte) {
            var range = NSMakeRange(NSNotFound, 0)
            if let msgPacket = messageCache[msgFlag] {
                if msgPacket.isMatching(robot.identifier, data: data) {
                    // Replace the message with one that is marked as received
                    messageCache[msgFlag]?.received = true
                }
                if (msgPacket.data.length < data.length) {
                    range = NSMakeRange(msgPacket.data.length, data.length - msgPacket.data.length)
                }
            }
            else if (msgFlag == .LeftMotorChanged || msgFlag == .RightMotorChanged) && bytes.count >= 2 {
                let motor = (msgFlag == .LeftMotorChanged) ? "Left" : "Right"
                let value = Int(bytes[1])
                print("\(motor) Motor Changed: \(value)")
                if (data.length > 2) {
                    range = NSMakeRange(2, data.length - 2)
                }
            }
            else {
                print("\nUnrecognized message received: \(bytes)")
            }
            
            if (range.location != NSNotFound) {
                didReceiveMessageResponse(robot, data: data.subdataWithRange(range))
            }
        }
        else if let debugStr = String(data:data, encoding:NSUTF8StringEncoding)  {
            print("\nMessage received: \(debugStr)")
        }
        else {
            print("\nUnrecognized message received: \(bytes)")
        }
    }
    
}






