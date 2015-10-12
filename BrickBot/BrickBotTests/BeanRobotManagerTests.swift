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
        let robotManager = BeanRobotManager()
        let bytes:[UInt8] = [0x42, 0x72, 0x69, 0x63, 0x6b, 0x42, 0x6f, 0x74, 0x5f, 0x31, 0x2e, 0x30, 0x2e, 0x30, 0x00];
        let data = NSData(bytes: bytes, length: bytes.count);
        let sketchName = robotManager.convertScratchDataToString(data, encoding:NSUTF8StringEncoding);
        XCTAssertNotNil(sketchName);
        XCTAssertEqual(sketchName, "BrickBot_1.0.0");
    }
    
    func testConvertSketchIdToString_ValidRobotName() {
        // Scratch Bank
        let robotManager = BeanRobotManager()
        let bytes:[UInt8] = [0x4c, 0x69, 0x64, 0x64, 0x79, 0x20, 0x42, 0x6f, 0x6f];
        let data = NSData(bytes: bytes, length: bytes.count);
        let sketchName = robotManager.convertScratchDataToString(data, encoding:NSUTF8StringEncoding);
        XCTAssertNotNil(sketchName);
        XCTAssertEqual(sketchName, "Liddy Boo");
    }
    
//    sendMessage: <f22084aa>
//    sendMessage: <f22086aa>
//    sendMessage: <f22087aa>
//    sendMessage: <f22089aa>
//    sendMessage: <f2208aaa>
//    sendMessage: <f2208caa>
//    sendMessage: <f2208daa>
//    sendMessage: <f2208faa>
//    sendMessage: <f22090aa>
//    sendMessage: <f22091aa>
//    sendMessage: <f22092aa>
//    sendMessage: <f22094aa>
//    sendMessage: <f22095aa>
//    sendMessage: <f22097aa>
//    sendMessage: <f22098aa>
//    sendMessage: <f2209aaa>
//    sendMessage: <f2209daa>
//
//    didReceiveMessageResponse: <f22093aa>
//    didReceiveMessageResponse: <f22092aa f22091aa f2208faa>
//    didReceiveMessageResponse: <f2208eaa f2208caa>
//    didReceiveMessageResponse: <f2208baa f2208aaa f22089aa>
//    didReceiveMessageResponse: <f22088aa f22086aa>
//    didReceiveMessageResponse: <f22083aa f22081aa f22080aa>
//    didReceiveMessageResponse: <f2207faa f2207eaa f2207faa>
//    didReceiveMessageResponse: <f22080aa f22081aa>
//    didReceiveMessageResponse: <f22083aa f22084aa f22086aa>
//    didReceiveMessageResponse: <f22087aa f22089aa>
//    didReceiveMessageResponse: <f2208aaa f2208caa>
//    didReceiveMessageResponse: <f2208daa f2208faa f22090aa>
//    didReceiveMessageResponse: <f22091aa f22092aa>
//    didReceiveMessageResponse: <f22094aa f22095aa f22097aa>
//    didReceiveMessageResponse: <f22098aa f2209aaa>
//    didReceiveMessageResponse: <f2209daa>
    

}
