//
//  PointsView.swift
//  CookieCutterCutter
//
//  Created by Elizabeth Salazar on 8/23/14.
//
//

import Foundation
import UIKit

class PointsView : UIView {
    
    var inProgress : Bool = false
    
    var points : [CGPoint] = [] {
        didSet(setPoints) {
            self.setNeedsDisplay()
        }
    }
    
    override func drawRect(r: CGRect) {
        var ctx = UIGraphicsGetCurrentContext()
        if ctx == nil {
            return
        }
        UIColor.orangeColor().setStroke()
        CGContextSetLineWidth(ctx, 6)
        if points.count > 0 {
            CGContextBeginPath(ctx)
            CGContextMoveToPoint(ctx, points[0].x, points[0].y)
            for p in points {
                CGContextAddLineToPoint(ctx, p.x, p.y)
            }
            if !inProgress {
                CGContextClosePath(ctx)
            }
            CGContextStrokePath(ctx)
        }
    }
    
}