//
//  ViewController.swift
//  CookieCutterCutter
//
//  Created by Andrew Pouliot on 8/23/14.
//
//

import UIKit
import SceneKit

class ViewController: UIViewController {

  var cutter : SCNShape?
    
  var pointsView = PointsView()

  var extrusionView = SCNView(frame: CGRectZero, options: nil)

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

  override func viewDidLoad() {
    super.viewDidLoad()
    pointsView.backgroundColor = UIColor.whiteColor()
    
    pointsView.frame = self.view.frame
    pointsView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
    self.view.addSubview(pointsView)

  }
    
    override func viewWillLayoutSubviews() {
    
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
    println(strings.count)

    pointsView.inProgress = false
    pointsView.points = points
    
    let scene = SCNScene()

    var camera = SCNCamera()
    camera.xFov = 45
    camera.yFov = 45

    var cameraNode = SCNNode()
    cameraNode.camera = camera
    cameraNode.position = SCNVector3Make(0, 0, 10)

    //Create our shape
    cutter = SCNShape(path: bezierPathFromPoints(), extrusionDepth: 2.0)

    var cutterNode = SCNNode(geometry: cutter)

    scene.rootNode.addChildNode(cutterNode)
    scene.rootNode.addChildNode(cameraNode)

    extrusionView.frame = self.view.bounds
    extrusionView.backgroundColor = UIColor.blueColor()
    extrusionView.scene = scene
    
    pointsView.removeFromSuperview()
    self.view.addSubview(extrusionView)

  }
    
    
  func bezierPathFromPoints() -> UIBezierPath {
    
    var path = UIBezierPath()
        
    if points.count == 0 {
        return path
    }

    var i = 0
    for p in points {
      var middle = self.view.center
      let scaled = CGPoint(x: 0.01 * (p.x - middle.x), y: -0.01 * (p.y - middle.y));
      if i==0 {
        path.moveToPoint(scaled)
      } else {
        path.addLineToPoint(scaled)
      }
      i++
    }
    path.closePath()

    return path
  }

}

