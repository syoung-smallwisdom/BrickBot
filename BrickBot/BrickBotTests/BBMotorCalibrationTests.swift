//
//  BBMotorCalibrationTests.swift
//  BrickBot
//
//  Created by Shannon Young on 10/7/15.
//  Copyright © 2015 Smallwisdom. All rights reserved.
//

import XCTest

class BBMotorCalibrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBytesFromMotorCalibration() {
        let motorCalibration = BBMotorCalibration(calibration: [-0.88, 0.7, 0.9])
        let expectedBytes:[UInt8] = [24 ,143, 158]
        XCTAssertEqual(motorCalibration.bytes(), expectedBytes)
    }
    
    func testMotorCalibrationFromData() {
        let data = NSData(bytes: [24 ,143, 158] as [UInt8], length: 3)
        let motorCalibration = BBMotorCalibration(data: data)
        let expectedCalibration = [-0.88, 0.71, 0.91]
        XCTAssertEqual(motorCalibration.calibrationStates, expectedCalibration)
    }
    
    func testSetCalibration_ForwardRight() {
        // Check that when the forward direction is updated, that the "right" direct is less than forward
        var motorCalibration = BBMotorCalibration()
        // check assumptions
        XCTAssertEqualWithAccuracy(motorCalibration.calibrationStates[BBMotorCalibrationState.ForwardStraight.rawValue], 0, accuracy: 0.001)
        XCTAssertEqualWithAccuracy(motorCalibration.calibrationStates[BBMotorCalibrationState.ForwardRight.rawValue], 0.6, accuracy: 0.001)
        
        motorCalibration.setCalibration(BBMotorCalibrationState.ForwardStraight.rawValue, value: 0.68);
        
        // Setting the straight value to more than the right value should automatically update the right value
        let expectedBytes:[UInt8] = [45, 141, 161]
        XCTAssertEqual(motorCalibration.bytes(), expectedBytes)
    }
    
    func testSetCalibration_ForwardLeft() {
        // Check that when the forward direction is updated, that the "right" direct is less than forward
        var motorCalibration = BBMotorCalibration()
        // check assumptions
        XCTAssertEqualWithAccuracy(motorCalibration.calibrationStates[BBMotorCalibrationState.ForwardStraight.rawValue], 0, accuracy: 0.001)
        XCTAssertEqualWithAccuracy(motorCalibration.calibrationStates[BBMotorCalibrationState.ForwardLeft.rawValue], -0.6, accuracy: 0.001)
        
        motorCalibration.setCalibration(BBMotorCalibrationState.ForwardStraight.rawValue, value: -0.68);
        
        // Setting the straight value to less than the left value should automatically update the right value
        let expectedBytes:[UInt8] = [19, 39, 135]
        XCTAssertEqual(motorCalibration.bytes(), expectedBytes)
    }
    
}
