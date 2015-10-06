//
//  BallView.swift
//  BrickBot
//
//  Created by Shannon Young on 9/15/15.
//  Copyright © 2015 Smallwisdom. All rights reserved.
//

import UIKit

class BallView: UIView {
    
    @IBOutlet weak var connectionIndicator: UIActivityIndicatorView!

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.size.height/2.0;
    }
    
    var position: CGPoint = CGPointZero {
        didSet {
            updateBackgroundColor()
        }
    }
    
    var connected: Bool = false {
        didSet {
            if (connected) {
                connectionIndicator.stopAnimating()
            }
            else {
                connectionIndicator.startAnimating()
            }
            updateBackgroundColor()
        }
    }
    
    func updateBackgroundColor() {
        if (connected) {
            // For debugging purposes it is useful to have a color change associated with 
            // which joystick position the robot control is in
            let binPos = BBRobotPosition(ballPosition: position)
            let r: CGFloat = (binPos.steer == .Left) ? 1.0 : 0.0
            let g: CGFloat = (binPos.steer == .Right) ? 1.0 : 0.0
            let b: CGFloat = (binPos.steer == .Center) ? 1.0 : 0.0
            self.backgroundColor = UIColor(red: r, green: g, blue: b, alpha: 1.0)
        }
        else {
            // RGB = (0, 0, 0)
            self.backgroundColor = UIColor.blackColor()
        }
    }

}
