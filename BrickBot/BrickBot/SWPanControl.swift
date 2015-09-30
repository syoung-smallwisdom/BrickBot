//
//  SWPanControl.swift
//
//  Created by Shannon Young on 9/21/15.
//  Copyright © 2015 Smallwisdom. All rights reserved.
//


import UIKit

//iPhone 6s Plus    Screen: (0.0, 0.0, 414.0, 736.0)
//iPhone 6          Screen: (0.0, 0.0, 375.0, 667.0)
//iPhone 5          Screen: (0.0, 0.0, 320.0, 568.0)

class SWPanControl: UIControl {
    
    var position: CGPoint  {
        get {
            return _position;
        }
        set (newPosition) {
            _position = CGPointMake(
                max(-1, min(1, newPosition.x)),
                max(-1, min(1, newPosition.y)))
        }
    }
    private var _position = CGPointZero
    
    var thumb:CGFloat = 100.0
    var threshold:CGFloat = 20.0
    
    func updatePosition(dx dx: CGFloat, dy: CGFloat) {
        position = CGPoint(
            x:min(1.0, max(-1.0, position.x + dx)),
            y:min(1.0, max(-1.0, position.y + dy)))
        self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
    }

    // MARK: Touch monitoring
    
    private var startPoint: CGPoint?
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let ret = super.beginTrackingWithTouch(touch, withEvent: event)
        startPoint = touch.locationInView(self)
        return ret
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        super.continueTrackingWithTouch(touch, withEvent: event)
        
        // Get the current position
        let currentPoint = touch.locationInView(self)

        let diff = CGPoint(x: currentPoint.x - startPoint!.x, y: -1*(currentPoint.y - startPoint!.y))
        
        // If pan movement is above the threashold then update the position
        if (abs(diff.x) > threshold || abs(diff.y) > threshold) {
            startPoint = currentPoint
            updatePosition(
                dx: min(1, max(-1, diff.x/thumb)),
                dy: min(1, max(-1, diff.y/thumb)))
        }

        return true
    }

}
