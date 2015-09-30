//
//  SWPanTiltControl
//
//  Created by Shannon Young on 9/30/15.
//  Copyright © 2015 Smallwisdom. All rights reserved.
//

import UIKit
import CoreMotion

class SWPanTiltControl: SWPanControl {
    
    var trackingMotion: Bool {
        return _trackingMotion
    }
    private var _trackingMotion: Bool = false
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let ret = super.beginTrackingWithTouch(touch, withEvent: event)
        if (ret) {
            self.startMonitoringPosition()
        }
        return ret
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        self.stopMotionMonitoring()
        super.endTrackingWithTouch(touch, withEvent: event)
    }
    
    
    // MARK: Motion monitoring
    
    private let motionManager = CMMotionManager()
    private let motionQueue = NSOperationQueue()
    private var previousMotion: CMDeviceMotion?
    private var hasInitalMotion: Bool = false
    
    func startMonitoringPosition() {
        
        // If the device motion isn't available then don't do anything'
        guard motionManager.deviceMotionAvailable else { return }
        
        // Setup initial state
        previousMotion = nil
        hasInitalMotion = false
        _trackingMotion = true
        
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
    
    func stopMotionMonitoring() {
        motionManager.stopDeviceMotionUpdates()
        _trackingMotion = false
    }
    
    private func updateMotionPosition(motion:CMDeviceMotion) {
        
        // Ignore the first reading since the pressure of tapping the screen
        // can result in an inital jump.
        guard hasInitalMotion else {
            hasInitalMotion = true
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
