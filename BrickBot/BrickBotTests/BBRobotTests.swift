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
    
    // MARK: - func sendBallPosition(ballPosition: CGPoint, remoteOn: Bool)
    
    func testSendBallPosition_Stop_RemoteOff() {
        let robot = BBRobotMock()
        robot.sendBallPosition(CGPointZero, remoteOn: false)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF0, 0x00] as [UInt8], length: 2))
    }
    
    func testSendBallPosition_Stop_RemoteOn() {
        let robot = BBRobotMock()
        robot.sendBallPosition(CGPointZero, remoteOn: true)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF0, 0x15] as [UInt8], length: 2))
    }
    
    func testSendBallPosition_ForwardStraight_RemoteOn() {
        let robot = BBRobotMock()
        robot.sendBallPosition(CGPointMake(0, 1), remoteOn: true)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF0, 0x19] as [UInt8], length: 2))
    }
    
    func testSendBallPosition_ForwardLeft_RemoteOn() {
        let robot = BBRobotMock()
        robot.sendBallPosition(CGPointMake(-1, 1), remoteOn: true)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF0, 0x18] as [UInt8], length: 2))
    }
    
    func testSendBallPosition_ForwardRight_RemoteOn() {
        let robot = BBRobotMock()
        robot.sendBallPosition(CGPointMake(1, 1), remoteOn: true)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF0, 0x1A] as [UInt8], length: 2))
    }
    
    func testSendBallPosition_HardLeft_RemoteOn() {
        let robot = BBRobotMock()
        robot.sendBallPosition(CGPointMake(-1, 0), remoteOn: true)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF0, 0x14] as [UInt8], length: 2))
    }
    
    func testSendBallPosition_HardRight_RemoteOn() {
        let robot = BBRobotMock()
        robot.sendBallPosition(CGPointMake(1, 0), remoteOn: true)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF0, 0x16] as [UInt8], length: 2))
    }
    
    func testSendBallPosition_ReverseStraight_RemoteOn() {
        let robot = BBRobotMock()
        robot.sendBallPosition(CGPointMake(0, -1), remoteOn: true)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF0, 0x11] as [UInt8], length: 2))
    }
    
    func testSendBallPosition_ReverseLeft_RemoteOn() {
        let robot = BBRobotMock()
        robot.sendBallPosition(CGPointMake(-1, -1), remoteOn: true)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF0, 0x10] as [UInt8], length: 2))
    }
    
    func testSendBallPosition_ReverseRight_RemoteOn() {
        let robot = BBRobotMock()
        robot.sendBallPosition(CGPointMake(1, -1), remoteOn: true)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF0, 0x12] as [UInt8], length: 2))
    }
    
    func testSendBallPosition_ForwardStraight_Threshold_Pass() {
        let robot = BBRobotMock()
        robot.sendBallPosition(CGPointMake(0, 0.31), remoteOn: true)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF0, 0x19] as [UInt8], length: 2))
    }
    
    func testSendBallPosition_HardLeft_Threshold_Pass() {
        let robot = BBRobotMock()
        robot.sendBallPosition(CGPointMake(-0.31, 0), remoteOn: true)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF0, 0x14] as [UInt8], length: 2))
    }
    
    func testSendBallPosition_HardRight_Threshold_Pass() {
        let robot = BBRobotMock()
        robot.sendBallPosition(CGPointMake(0.31, 0), remoteOn: true)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF0, 0x16] as [UInt8], length: 2))
    }
    
    func testSendBallPosition_ReverseStraight_Threshold_Pass() {
        let robot = BBRobotMock()
        robot.sendBallPosition(CGPointMake(0, -0.31), remoteOn: true)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF0, 0x11] as [UInt8], length: 2))
    }
    
    func testSendBallPosition_ForwardStraight_Threshold_Fail() {
        let robot = BBRobotMock()
        robot.sendBallPosition(CGPointMake(0, 0.29), remoteOn: true)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF0, 0x15] as [UInt8], length: 2))
    }
    
    func testSendBallPosition_HardLeft_Threshold_Fail() {
        let robot = BBRobotMock()
        robot.sendBallPosition(CGPointMake(-0.29, 0), remoteOn: true)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF0, 0x15] as [UInt8], length: 2))
    }
    
    func testSendBallPosition_HardRight_Threshold_Fail() {
        let robot = BBRobotMock()
        robot.sendBallPosition(CGPointMake(0.29, 0), remoteOn: true)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF0, 0x15] as [UInt8], length: 2))
    }
    
    func testSendBallPosition_ReverseStraight_Threshold_Fail() {
        let robot = BBRobotMock()
        robot.sendBallPosition(CGPointMake(0, -0.29), remoteOn: true)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF0, 0x15] as [UInt8], length: 2))
    }
    
    // MARK: - func sendAutopilotOn(autopilotOn: Bool)
    
    func testSendAutopilot_On() {
        let robot = BBRobotMock()
        robot.sendAutopilotOn(true)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF1, 0x01] as [UInt8], length: 2))
    }
    
    func testSendAutopilot_Off() {
        let robot = BBRobotMock()
        robot.sendAutopilotOn(false)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF1, 0x00] as [UInt8], length: 2))
    }
    
    // MARK: - func sendResetCalibration() 
    
    func testSendResetCalibration() {
        let robot = BBRobotMock()
        robot.sendResetCalibration()
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF3] as [UInt8], length: 1))
    }
    
    // MARK: - func sendMotorCalibration(calibration: BrickBotMotorCalibration) 
    
    func testSendMotorCalibration() {
        let robot = BBRobotMock()
        let motorCalibration = BBMotorCalibration(data: NSData(bytes: [20, 146, 162] as [UInt8], length: 3))
        robot.sendMotorCalibration(motorCalibration)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF2, 20, 146, 162] as [UInt8], length: 4))
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
