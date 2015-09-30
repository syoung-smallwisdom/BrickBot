//
//  SettingsButton.swift
//
//  Created by Shannon Young on 9/15/14.
//  Copyright (c) 2014 Smallwisdom. All rights reserved.
//

import UIKit

@IBDesignable
class SWSettingsButton: UIButton {
    
    override var enabled: Bool {
        didSet {
            updateLayerProperties()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Set the outer circle using the base layer
        layer.cornerRadius = bounds.size.height/2
        
        if (gearLayer == nil) {
            gearLayer = CAShapeLayer()
            layer.addSublayer(gearLayer!)
        }
        gearLayer?.frame = bounds
        gearLayer?.path = createGearPath().CGPath
        
        updateLayerProperties()
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        updateLayerProperties()
    }
    
    private var buttonColor: UIColor? {
        // stroke the path
        if (self.enabled) {
            return self.tintColor
        }
        else {
            return UIColor.grayColor()
        }
    }
    
    private var gearLayer: CAShapeLayer?
    
    private func updateLayerProperties() {
        // Update the color
        layer.borderWidth = 1.0
        layer.borderColor = buttonColor?.CGColor
        gearLayer?.strokeColor = buttonColor?.CGColor
        gearLayer?.fillColor = buttonColor?.CGColor
    }
    
    func createGearPath() -> UIBezierPath
    {
        let path = UIBezierPath()
        
        let center = CGPointMake(bounds.width / 2.0, bounds.height / 2.0)
        let radiusInner = bounds.width / 5.0
        let radiusOuter = 1.0 * bounds.width / 3.0
        var angle = CGFloat(0.0)
        let pieSlice = CGFloat(M_PI / 6.0)
        
        for _ in 1...6 {
            path.addArcWithCenter(center, radius: radiusOuter,
                startAngle: angle, endAngle:  angle + pieSlice, clockwise: true)
            angle += pieSlice
            path.addArcWithCenter(center, radius: radiusInner,
                startAngle: angle, endAngle:  angle + pieSlice, clockwise: true)
            angle += pieSlice
        }
        path.closePath()
        
        return path
    }
    
}
