//
//  BrickBotRobotPosition.swift
//  BrickBot
//
//  Created by Shannon Young on 10/5/15.
//  Copyright © 2015 Smallwisdom. All rights reserved.
//

import UIKit

public enum BBSteer: UInt8 {
    case Left = 0, Center = 1, Right = 2
}

public enum BBDirection: UInt8 {
    case Reverse = 0, Stop = 1, Forward = 2
}

public struct BBRobotPosition: Equatable, Hashable {
    
    public var steer: BBSteer = .Center
    public var dir: BBDirection = .Stop
    
    public init(ballPosition: CGPoint) {
        let threshold = CGFloat(0.3)
        func roundPosition(pos: CGFloat) -> UInt8 {
            return (pos < -1 * threshold) ? 0 : (pos > threshold) ? 2 : 1
        }
        self.steer = BBSteer(rawValue: roundPosition(ballPosition.x)) ?? .Center
        self.dir = BBDirection(rawValue: roundPosition(ballPosition.y)) ?? .Stop
    }
    
    public init(steer: BBSteer, dir: BBDirection) {
        self.steer = steer
        self.dir = dir
    }
    
    public var hashValue: Int {
        return Int(rawValue)
    }
    
    var rawValue: UInt8 {
        return steer.rawValue | dir.rawValue << 2 | 1 << 4
    }
}

public func == (lhs: BBRobotPosition, rhs: BBRobotPosition) -> Bool {
    return lhs.steer == rhs.steer && lhs.dir == rhs.dir
}
