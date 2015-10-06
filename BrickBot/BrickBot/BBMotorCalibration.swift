//
//  BrickBotMotorCalibration.swift
//  BrickBot
//
//  Created by Shannon Young on 10/5/15.
//  Copyright © 2015 Smallwisdom. All rights reserved.
//

import UIKit

let BBMotorCalibrationCenter: CGFloat = 90;
let BBMotorCalibrationMaxOffset: CGFloat = 75;

public enum BBMotorCalibrationState: Int {
    case ForwardLeft = 0, ForwardStraight = 1, ForwardRight = 2, Count
}

public struct BBMotorCalibration: Equatable {
    
    public var calibrationStates:[CGFloat] = [-0.5*BBMotorCalibrationCenter/BBMotorCalibrationMaxOffset, 0, 0.5*BBMotorCalibrationCenter/BBMotorCalibrationMaxOffset];
    
    public init() {
        // default value already set
    }
    
    public init(calibration:[CGFloat]) {
        calibrationStates = calibration
    }
    
    public init(data: NSData?) {
        // Check that the data is valid
        if let data = data where (data.length != BBEmptyBank) { // bank returns a zero if not set
            let bytes = Array(UnsafeBufferPointer(start: UnsafePointer<UInt8>(data.bytes), count: data.length))
            for (var ii=0; ii < calibrationStates.count && ii < bytes.count; ii++) {
                calibrationStates[ii] = round(((CGFloat(bytes[ii]) - BBMotorCalibrationCenter)/BBMotorCalibrationMaxOffset) * 100)/100
            }
        }
    }
    
    func bytes() -> [UInt8] {
        var bytes: [UInt8] = []
        for calibration in calibrationStates {
            bytes += [UInt8(round(calibration * BBMotorCalibrationMaxOffset) + BBMotorCalibrationCenter)]
        }
        return bytes
    }
    
    mutating func setCalibration(idx: Int, value: CGFloat) {
        guard let state = BBMotorCalibrationState(rawValue: idx) else { return; }
        calibrationStates[idx] = value
        if (state == .ForwardStraight) {
            let rightIdx = BBMotorCalibrationState.ForwardRight.rawValue
            let leftIdx = BBMotorCalibrationState.ForwardLeft.rawValue
            if (calibrationStates[rightIdx] <= value) {
                let rightVal = (BBMotorCalibrationCenter + value * BBMotorCalibrationMaxOffset) / (2 * BBMotorCalibrationMaxOffset)
                calibrationStates[rightIdx] = round(rightVal * 100.0)/100
            }
            else if (calibrationStates[leftIdx] >= value) {
                let leftVal = (value * BBMotorCalibrationMaxOffset - BBMotorCalibrationCenter) / (2 * BBMotorCalibrationMaxOffset)
                calibrationStates[leftIdx] = round(leftVal * 100.0)/100
            }
        }
    }
}

public func == (lhs: BBMotorCalibration, rhs: BBMotorCalibration) -> Bool {
    return lhs.calibrationStates == rhs.calibrationStates
}
