//
//  RobotManager.swift
//  BrickBot
//
//  Created by Shannon Young on 9/15/15.
//  Copyright © 2015 Smallwisdom. All rights reserved.
//

import UIKit

protocol RobotManagerDelegate {
    func didConnectRobot(robotManager: RobotManager, robot: BrickBotRobot)
    func didDisconnectRobot(robotManager: RobotManager, robot: BrickBotRobot)
    func didTimeoutDiscovery(robotManager: RobotManager)
}

protocol RobotManager {
    
    /**
    * Use a simply delegate pattern to manage who handles the UI/UX
    */
    var delegate: RobotManagerDelegate? { get set }
    
    /**
    * Pointer to the currently connected robot that you are controlling
    */
    var connectedRobot: BrickBotRobot? { get }
    
    /**
    * Dictionary of all the robots that have been found by this manager
    */
    var discoveredRobots: [NSUUID: BrickBotRobot] { get }
    
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
    func connectRobot(robot: BrickBotRobot)
    
    /**
    * In the case where multiple robots are discovered, connect to the next one in the list.
    */
    func connectNextAvailableRobot()
}






