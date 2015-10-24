//
//  RobotSettingsViewController.swift
//  BrickBot
//
//  Created by Shannon Young on 9/28/15.
//  Copyright © 2015 Smallwisdom. All rights reserved.
//

import UIKit

class RobotSettingsViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    var robotManager:BBRobotManager!
    var robot:BBRobot? {
        return robotManager.connectedRobot
    }
    
    var selectedIndex = 1   // Forward
    var motorCalibration = BBMotorCalibration()
    var motorCalibrationChanged = false
    
    @IBOutlet weak var robotNameTextField: UITextField!
    @IBOutlet var arrowButtons: [SWArrowButton]!
    @IBOutlet var arrowDirectionLabels: [UILabel]!
    @IBOutlet weak var calibrationDial: CalibrationDial!
    @IBOutlet weak var motorSwitch: UISwitch!
    @IBOutlet weak var viewHitGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var loadingView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // setup initial values
        robotNameTextField.text = robot?.name ?? generateRandomName()
        
        robotManager.readMotorCalibration { [weak self](calibration:BBMotorCalibration?) -> () in
            guard let calibration = calibration, let strongSelf = self else { return }
            strongSelf.motorCalibration = calibration
            strongSelf.calibrationDial.dialPosition = calibration.calibrationStates[strongSelf.selectedIndex]
            strongSelf.loadingView.hidden = true
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // turn off the motors when exiting the view
        robotManager.sendBallPosition(CGPointZero, remoteOn: false)
    }
    
    @IBAction func cancelTapped(sender: AnyObject) {
        if motorCalibrationChanged {
            robotManager.sendResetCalibration()
        }
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func saveTapped(sender: AnyObject) {
        if let robotName = robotNameTextField.text where robotName != robot?.name {
            robotManager.sendRobotName(robotName)
        }
        if motorCalibrationChanged {
            robot?.saveMotorCalibration(motorCalibration)
        }
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func arrowTapped(sender: AnyObject) {
        // Check that not tracking
        guard !calibrationDial.tracking else { return }
        // And that this is toggling ON a different button from the currently selected
        guard let arrowButton = sender as? SWArrowButton,
            let idx = arrowButtons.indexOf(arrowButton) where idx != selectedIndex
            else {
                toggleMotorState()
                return
        }
        
        // turn motor off
        turnOffMotors();
        
        // Update arrow button states
        arrowButtons[selectedIndex].selected = false
        arrowDirectionLabels[selectedIndex].hidden = true
        arrowButtons[idx].selected = true
        arrowDirectionLabels[idx].hidden = false
        selectedIndex = idx
        
        // Update the calibration dial
        calibrationDial.dialPosition = motorCalibration.calibrationStates[selectedIndex]
    }
    
    func toggleMotorState() {
        motorSwitch.on = !motorSwitch.on
        motorSwitchChanged(motorSwitch)
    }
    
    func turnOffMotors() {
        // Turn off the motor switch
        motorSwitch.on = false
        motorSwitchChanged(motorSwitch)
    }
    
    @IBAction func motorSwitchChanged(sender: AnyObject) {
        if (motorSwitch.on) {
            robotManager.sendBallPosition(CGPointMake(CGFloat(selectedIndex - 1), 1), remoteOn: true)
        }
        else {
            robotManager.sendBallPosition(CGPointZero, remoteOn: false)
        }
    }
    
    @IBAction func calibrationDialTouchedDown(sender: AnyObject) {
        turnOffMotors()
    }

    @IBAction func calibrationDialPositionChanged(sender: AnyObject) {
        motorCalibrationChanged = true
        
        motorCalibration.setCalibration(selectedIndex, value:calibrationDial.dialPosition)
        robotManager.sendMotorCalibration(motorCalibration)
    }
    
    @IBAction func viewTapped(gesture: UIGestureRecognizer) {
        let location = gesture.locationOfTouch(0, inView: view)
        if (view.hitTest(location, withEvent: nil) != robotNameTextField) {
            robotNameTextField.resignFirstResponder()
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // Add listener to dismiss the keyboard
        viewHitGestureRecognizer.enabled = true
    }

    func textFieldDidEndEditing(textField: UITextField) {
        viewHitGestureRecognizer.enabled = false
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        // there is no longer a check for string length for a Swift string so bridge to obj-c
        let currentLength = textField.text?.lengthOfBytesUsingEncoding(BBNameStringEncoding) ?? 0
        let addLength = string.lengthOfBytesUsingEncoding(BBNameStringEncoding)
        return currentLength - range.length + addLength <= (robot?.maxRobotNameLength ?? 20)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - Random Name generator
    
    let randomNames = ["BeeBoo", "Rev", "Brinkle", "Tribecca", "Susan", "Lotta", "Grumbly"]
    func generateRandomName() -> String {
        let idx = Int(arc4random_uniform(UInt32(randomNames.count - 1)))
        return randomNames[idx]
    }
    

}
