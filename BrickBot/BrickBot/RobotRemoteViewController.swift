//
//  RobotRemoteViewController.swift
//  BrickBot
//
//  Created by Shannon Young on 9/15/15.
//  Copyright © 2015 Smallwisdom. All rights reserved.
//

import UIKit

class RobotRemoteViewController: UIViewController, BBRobotManagerDelegate {

    // UI
    @IBOutlet weak var screenButton: SWPanTiltControl!
    @IBOutlet weak var autopilotSwitch: UISwitch!
    @IBOutlet weak var ballView: BallView!
    @IBOutlet weak var ballX: NSLayoutConstraint!
    @IBOutlet weak var ballY: NSLayoutConstraint!
    @IBOutlet weak var settingsButton: SWSettingsButton!
    @IBOutlet weak var robotNameLabel: UILabel!
    
    // Robot
    lazy var robotManager: BBRobotManager = {
        return (UIApplication.isSimulator() ? SimulatedRobotManager() : BeanRobotManager()) as BBRobotManager
    }()
    var robot:BBRobot? {
        return robotManager.connectedRobot
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        robotNameLabel.text = ""
        
        // Connect to the robot manager on launch
        robotManager.delegate = self
        settingsButton.enabled = (robotManager.connectedRobot != nil)
        robotManager.connect()
        
        // When the app enters/exits foreground we want to disconnect the remote control
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"willEnterForeground", name:UIApplicationWillEnterForegroundNotification, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"didEnterBackground", name:UIApplicationDidEnterBackgroundNotification, object:nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        robotNameLabel.text = robot?.robotName
    }
    
    @IBAction func didTouchUp(sender: AnyObject) {
        screenButton.position = CGPointZero
        didChangePosition(sender)
    }
    
    @IBAction func didTouchDown(sender: AnyObject) {
        screenButton.position = CGPointZero
        didChangePosition(sender)
    }
    
    @IBAction func didChangePosition(sender: AnyObject) {
        ballPosition = screenButton.position
    }
    
    @IBAction func autopilotChanged(sender: AnyObject) {
        robotManager.sendAutopilotOn(autopilotSwitch.on)
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
            robotManager.sendBallPosition(ballPosition, remoteOn: remoteOn)
        }
    }
    
    // Turn off the autopilot when view will disappear
    func turnOffMotors() {
        if (autopilotOn) {
            autopilotSwitch.on = false;
            autopilotChanged(autopilotSwitch)
        }
    }
    
    
    // MARK: - RobotManagerDelegate
    
    func didConnectRobot(robotManager: BBRobotManager, robot: BBRobot) {
        ballView.connected = true
        settingsButton.enabled = true
        robotNameLabel.text = robot.robotName
    }
    
    func didDisconnectRobot(robotManager: BBRobotManager, robot: BBRobot) {
        ballView.connected = false
        settingsButton.enabled = false
        robotNameLabel.text = ""
    }
    
    func didTimeoutDiscovery(robotManager: BBRobotManager) {
        // TODO: Revist UI/UX of automatically attempting to connect to the next available robot when not. syoung 9/27/2015
        robotManager.connectNextAvailableRobot()
    }
    
    
    // MARK: - App state handling
    
    func willEnterForeground() {
        autopilotSwitch.on = false
        robotManager.connect()
        settingsButton.enabled = (robotManager.connectedRobot != nil)
    }
    
    func didEnterBackground() {
        robotManager.disconnect()
        settingsButton.enabled = false
    }
    

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let settingVC = segue.destinationRootViewController() as? RobotSettingsViewController {
            turnOffMotors()
            settingVC.robotManager = self.robotManager
        }
        else {
            assertionFailure("Unrecognized segue")
        }
    }
    
}
