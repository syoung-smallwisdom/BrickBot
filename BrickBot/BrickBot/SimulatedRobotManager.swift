//
//  SimulatedRobotManager.swift
//  BrickBot
//
//  Created by Shannon Young on 9/28/15.
//  Copyright © 2015 Smallwisdom. All rights reserved.
//

import UIKit

class SimulatedRobotManager: NSObject, RobotManager {
    
    var delegate: RobotManagerDelegate?
    
    var connectedRobot: BrickBotRobot? {
        return robot.connected ? robot : nil
    }
    private var robot: SimulatedBrickBotRobot = SimulatedBrickBotRobot()
    
    var discoveredRobots: [NSUUID: BrickBotRobot] = [:]
    
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
    
    func connectRobot(robot: BrickBotRobot) {
        connect()
    }
    
    func connectNextAvailableRobot() {
        connect()
    }

    func readMotorCalibration(completion:(BrickBotMotorCalibration?) ->()) {
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            completion(self.robot.motorCalibration)
        }
    }

}
