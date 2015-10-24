//
//  BeanRobotManager.swift
//  BrickBot
//
//  Created by Shannon Young on 9/21/15.
//  Copyright © 2015 Smallwisdom. All rights reserved.
//

import UIKit



final class BeanRobotManager: NSObject, BBRobotManager, PTDBeanManagerDelegate, PTDBeanDelegate {
    
    // MARK: RobotManager
    
    weak var delegate: BBRobotManagerDelegate?
    
    var connectedRobot: BBRobot?
    
    var discoveredRobots: [NSUUID: BBRobot] = [:]
    
    var messageCache: [BBControlFlag: BBRobotMessagePacket] = [:]
    
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
    
    func connectRobot(robot: BBRobot) {
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
    
    var readMotorCalibrationCompletion: ((BBMotorCalibration?) ->())?
    
    func readMotorCalibration(completion:(BBMotorCalibration?) ->()) {
        guard let bean = connectedRobot as? PTDBean else {
            completion(nil)
            return
        }
        
        readMotorCalibrationCompletion = completion
        bean.readScratchBank(BBScratchBank.MotorCalibration.rawValue)
    }

    
    // MARK: Internal
    
    var beanManager: PTDBeanManager?
    var discoveredBeanUUIDs: Set<String> = []
    var timer: NSTimer?
    
    func didConnectRobot(robot: BBRobot) {
        
        discoveredRobots[robot.identifier] = robot
        
        func shouldConnectRobot(robot: BBRobot) -> Bool {
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
            
            // Query the name of the robot and the motor calibration
            let bean = robot as! PTDBean
            bean.readScratchBank(BBScratchBank.MotorCalibration.rawValue);
        }
        else {
            resetTimer()
            disconnectPeriperal(robot)
        }
    }
    
    func didDisconnectRobot(robot: BBRobot) {
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
    
    func connectPeriperal(robot: BBRobot!) {
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
    
    func disconnectPeriperal(robot: BBRobot!) {
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
    
    // For now, just hardcode the SketchId for a BrickBot robot.
    let BrickBotSketchIdPrefix = "BrickBot_"
    func didReadSketchId(bean: PTDBean!, data: NSData) {
        
        // Check the data in the first scratch bank. If the data is not empty and the 
        // sketchId starts with the sketch ID we are looking for then connect.
        if let name = convertScratchDataToString(data, encoding: NSUTF8StringEncoding) where name.hasPrefix(BrickBotSketchIdPrefix) {
            // This is a robot bean, store it's type and add it to the list of known robots
            didConnectRobot(bean)
        }
        else {
            // Otherwise, disconnect
            beanManager?.disconnectBean(bean, error: nil)
        }
    }
    
    func didReadMotorCalibrationData(bean: PTDBean!, data:NSData) {
        if (data.length >= BBMotorCalibrationState.Count.rawValue) {
            bean.motorCalibrationData = data;
        }
        else if let data = bean.motorCalibrationData {
            // set the scratch bank and then reset the calibration to update
            bean.setScratchBank(BBScratchBank.MotorCalibration.rawValue, data: data)
            self.sendResetCalibration()
        }
    }
    
    func convertScratchDataToString(data: NSData, encoding: NSStringEncoding) -> String? {
        
        guard (data.length > 0) else { return nil }
        
        // C++ Arduino string is zero padded so strip that char if necessary
        var bytes = [UInt8](count: data.length, repeatedValue: 0)
        data.getBytes(&bytes, length:data.length)
        
        var range = NSMakeRange(0, data.length);
        if (bytes.count > 2 && bytes[bytes.count - 1] == 0x00) {
            range.length -= 1;
        }
        
        let str = String(data: data.subdataWithRange(range), encoding: encoding)
        return str
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
            bean.readArduinoSketchInfo()
            bean.readScratchBank(BBScratchBank.SketchId.rawValue);
        }
    }
    
    func beanManager(beanManager: PTDBeanManager!, didDisconnectBean bean: PTDBean!, error: NSError!) {
        print("DISCONNECTED BEAN \nName: \(bean.name), UUID: \(bean.identifier) RSSI: \(bean.RSSI)")
        didDisconnectRobot(bean)
    }
    
    
    // MARK: PTDBeanDelegate
    
    func bean(bean: PTDBean!, didUpdateSketchName name: String!, dateProgrammed date: NSDate!, crc32 crc: UInt32) {
        print("\ndidUpdateSketchName name:\(name)")
    }
    
    func bean(bean: PTDBean!, didUpdateScratchBank bank:Int, data:NSData) {
        // Check that this is a scratch bank that is reserved, otherwise ignore
        guard let scratchBank = BBScratchBank(rawValue: bank) else { return }

        switch (scratchBank) {
        case .SketchId:
            didReadSketchId(bean, data: data)
            
        case .MotorCalibration:
            didReadMotorCalibrationData(bean, data: data)
            let motorCalibration = BBMotorCalibration(data: bean.motorCalibrationData)
            readMotorCalibrationCompletion?(motorCalibration)
        }
    }
    
    func bean(bean: PTDBean!, error: NSError!) {
        print("Bean ERROR: \(error)")
    }
    
    func bean(bean: PTDBean!, serialDataReceived data: NSData!) {
        didReceiveMessageResponse(bean, data: data)
    }
}

extension PTDBean: BBRobot {
    
    // Motor calibration is stored locally in user defaults. The Bean doesn't save
    // scratch bank data across power resets so this information is saved to the iOS device as a backup.
    
    public var motorCalibrationData: NSData?  {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey(motorCalibrationKey) as? NSData
        }
        set (newValue) {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: motorCalibrationKey)
        }
    }
    private var motorCalibrationKey: String {
        return "\(self.identifier.UUIDString)_MotorCalibrationKey"
    }

}
