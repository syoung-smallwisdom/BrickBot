//
//  BrickBotRobotTests.swift
//  BrickBot
//
//  Created by Shannon Young on 10/5/15.
//  Copyright © 2015 Smallwisdom. All rights reserved.
//

import XCTest

class BBRobotTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: - func saveRobotName(robotName: String)
    
    func testSaveRobotName() {
        let robot = BBRobotMock()
        let name = "Peter"
        robot.saveRobotName(name)
        
        // Name should be set
        XCTAssertEqual(robot.robotName, name)
        
        // scratch bank should be set
        let data = robot.scratchBankData[BBScratchBank.RobotName.rawValue]
        XCTAssertEqual(data, name.dataUsingEncoding(BBNameStringEncoding))
    }
    
    // MARK: - var setRobotName
    
    func testSetRobotName() {
        let robot = BBRobotMock()
        let name = "Peter"
        
        robot.robotName = name;
        
        // Name should be set
        XCTAssertEqual(robot.robotName, name)
        
        // scratch bank should NOT be set
        XCTAssertNil(robot.scratchBankData[BBScratchBank.RobotName.rawValue])
    }

    // MARK: - func saveMotorCalibration(calibration: BrickBotMotorCalibration) 
    
    func testSaveMotorCalibration() {
        let robot = BBRobotMock()
        let motorCalibration = BBMotorCalibration(data: NSData(bytes: [20, 146, 162] as [UInt8], length: 3))
        robot.saveMotorCalibration(motorCalibration)
        
        // serial data should *not* be set
        XCTAssertNil(robot.serialData)
        
        // scratch bank should be set and should *not* include the control flag
        let data = robot.scratchBankData[BBScratchBank.MotorCalibration.rawValue]
        XCTAssertEqual(data, NSData(bytes: [20, 146, 162] as [UInt8], length: 3))
        
        let outputCalibration = BBMotorCalibration(data: data)
        XCTAssertEqual(outputCalibration, motorCalibration)
    }
    


    
}

class BBRobotMock: NSObject, BBRobot {
    
    var identifier: NSUUID! = NSUUID()
    var connected: Bool = false
    var robotName: String?
    var motorCalibrationData: NSData?
    var maxRobotNameLength: Int = 10
    
    var serialData: NSData?
    var scratchBankData: [Int: NSData] = [:]
    
    func sendSerialData(data: NSData!) {
        print("\nsendSerialData \(data)", terminator: "");
        serialData = data
    }

    func setScratchBank(bank: Int, data: NSData!) {
        scratchBankData[bank] = data
    }
    
}
