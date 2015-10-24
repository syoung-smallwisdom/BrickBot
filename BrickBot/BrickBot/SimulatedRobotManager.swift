//
//  SimulatedRobotManager.swift
//  BrickBot
//
//  Created by Shannon Young on 9/28/15.
//  Copyright © 2015 Smallwisdom. All rights reserved.
//

import UIKit

class SimulatedRobotManager: NSObject, BBRobotManager {
    
    weak var delegate: BBRobotManagerDelegate?
    
    var messageCache: [BBControlFlag: BBRobotMessagePacket] = [:]
    
    var connectedRobot: BBRobot? {
        return robot.connected ? robot : nil
    }
    private var robot: SimulatedBrickBotRobot = SimulatedBrickBotRobot()
    
    var discoveredRobots: [NSUUID: BBRobot] = [:]
    
    func connect() {
        if (!robot.connected) {
            robot.connected = true;
            delegate?.didConnectRobot(self, robot: robot)
        }
    }
    
    func disconnect() {
        robot.connected = false;
        delegate?.didDisconnectRobot(self, robot: robot)
    }
    
    func connectRobot(robot: BBRobot) {
        connect()
    }
    
    func connectNextAvailableRobot() {
        connect()
    }

    func readMotorCalibration(completion:(BBMotorCalibration?) ->()) {
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            completion(BBMotorCalibration())
        }
    }
    
    func sendMessage(msgFlag: BBControlFlag, bytes: [UInt8]?) {
        print("\nsendMessage \(msgFlag) \(bytes)");
    }
}

class SimulatedBrickBotRobot: NSObject, BBRobot {
    
    var identifier: NSUUID! = NSUUID()
    
    var connected: Bool = false
    
    var name: String! = "SimBot"
    
    var motorCalibrationData: NSData?
    
    var maxRobotNameLength: Int {
        return 10
    }
    
    func sendSerialData(data: NSData!) {
        print("\nsendSerialData \(data)", terminator: "");
    }
    
    func setScratchBank(bank: Int, data: NSData!) {
        print("\nsetScratchBank \(bank) data:\(data)", terminator: "");
    }
    
}