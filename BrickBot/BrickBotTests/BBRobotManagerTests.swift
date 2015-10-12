//
//  BBRobotManagerTests.swift
//  BrickBot
//
//  Created by Shannon Young on 10/12/15.
//  Copyright © 2015 Smallwisdom. All rights reserved.
//

import XCTest

class BBRobotManagerTests: XCTestCase {

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
        let robotManager = BBRobotManagerMock()
        let robot = robotManager.connectedRobot as! BBRobotMock
        robotManager.sendBallPosition(CGPointZero, remoteOn: false)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF0, 0x00] as [UInt8], length: 2))
    }
    
    func testSendBallPosition_Stop_RemoteOn() {
        let robotManager = BBRobotManagerMock()
        let robot = robotManager.connectedRobot as! BBRobotMock
        robotManager.sendBallPosition(CGPointZero, remoteOn: true)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF0, 0x15] as [UInt8], length: 2))
    }
    
    func testSendBallPosition_ForwardStraight_RemoteOn() {
        let robotManager = BBRobotManagerMock()
        let robot = robotManager.connectedRobot as! BBRobotMock
        robotManager.sendBallPosition(CGPointMake(0, 1), remoteOn: true)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF0, 0x19] as [UInt8], length: 2))
    }
    
    func testSendBallPosition_ForwardLeft_RemoteOn() {
        let robotManager = BBRobotManagerMock()
        let robot = robotManager.connectedRobot as! BBRobotMock
        robotManager.sendBallPosition(CGPointMake(-1, 1), remoteOn: true)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF0, 0x18] as [UInt8], length: 2))
    }
    
    func testSendBallPosition_ForwardRight_RemoteOn() {
        let robotManager = BBRobotManagerMock()
        let robot = robotManager.connectedRobot as! BBRobotMock
        robotManager.sendBallPosition(CGPointMake(1, 1), remoteOn: true)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF0, 0x1A] as [UInt8], length: 2))
    }
    
    func testSendBallPosition_HardLeft_RemoteOn() {
        let robotManager = BBRobotManagerMock()
        let robot = robotManager.connectedRobot as! BBRobotMock
        robotManager.sendBallPosition(CGPointMake(-1, 0), remoteOn: true)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF0, 0x14] as [UInt8], length: 2))
    }
    
    func testSendBallPosition_HardRight_RemoteOn() {
        let robotManager = BBRobotManagerMock()
        let robot = robotManager.connectedRobot as! BBRobotMock
        robotManager.sendBallPosition(CGPointMake(1, 0), remoteOn: true)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF0, 0x16] as [UInt8], length: 2))
    }
    
    func testSendBallPosition_ReverseStraight_RemoteOn() {
        let robotManager = BBRobotManagerMock()
        let robot = robotManager.connectedRobot as! BBRobotMock
        robotManager.sendBallPosition(CGPointMake(0, -1), remoteOn: true)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF0, 0x11] as [UInt8], length: 2))
    }
    
    func testSendBallPosition_ReverseLeft_RemoteOn() {
        let robotManager = BBRobotManagerMock()
        let robot = robotManager.connectedRobot as! BBRobotMock
        robotManager.sendBallPosition(CGPointMake(-1, -1), remoteOn: true)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF0, 0x10] as [UInt8], length: 2))
    }
    
    func testSendBallPosition_ReverseRight_RemoteOn() {
        let robotManager = BBRobotManagerMock()
        let robot = robotManager.connectedRobot as! BBRobotMock
        robotManager.sendBallPosition(CGPointMake(1, -1), remoteOn: true)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF0, 0x12] as [UInt8], length: 2))
    }
    
    func testSendBallPosition_ForwardStraight_Threshold_Pass() {
        let robotManager = BBRobotManagerMock()
        let robot = robotManager.connectedRobot as! BBRobotMock
        robotManager.sendBallPosition(CGPointMake(0, 0.31), remoteOn: true)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF0, 0x19] as [UInt8], length: 2))
    }
    
    func testSendBallPosition_HardLeft_Threshold_Pass() {
        let robotManager = BBRobotManagerMock()
        let robot = robotManager.connectedRobot as! BBRobotMock
        robotManager.sendBallPosition(CGPointMake(-0.31, 0), remoteOn: true)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF0, 0x14] as [UInt8], length: 2))
    }
    
    func testSendBallPosition_HardRight_Threshold_Pass() {
        let robotManager = BBRobotManagerMock()
        let robot = robotManager.connectedRobot as! BBRobotMock
        robotManager.sendBallPosition(CGPointMake(0.31, 0), remoteOn: true)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF0, 0x16] as [UInt8], length: 2))
    }
    
    func testSendBallPosition_ReverseStraight_Threshold_Pass() {
        let robotManager = BBRobotManagerMock()
        let robot = robotManager.connectedRobot as! BBRobotMock
        robotManager.sendBallPosition(CGPointMake(0, -0.31), remoteOn: true)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF0, 0x11] as [UInt8], length: 2))
    }
    
    func testSendBallPosition_ForwardStraight_Threshold_Fail() {
        let robotManager = BBRobotManagerMock()
        let robot = robotManager.connectedRobot as! BBRobotMock
        robotManager.sendBallPosition(CGPointMake(0, 0.29), remoteOn: true)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF0, 0x15] as [UInt8], length: 2))
    }
    
    func testSendBallPosition_HardLeft_Threshold_Fail() {
        let robotManager = BBRobotManagerMock()
        let robot = robotManager.connectedRobot as! BBRobotMock
        robotManager.sendBallPosition(CGPointMake(-0.29, 0), remoteOn: true)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF0, 0x15] as [UInt8], length: 2))
    }
    
    func testSendBallPosition_HardRight_Threshold_Fail() {
        let robotManager = BBRobotManagerMock()
        let robot = robotManager.connectedRobot as! BBRobotMock
        robotManager.sendBallPosition(CGPointMake(0.29, 0), remoteOn: true)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF0, 0x15] as [UInt8], length: 2))
    }
    
    func testSendBallPosition_ReverseStraight_Threshold_Fail() {
        let robotManager = BBRobotManagerMock()
        let robot = robotManager.connectedRobot as! BBRobotMock
        robotManager.sendBallPosition(CGPointMake(0, -0.29), remoteOn: true)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF0, 0x15] as [UInt8], length: 2))
    }
    
    // MARK: - func sendAutopilotOn(autopilotOn: Bool)
    
    func testSendAutopilot_On() {
        let robotManager = BBRobotManagerMock()
        let robot = robotManager.connectedRobot as! BBRobotMock
        robotManager.sendAutopilotOn(true)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF1, 0x01] as [UInt8], length: 2))
    }
    
    func testSendAutopilot_Off() {
        let robotManager = BBRobotManagerMock()
        let robot = robotManager.connectedRobot as! BBRobotMock
        robotManager.sendAutopilotOn(false)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF1, 0x00] as [UInt8], length: 2))
    }
    
    // MARK: - func sendResetCalibration()
    
    func testSendResetCalibration() {
        let robotManager = BBRobotManagerMock()
        let robot = robotManager.connectedRobot as! BBRobotMock
        robotManager.sendResetCalibration()
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF3] as [UInt8], length: 1))
    }
    
    // MARK: - func sendMotorCalibration(calibration: BrickBotMotorCalibration)
    
    func testSendMotorCalibration() {
        let motorCalibration = BBMotorCalibration(data: NSData(bytes: [20, 146, 162] as [UInt8], length: 3))
        let robotManager = BBRobotManagerMock()
        let robot = robotManager.connectedRobot as! BBRobotMock
        robotManager.sendMotorCalibration(motorCalibration)
        XCTAssertEqual(robot.serialData, NSData(bytes: [0xF2, 20, 146, 162] as [UInt8], length: 4))
    }
    
    // MARK: - func didReceiveMessageResponse(robot: BBRobot, data: NSData)
    
    func testDidReceiveMessageResponse_SingleSendResponse() {
        
        let robotManager = BBRobotManagerMock()
        robotManager.sendMotorCalibration(BBMotorCalibration(data: NSData(bytes: [20, 146, 162] as [UInt8], length: 3)))
        
        // Check that the msgPacket cached for this is the LAST message
        XCTAssertNotNil(robotManager.messageCache[.MotorCalibration])
        if let msgPacket = robotManager.messageCache[.MotorCalibration] {
            XCTAssertEqual(msgPacket.data, NSData(bytes: [0xF2, 20, 146, 162] as [UInt8], length: 4))
            XCTAssertFalse(msgPacket.received)
        }
        
        // Now send the response to all three messages concatonated
        let responseData = NSData(bytes: [0xF2, 20, 146, 162] as [UInt8], length: 4)
        robotManager.didReceiveMessageResponse(robotManager.connectedRobot!, data: responseData)
        
        // Check the cache after the didReceive
        XCTAssertNotNil(robotManager.messageCache[.MotorCalibration])
        if let msgPacket = robotManager.messageCache[.MotorCalibration] {
            XCTAssertEqual(msgPacket.data, NSData(bytes: [0xF2, 20, 146, 162] as [UInt8], length: 4))
            XCTAssertTrue(msgPacket.received)
        }
        
    }
    
    func testDidReceiveMessageResponse_MultipleSendResponse() {
        
        let robotManager = BBRobotManagerMock()
        robotManager.sendMotorCalibration(BBMotorCalibration(data: NSData(bytes: [20, 146, 160] as [UInt8], length: 3)))
        robotManager.sendMotorCalibration(BBMotorCalibration(data: NSData(bytes: [20, 146, 161] as [UInt8], length: 3)))
        robotManager.sendMotorCalibration(BBMotorCalibration(data: NSData(bytes: [20, 146, 162] as [UInt8], length: 3)))
        
        // Check that the msgPacket cached for this is the LAST message
        XCTAssertNotNil(robotManager.messageCache[.MotorCalibration])
        if let msgPacket = robotManager.messageCache[.MotorCalibration] {
            XCTAssertEqual(msgPacket.data, NSData(bytes: [0xF2, 20, 146, 162] as [UInt8], length: 4))
            XCTAssertFalse(msgPacket.received)
        }
        
        // Now send the response to all three messages concatonated
        let responseData = NSData(bytes: [0xF2, 20, 146, 160, 0xF2, 20, 146, 161, 0xF2, 20, 146, 162] as [UInt8], length: 4*3)
        robotManager.didReceiveMessageResponse(robotManager.connectedRobot!, data: responseData)
        
        // Check the cache after the didReceive
        XCTAssertNotNil(robotManager.messageCache[.MotorCalibration])
        if let msgPacket = robotManager.messageCache[.MotorCalibration] {
            XCTAssertEqual(msgPacket.data, NSData(bytes: [0xF2, 20, 146, 162] as [UInt8], length: 4))
            XCTAssertTrue(msgPacket.received)
        }
        
    }

}

class BBRobotManagerMock: NSObject, BBRobotManager {
    
    var delegate: BBRobotManagerDelegate?
    var connectedRobot: BBRobot? = BBRobotMock()
    var discoveredRobots: [NSUUID: BBRobot] = [:]
    var messageCache: [BBControlFlag: BBRobotMessagePacket] = [:]
    
    // MARK: Not Implemented
    
    func connect() {
        assertionFailure("Not Implemented")
    }
    
    func disconnect() {
        assertionFailure("Not Implemented")
    }
    
    func connectRobot(robot: BBRobot) {
        assertionFailure("Not Implemented")
    }
    
    func connectNextAvailableRobot() {
        assertionFailure("Not Implemented")
    }
    
    func readMotorCalibration(completion:(BBMotorCalibration?) ->()) {
        assertionFailure("Not Implemented")
    }
    
}
