//
//  BeanRobotManagerTests.swift
//  BrickBot
//
//  Created by Shannon Young on 10/9/15.
//  Copyright © 2015 Smallwisdom. All rights reserved.
//

import XCTest

class BeanRobotManagerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }


    // MARK: - func convertScratchDataToString(data: NSData, encoding: NSStringEncoding)
    
    func testConvertSketchIdToString_ValidSketchIDName() {
        // Scratch Bank
        let bytes:[UInt8] = [0x42, 0x72, 0x69, 0x63, 0x6b, 0x42, 0x6f, 0x74, 0x5f, 0x31, 0x2e, 0x30, 0x2e, 0x30, 0x00];
        let data = NSData(bytes: bytes, length: bytes.count);
        let sketchName = BeanHelper.convertScratchDataToString(data, encoding:NSUTF8StringEncoding);
        XCTAssertNotNil(sketchName);
        XCTAssertEqual(sketchName, "BrickBot_1.0.0");
    }
    
    func testConvertSketchIdToString_ValidRobotName() {
        // Scratch Bank
        let bytes:[UInt8] = [0x4c, 0x69, 0x64, 0x64, 0x79, 0x20, 0x42, 0x6f, 0x6f];
        let data = NSData(bytes: bytes, length: bytes.count);
        let sketchName = BeanHelper.convertScratchDataToString(data, encoding:NSUTF8StringEncoding);
        XCTAssertNotNil(sketchName);
        XCTAssertEqual(sketchName, "Liddy Boo");
    }
    

}
