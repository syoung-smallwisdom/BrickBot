//
//  SWArrowButton.swift
//
//  Created by Shannon Young on 9/30/15.
//  Copyright © 2015 Smallwisdom. All rights reserved.
//

import UIKit

@IBDesignable
class SWArrowButton: UIButton {
    
    @IBInspectable var topColor: UIColor = UIColor.blueColor()
    @IBInspectable var bottomColor: UIColor = UIColor(red: 136.0/255.0, green: 1.0, blue: 1.0, alpha: 1.0)
    @IBInspectable var angle: Int {
        get {
            return _angle;
        }
        set (newAngle) {
            _angle = max(-180, min(180, newAngle))
        }
    }
    private var _angle: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 1
        self.layer.borderColor = self.tintColor.CGColor
    }
    
    override func drawRect(rect: CGRect) {
        
        // Create the arrow
        let size = self.bounds.size
        let xCenter = floor(size.width / 2.0)
        let xArrowhead = 0.1*size.width
        let yArrowheadTop = 0.1*size.height
        let yArrowheadBottom = floor(size.height / 3.0)
        let xArrowLine = floor(size.width / 5.0)
        let yArrowLineBottom = 0.9*size.height
        
        let arrowPath = UIBezierPath()
        arrowPath.moveToPoint(CGPointMake(xArrowhead, yArrowheadBottom))
        arrowPath.addLineToPoint(CGPointMake(xCenter, yArrowheadTop))
        arrowPath.addLineToPoint(CGPointMake(size.width - xArrowhead, yArrowheadBottom))
        arrowPath.addLineToPoint(CGPointMake(xCenter + xArrowLine, yArrowheadBottom))
        arrowPath.addLineToPoint(CGPointMake(xCenter + xArrowLine, yArrowLineBottom))
        arrowPath.addLineToPoint(CGPointMake(xCenter - xArrowLine, yArrowLineBottom))
        arrowPath.addLineToPoint(CGPointMake(xCenter - xArrowLine, yArrowheadBottom))
        arrowPath.closePath()
        
        // Create a gradient from light to dark blue
        let alpha: CGFloat = self.selected || self.highlighted ? 1.0 : 0.3
        let colorTop = topColor.colorWithAlphaComponent(alpha).CGColor
        let colorBottom = bottomColor.colorWithAlphaComponent(alpha).CGColor
        
        let gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), [colorTop, colorBottom], [0, 1])!
        
        // Draw to context
        let context = UIGraphicsGetCurrentContext();
        
        CGContextSaveGState(context)
        
        // Rotate the context about center
        let center = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0)
        let theta = CGFloat(Double(angle) * M_PI / 180.0)
        CGContextTranslateCTM(context, center.x, center.y)
        CGContextRotateCTM(context, theta)
        CGContextTranslateCTM(context, -1*center.x, -1*center.y)
        
        // Draw the path
        arrowPath.addClip()
        CGContextDrawLinearGradient(context, gradient, CGPointMake(xCenter, 0), CGPointMake(xCenter, size.height), CGGradientDrawingOptions())
        
        CGContextRestoreGState(context)
    }
    
}