//
//  BeanRobotManager.swift
//  BrickBot
//
//  Created by Shannon Young on 9/21/15.
//  Copyright © 2015 Smallwisdom. All rights reserved.
//

import UIKit

final class BeanRobotManager: NSObject, RobotManager, PTDBeanManagerDelegate, PTDBeanDelegate {
    
    // MARK: RobotManager
    
    var delegate: RobotManagerDelegate?
    
    var connectedRobot: BrickBotRobot?
    
    var discoveredRobots: [NSUUID: BrickBotRobot] = [:]

    func connect() {
        if (beanManager == nil) {
            beanManager = PTDBeanManager(delegate: self)
        }
        resetTimer()
    }
    
    func disconnect() {
        if let manager = self.beanManager {
            timer?.invalidate()
            beanManager = nil
            manager.delegate = nil
            manager.stopScanningForBeans_error(nil)
            manager.disconnectFromAllBeans(nil)
            connectedRobot = nil
            discoveredBeanUUIDs = []
            discoveredRobots = [:]
        }
    }
    
    func connectRobot(robot: BrickBotRobot) {
        guard !robot.connected || (robot.identifier != connectedRobot?.identifier) else {
            return
        }
        
        // Set this robot as the one to connect to
        lastConnectedRobotId = robot.identifier.UUIDString
        
        // Disconnect from the previous robot
        if let currentBot = self.connectedRobot {
            connectedRobot = nil
            if (currentBot.connected) {
                disconnectPeriperal(currentBot)
            }
        }
        
        // Connect to this robot
        if (robot.connected) {
            didConnectRobot(robot)
        }
        else {

            connectPeriperal(robot)
        }
    }
    
    func connectNextAvailableRobot() {
        // TODO: FIXME!! This will only work for 2 robots. syoung 10/02/2015
        guard let nextRobot = discoveredRobots.values.filter({$0.identifier.UUIDString != self.lastConnectedRobotId}).first else { return }
        connectRobot(nextRobot)
    }
    
    var readMotorCalibrationCompletion: ((BrickBotMotorCalibration?) ->())?
    
    func readMotorCalibration(completion:(BrickBotMotorCalibration?) ->()) {
        guard let bean = connectedRobot as? PTDBean else {
            completion(nil)
            return
        }
        
        readMotorCalibrationCompletion = completion
        bean.readScratchBank(MotorCalibrationScratchBank)
    }
    
    //    public func fetchReminders(reminderList:HPReminderList, completion:([AnyObject]?) ->()) {
    //    if (self.eventAccessGranted) {
    //    let calendar = self.eventStore.calendarWithIdentifier(reminderList.calendarId)
    //    let predicate = self.eventStore.predicateForIncompleteRemindersWithDueDateStarting(nil, ending: nil, calendars: [calendar])
    //    self.eventStore.fetchRemindersMatchingPredicate(predicate, completion:completion);
    //    }
    //    else {
    //    completion(nil);
    //    }
    //    }
    
    // MARK: Internal
    
    var beanManager: PTDBeanManager?
    var discoveredBeanUUIDs: Set<String> = []
    var timer: NSTimer?
    
    func didConnectRobot(robot: BrickBotRobot) {
        
        discoveredRobots[robot.identifier] = robot
        
        func shouldConnectRobot(robot: BrickBotRobot) -> Bool {
            if (connectedRobot == nil) {
                let lastId = lastConnectedRobotId
                return (lastId == nil) || (lastId == robot.identifier.UUIDString)
            }
            return false
        }
        
        if (shouldConnectRobot(robot)) {
            timer?.invalidate()
            timer = nil
            connectedRobot = robot
            lastConnectedRobotId = robot.identifier.UUIDString
            self.delegate?.didConnectRobot(self, robot: robot)
        }
        else {
            resetTimer()
            disconnectPeriperal(robot)
        }
    }
    
    func didDisconnectRobot(robot: BrickBotRobot) {
        if (connectedRobot?.identifier == robot.identifier) {
            connectedRobot = nil
            self.delegate?.didDisconnectRobot(self, robot: robot)
        }
    }
    
    var LastRobotIdentifierKey: String {
        return "LastRobotIdentifierKey"
    }
    
    var lastConnectedRobotId: String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey(LastRobotIdentifierKey)
        }
        set (newValue) {
            if (newValue != nil) {
                NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: LastRobotIdentifierKey)
            }
        }
    }
    
    func connectPeriperal(robot: BrickBotRobot!) {
        guard let bean = robot as? PTDBean else {
            assertionFailure("Trying to connect a robot that is not a PTDBean")
            return
        }
        
        var error: NSError?
        beanManager?.connectToBean(bean, error: &error)
        if error != nil {
            print("Error connecting to bean: \(error)")
        }
    }
    
    func disconnectPeriperal(robot: BrickBotRobot!) {
        guard let bean = robot as? PTDBean else {
            assertionFailure("Trying to disconnect a robot that is not a PTDBean")
            return
        }
        
        var error: NSError?
        beanManager?.disconnectBean(bean, error: &error)
        if error != nil {
            print("Error disconnecting to bean: \(error)")
        }
    }
    
    func resetTimer() {
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(15, target: self, selector: "timeoutFired", userInfo: nil, repeats: false)
    }
    
    func timeoutFired() {
        timer = nil;
        self.delegate?.didTimeoutDiscovery(self)
    }
    
    
    // MARK: PTDBeanManagerDelegate
    
    func beanManagerDidUpdateState(beanManager: PTDBeanManager!) {
        
        // Update based on manager state
        switch beanManager.state {
        case .Unsupported:
            UIAlertController.showAlert(title: "Error", message: "This device is unsupported.")
        case .PoweredOff:
            UIAlertController.showAlert(title: "Error", message: "Please turn on Bluetooth.")
        case .PoweredOn:
            beanManager.startScanningForBeans_error(nil);
        default:
            break
        }
    }
    
    func beanManager(beanManager: PTDBeanManager!, didDiscoverBean bean: PTDBean!, error: NSError!) {
        print("DISCOVERED BEAN \nName: \(bean.name), UUID: \(bean.identifier) RSSI: \(bean.RSSI)")
        
        guard (discoveredBeanUUIDs.filter({$0 == bean.identifier.UUIDString}).count == 0) ||
        (bean.identifier.UUIDString == lastConnectedRobotId)
            else { return }
        
        // If this is the last discovered bean or it is newly discovered,
        // then connect to it to query it for name and sketch info
        bean.delegate = self
        beanManager.connectToBean(bean, error:nil)
        discoveredBeanUUIDs.insert(bean.identifier.UUIDString)
    }
    
    func beanManager(beanManager: PTDBeanManager!, didConnectBean bean: PTDBean!, error: NSError!) {
        print("CONNECTED BEAN \nName: \(bean.name), UUID: \(bean.identifier) RSSI: \(bean.RSSI)")
        
        if (discoveredRobots[bean.identifier] != nil) {
            // If this is a robot in the list of those already discovered then automatically reconnect
            didConnectRobot(bean)
        }
        else {
            // Query the sketch name and robot name
            bean.readScratchBank(RobotNameScratchBank);
            bean.readArduinoSketchInfo()
        }
    }
    
    func beanManager(beanManager: PTDBeanManager!, didDisconnectBean bean: PTDBean!, error: NSError!) {
        print("DISCONNECTED BEAN \nName: \(bean.name), UUID: \(bean.identifier) RSSI: \(bean.RSSI)")
        didDisconnectRobot(bean)
    }
    
    
    // MARK: PTDBeanDelegate
    
    func bean(bean: PTDBean!, didUpdateSketchName name: String!, dateProgrammed date: NSDate!, crc32 crc: UInt32) {
        if name.hasPrefix("sketch_brickBot") {
            // This is a robot bean, store it's type and add it to the list of known robots
            didConnectRobot(bean)
        }
        else {
            // Otherwise, disconnect
            beanManager?.disconnectBean(bean, error: nil)
        }
    }
    
    func bean(bean: PTDBean!, didUpdateScratchBank bank:Int, data:NSData) {
        
        switch (bank) {
        case RobotNameScratchBank:
            bean.setRobotNameWithData(data)
            
        case MotorCalibrationScratchBank:
            let motorCalibration = BrickBotMotorCalibration(data: data)
            readMotorCalibrationCompletion?(motorCalibration)
            
        default:
            break
        }
    }
    
    func bean(bean: PTDBean!, error: NSError!) {
        print("Bean ERROR: \(error)")
    }
}



extension PTDBean: BrickBotRobot {
    
    // Robot name is stored locally in user defaults
    var robotName: String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey(robotNameKey)
        }
        set (newRobotName) {
            NSUserDefaults.standardUserDefaults().setValue(newRobotName, forKey: robotNameKey)
        }
    }
    private var robotNameKey: String {
        return "\(self.identifier.UUIDString)_RobotNameKey"
    }
    
    var maxRobotNameLength: Int {
        return 10
    }
    
    func setRobotNameWithData(data: NSData?) {
        guard let data = data where data.length > 0 && (data != emptyBank) else { return }
        robotName = String(data:data, encoding:NSUTF16StringEncoding)
    }
    
    func saveRobotName(robotName: String) {
        guard robotName.lengthOfBytesUsingEncoding(NSUTF16StringEncoding) < maxRobotNameLength * 2 else {
            assertionFailure("Robot name is too long")
            return
        }
        self.robotName = robotName
        self.setScratchBank(RobotNameScratchBank, data: robotName.dataUsingEncoding(NSUTF16StringEncoding))
    }
    
    func saveMotorCalibration(calibration: BrickBotMotorCalibration) {
        let bytes = calibration.bytes()
        let data = NSData(bytes:bytes, length:bytes.count)
        self.setScratchBank(MotorCalibrationScratchBank, data: data)
    }
    
}
