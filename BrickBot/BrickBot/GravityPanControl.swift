//
//  GravityPanControl.swift
//  BrickBot
//
//  Created by Shannon Young on 9/21/15.
//  Copyright © 2015 Smallwisdom. All rights reserved.
//

/**
 * This is intended as a control used to listen to both finger panning and tilt to
 * control position.
 */

import UIKit
import CoreMotion

//iPhone 6s Plus    Screen: (0.0, 0.0, 414.0, 736.0)
//iPhone 6          Screen: (0.0, 0.0, 375.0, 667.0)
//iPhone 5          Screen: (0.0, 0.0, 320.0, 568.0)

class GravityPanControl: UIControl {
    
    var position: CGPoint = CGPointZero
    
    private func updatePosition(dx dx: CGFloat, dy: CGFloat) {
        position.x = min(1, max(-1, position.x + dx))
        position.y = min(1, max(-1, position.y + dy))
        self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
    }
    
    
    // MARK: Touch monitoring
    private var startPoint: CGPoint?
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        super.beginTrackingWithTouch(touch, withEvent: event)
        position = CGPointZero
        startPoint = touch.locationInView(self)
        self.startMonitoringPosition()
        self.sendActionsForControlEvents(UIControlEvents.TouchDown)
        return true
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        super.continueTrackingWithTouch(touch, withEvent: event)
        
        // Get the current position
        let currentPoint = touch.locationInView(self)
        let thumb:CGFloat = 100.0
        let threashold:CGFloat = 20.0
        let diff = CGPoint(x: currentPoint.x - startPoint!.x, y: -1*(currentPoint.y - startPoint!.y))
        
        // If pan movement is above the threashold then update the position
        if (abs(diff.x) > threashold || abs(diff.y) > threashold) {
            startPoint = currentPoint
            updatePosition(
                dx: min(1, max(-1, diff.x/thumb)),
                dy: min(1, max(-1, diff.y/thumb)))
        }

        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        super.endTrackingWithTouch(touch, withEvent: event)
        self.stopMotionMonitoring()
        self.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
    }
    
    
    // MARK: Motion monitoring
    private let motionManager = CMMotionManager()
    private let motionQueue = NSOperationQueue()
    private var previousMotion: CMDeviceMotion?
    private var isTrackingMotion: Bool = false
    
    private func startMonitoringPosition() {

        // If the device motion isn't available then don't do anything'
        guard motionManager.deviceMotionAvailable else { return }

        // Setup initial state
        previousMotion = nil
        isTrackingMotion = false
        
        // Start monitoring motion position
        motionManager.deviceMotionUpdateInterval = 0.1;
        motionManager.startDeviceMotionUpdatesToQueue(motionQueue, withHandler: { [weak self] (data:CMDeviceMotion?, error:NSError?) -> Void in
            if (error != nil) {
                print("Motion error: ", error!)
            }
            else if let motion = data {
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    self?.updateMotionPosition(motion)
                }
            }
        })
    }
    
    private func stopMotionMonitoring() {
        motionManager.stopDeviceMotionUpdates()
        position = CGPointZero
    }
    
    private func updateMotionPosition(motion:CMDeviceMotion) {

        // Ignore the first reading since the pressure of tapping the screen
        // can result in an inital jump.
        guard isTrackingMotion else {
            isTrackingMotion = true
            return
        }
        
        // If the previous gravity has been set (and therefore there is something to compare against)
        // then update the position of the control
        if let previousGravity = self.previousMotion?.gravity {
            
            // Use a multiplier to scale the difference since +1 / -1 is the full tilt about the axis
            let xMultiplier = 1.5
            let yMultiplier = 2.0
    
            updatePosition(
                dx: CGFloat(xMultiplier * (motion.gravity.x - previousGravity.x)),
                dy: CGFloat(yMultiplier * (motion.gravity.y - previousGravity.y)))
        }
    
        // retain the previous motion
        self.previousMotion = motion
    }

}
