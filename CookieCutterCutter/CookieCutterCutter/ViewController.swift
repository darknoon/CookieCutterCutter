//
//  ViewController.swift
//  CookieCutterCutter
//
//  Created by Andrew Pouliot on 8/23/14.
//
//

import UIKit

class ViewController: UIViewController {

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
    self.view.backgroundColor = UIColor.redColor()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
    points = []
  }

  override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
    var t = touches.anyObject() as UITouch
    points.append(t.locationInView(self.view))
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
  }

}

