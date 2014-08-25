//
//  ViewController.swift
//  CookieCutterCutter
//
//  Created by Andrew Pouliot on 8/23/14.
//
//

import UIKit
import SceneKit

func makeGeometry(m: Model) -> SCNGeometry {
  let vertexSource = SCNGeometrySource(vertices: m.vertices, count: m.vertices.count)
  let normalSource = SCNGeometrySource(normals: m.normals, count: m.normals.count)

  var indexData = NSData(bytes: UnsafePointer<UInt32>(m.elements), length: m.elements.count * sizeof(UInt32))

  let element = SCNGeometryElement(data: indexData,
    primitiveType: SCNGeometryPrimitiveType.Triangles,
    primitiveCount: m.elements.count / 3,
    bytesPerIndex: sizeof(Int32))

  return SCNGeometry(sources: [vertexSource, normalSource], elements: [element]);
}


class ViewController: UIViewController {

  var cutter : SCNShape?
  var points : [CGPoint] = []
  var resetButton : UIButton = UIButton(frame: CGRectMake(20, 20, 200, 50))

  var stlString : String = ""
    
  //This is what the user sees first, added directly to self.view
  var pointsView = PointsView()

  //This only gets displayed after we're done with the pointsView (after touchesEnded
  var extrusionView = ExtrusionView(frame: CGRectZero, options:nil)

  override init() {
      return super.init()
  }

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    return super.init(nibName: nil, bundle: nil)
  }

  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    pointsView.backgroundColor = UIColor.whiteColor()
    
    pointsView.frame = self.view.frame
    pointsView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
    self.view.addSubview(pointsView)
    
    //Reset Button
    resetButton.setTitle("Reset Drawing", forState: UIControlState.Normal)
    resetButton.backgroundColor = UIColor.blackColor()
    resetButton.addTarget(self, action: "resetButtonClick", forControlEvents: UIControlEvents.TouchUpInside)
    
    self.view.addSubview(resetButton)
  }
    
  @objc func resetButtonClick() {
        pointsView.points = []
        extrusionView.removeFromSuperview()
        self.view.insertSubview(pointsView, belowSubview: resetButton)
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

  func saveSTLFile() {
    if var foundDirs = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as? [String] {
      if foundDirs.count > 0 {
        let documents = foundDirs[0];
        let path = documents.stringByAppendingPathComponent("CustomCookieCutter.stl")
        println("saved STL file to \(path)")
        var err : NSError?;
        stlString.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding, error: &err)
      }
    }
  }

  override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {

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
    var middle = self.view.center

    let scale : CGFloat = 0.01

    // Convert coordinates to what we'll use for the geometry
    let scaledPoints = points.map { (p) -> CGPoint in
      let scaled = CGPoint(x: scale * (p.x - middle.x), y: -scale * (p.y - middle.y));
      return scaled
    }

    let depth : CGFloat = 1

    // As ratios
    let cut : CGFloat = 0.2
    let shelfDepth : CGFloat = 0.2
    let width: CGFloat = 0.2

    // Scaled by depth, in 1x1 box
    /*


           Width
     B-----------------C
     |                 |
     |                 |
     |  Top            |  ShelfDepth
     |                 |
     |                 |
     |    E------------D
     |    |
     |    |
     |    |
     |    |
     |    |             
     |    |             
     A----F
        Cut

    */

    var profile : [CGPoint] = [
      CGPoint(x: 0.0, y: 0.0), // A
      CGPoint(x: 0.0, y: 1.0), // B
      CGPoint(x: 1.0, y: 1.0), // C
      CGPoint(x: 1.0, y: 1.0 - shelfDepth), // D
      CGPoint(x: cut, y: 1.0 - shelfDepth), // E
      CGPoint(x: cut, y: 0.0), // F
    ]

    let m = extrudeAlong(scaledPoints, profile, width, depth)

    stlString = createSTLString(trianglePoints: m.vertices, normals: m.normals)
    saveSTLFile()

    var cutterNode = SCNNode(geometry: makeGeometry(m))

    var material = SCNMaterial()
    material.diffuse.contents = UIColor.orangeColor()
    material.specular.contents = UIColor.whiteColor()

    //TODO: delete
    material.doubleSided = true

    cutterNode.geometry.materials = [material]

    var lightNode = SCNNode()
    var light = SCNLight()
    light.type = SCNLightTypeOmni
    lightNode.light = light
    light.attenuationEndDistance = 100
    lightNode.position = SCNVector3(x: 0, y: 0, z: 20)
    scene.rootNode.addChildNode(lightNode)

    extrusionView.childObject = cutterNode
    
    scene.rootNode.addChildNode(cutterNode)
    scene.rootNode.addChildNode(cameraNode)

    extrusionView.frame = self.view.bounds
    extrusionView.backgroundColor = UIColor.whiteColor()
    extrusionView.scene = scene

    
    pointsView.removeFromSuperview()
    self.view.insertSubview(extrusionView, belowSubview: resetButton)

  }


}

