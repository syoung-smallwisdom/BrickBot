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

public protocol BBRobotManager {
    
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






