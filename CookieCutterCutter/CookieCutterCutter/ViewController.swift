//
//  ViewController.swift
//  CookieCutterCutter
//
//  Created by Andrew Pouliot on 8/23/14.
//
//

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

class ViewController: UIViewController {

  var pointsView : PointsView {
    return self.view as PointsView
  }

  override init() {
      return super.init()
  }

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    return super.init(nibName: nil, bundle: nil)
  }

  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  var points : [CGPoint] = []

  override func loadView() {
    self.view = PointsView()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor.whiteColor()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }


  override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
    points = []
    pointsView.points = points
    pointsView.inProgress = true
  }

  override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
    var t = touches.anyObject() as UITouch
    points.append(t.locationInView(self.view))

    pointsView.points = points
  }

  override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
    var strings = points.map({(var t) -> String in
      return NSStringFromCGPoint(t)
    })
    var s = NSArray(array: strings).componentsJoinedByString(", ")

    for t in points {
      s += NSStringFromCGPoint(t)
    }
    println("Touch points" + s)

    pointsView.inProgress = false
    pointsView.points = points
  }

}

