//
//  SimulatedRobotManager.swift
//  BrickBot
//
//  Created by Shannon Young on 9/28/15.
//  Copyright © 2015 Smallwisdom. All rights reserved.
//

import UIKit

class SimulatedRobotManager: NSObject, RobotManager {
    
    /**
    * Use a simply delegate pattern to manage who handles the UI/UX
    */
    var delegate: RobotManagerDelegate?
    
    /**
    * Pointer to the currently connected robot that you are controlling
    */
    var connectedRobot: BrickBotRobot? {
        return robot.connected ? robot : nil
    }
    private var robot: SimulatedBrickBotRobot = SimulatedBrickBotRobot()
    
    /**
    * Dictionary of all the robots that have been found by this manager
    */
    var discoveredRobots: [NSUUID: BrickBotRobot] = [:]
    
    /**
    * Connect to the robot manager and start searching for robots. By current design,
    * this will automatically connect to the robot if one is found.
    */
    func connect() {
        if (!robot.connected) {
            robot.connected = true;
            delegate?.didConnectRobot(self, robot: robot)
        }
    }
    
    /**
    * Disconnect from all robots and stop searching
    */
    func disconnect() {
        robot.connected = false;
        delegate?.didDisconnectRobot(self, robot: robot)
    }
    
    /**
    * In the case where multiple robots are discovered, connect to this one, specifically.
    */
    func connectRobot(robot: BrickBotRobot) {
        connect()
    }
    
    /**
    * In the case where multiple robots are discovered, connect to the next one in the list.
    */
    func connectNextAvailableRobot() {
        connect()
    }

}
