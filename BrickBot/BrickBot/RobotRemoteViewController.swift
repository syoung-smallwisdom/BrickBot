//
//  RobotRemoteViewController.swift
//  BrickBot
//
//  Created by Shannon Young on 9/15/15.
//  Copyright © 2015 Smallwisdom. All rights reserved.
//

import UIKit

class RobotRemoteViewController: UIViewController, RobotManagerDelegate {

    // UI
    @IBOutlet weak var screenButton: GravityPanControl!
    @IBOutlet weak var autopilotSwitch: UISwitch!
    @IBOutlet weak var ballView: BallView!
    @IBOutlet weak var ballX: NSLayoutConstraint!
    @IBOutlet weak var ballY: NSLayoutConstraint!
    
    // Robot
    let robotManager = BeanRobotManager()
    var robot:BrickBotRobot? {
        return robotManager.connectedRobot
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Connect to the robot manager
        robotManager.delegate = self
        robotManager.connect()
        
        // When the app enters/exits foreground we want to disconnect the remote control
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"willEnterForeground", name:UIApplicationWillEnterForegroundNotification, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"didEnterBackground", name:UIApplicationDidEnterBackgroundNotification, object:nil)
    }
    
    @IBAction func didTouchUp(sender: AnyObject) {
        ballView.backgroundColor = UIColor.redColor()
        ballPosition = CGPointZero
    }
    
    @IBAction func didTouchDown(sender: AnyObject) {
        ballView.backgroundColor = UIColor.greenColor();
        ballPosition = CGPointZero
    }
    
    @IBAction func didChangePosition(sender: GravityPanControl) {
        ballPosition = sender.position
    }
    
    @IBAction func autopilotChanged(sender: UISwitch) {
        robot?.sendAutopilotOn(sender.on)
    }
    
    var remoteOn:Bool {
        get {
            return screenButton.tracking
        }
    }
    
    var autopilotOn:Bool {
        get {
            return autopilotSwitch.on
        }
    }
    
    var ballPosition:CGPoint = CGPoint() {
        didSet {
            
            // Set the ball position in the UI
            ballX.constant = ballPosition.x * self.view.bounds.width * 0.8 / 2.0
            ballY.constant = ballPosition.y * self.view.bounds.height * 0.8 / -2.0
            ballView.position = ballPosition
            ballView.layoutIfNeeded()
            
            // Send ball position to the bean
            robot?.sendBallPosition(ballPosition, remoteOn: remoteOn)
        }
    }
    
    
    // MARK: RobotManagerDelegate
    
    func didConnectRobot(robotManager: RobotManager, robot: BrickBotRobot) {
        ballView.connected = true
    }
    
    func didDisconnectRobot(robotManager: RobotManager, robot: BrickBotRobot) {
        ballView.connected = false
    }
    
    func didTimeoutDiscovery(robotManager: RobotManager) {
        // TODO: Revist UI/UX of automatically attempting to connect to the next available robot when not. syoung 9/27/2015
        robotManager.connectNextAvailableRobot()
    }
    
    
    // MARK: App state handling
    
    func willEnterForeground() {
        autopilotSwitch.on = false
        robotManager.connect()
    }
    
    func didEnterBackground() {
        robotManager.disconnect()
    }
    
}
