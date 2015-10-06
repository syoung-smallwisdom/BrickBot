//
//  CalibrationDial.swift
//
//  Created by Shannon Young on 9/30/15.
//  Copyright © 2015 Smallwisdom. All rights reserved.
//

import UIKit

@IBDesignable
class CalibrationDial: SWPanControl {
    
    @IBOutlet weak var valueLabel: UILabel?

    @IBInspectable var dialPosition: CGFloat {
        get {
            return position.x;
        }
        set (dialPosition) {
            position.x = round(dialPosition*100)/100;
            updateLayerProperties()
        }
    }
    
    override var position: CGPoint {
        didSet {
            updateLayerProperties()
        }
    }
    
    override func updatePosition(dx dx: CGFloat, dy: CGFloat) {
        let ddx = (dialPosition >= 0) ? dx - dy : dx + dy
        super.updatePosition(dx: round(ddx*100)/100, dy: 0)
    }
    
    // MARK: Draw the dial
    
    let lineWidth: CGFloat = 24
    
    private var leftLayer: CAShapeLayer!
    private var rightLayer: CAShapeLayer!
    private var dotLayer: CAShapeLayer!

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.thumb = bounds.width / 2
        self.threshold = bounds.width / 200
        
        if (leftLayer == nil) {
            leftLayer = CAShapeLayer()
            layer.addSublayer(leftLayer)
        }
        leftLayer.frame = layer.bounds
        
        if (rightLayer == nil) {
            rightLayer = CAShapeLayer()
            layer.addSublayer(rightLayer)
        }
        rightLayer.frame = layer.bounds
        
        if (dotLayer == nil) {
            dotLayer = CAShapeLayer()
            layer.addSublayer(dotLayer)
        }
        dotLayer.frame = layer.bounds
        
        updateLayerProperties()
    }
    
    private func updateLayerProperties() {
        valueLabel?.text = String(dialPosition)
        if leftLayer != nil {
            leftLayer.path = calculateLeftPath().CGPath
            leftLayer.fillColor = UIColor.redColor().CGColor
        }
        if rightLayer != nil {
            rightLayer.path = calculateRightPath().CGPath
            rightLayer.fillColor = UIColor.greenColor().CGColor
        }
        if dotLayer != nil {
            dotLayer.path = calculateDotPath().CGPath
            dotLayer.fillColor = UIColor.whiteColor().CGColor
            dotLayer.shadowColor = UIColor.blackColor().CGColor
            dotLayer.shadowPath = dotLayer.path
            dotLayer.shadowOffset = CGSizeMake(0, 0)
            dotLayer.shadowRadius = 2
            dotLayer.shadowOpacity = 0.8
        }
    }
    
    private func calculateLeftPath() -> UIBezierPath {
        return createArcPath(from: -1, to: dialPosition)
    }
    
    private func calculateRightPath() -> UIBezierPath {
        return createArcPath(from: dialPosition, to: 1)
    }
    
    private func calculateDotPath() -> UIBezierPath {
        return createArcPath(from: dialPosition, to: dialPosition)
    }
    
    private func createArcPath(from from: CGFloat, to: CGFloat) -> UIBezierPath {
        
        let size = bounds.insetBy(dx: lineWidth / 1.5, dy: lineWidth / 1.5)
        let outerRadius = (size.height * size.height + size.width * size.width / 4) / (2 * size.height)
        let innerRadius = outerRadius - lineWidth
        let theta = size.width/2 > size.height ? asin(size.width / (2 * outerRadius)) : CGFloat(M_PI)/2 + asin((size.height - size.width / 2) / outerRadius)
        let arcCenter = CGPointMake(bounds.width / 2.0, outerRadius + 3)
        let startAngle = -1 * CGFloat(M_PI_2) + from * theta
        let endAngle = -1 * CGFloat(M_PI_2) + to * theta
        let capRadius = innerRadius + lineWidth / 2
        let leftEndCapAngle = startAngle + CGFloat(M_PI)
        let leftEndCapCenter = CGPointMake(arcCenter.x - capRadius * sin(-1*from*theta), arcCenter.y - capRadius * cos(from*theta))
        let rightEndCapAngle = endAngle + CGFloat(M_PI)
        let rightEndCapCenter = CGPointMake(arcCenter.x - capRadius * sin(-1*to*theta), arcCenter.y - capRadius * cos(to*theta))
        
        let shapePath = UIBezierPath()
        shapePath.addArcWithCenter(leftEndCapCenter, radius: lineWidth / 2, startAngle: leftEndCapAngle, endAngle: leftEndCapAngle + CGFloat(M_PI), clockwise: true)
        shapePath.addArcWithCenter(arcCenter, radius: outerRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        shapePath.addArcWithCenter(rightEndCapCenter, radius: lineWidth / 2, startAngle: rightEndCapAngle + CGFloat(M_PI), endAngle: rightEndCapAngle, clockwise: true)
        shapePath.addArcWithCenter(arcCenter, radius: innerRadius, startAngle: endAngle, endAngle: startAngle, clockwise: false)
        shapePath.closePath()
        
        return shapePath
    }
    

}