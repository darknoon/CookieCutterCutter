//
//  STLWriting.swift
//  CookieCutterCutter
//
//  Created by Andrew Pouliot on 8/24/14.
//
//

import SceneKit


extension SCNVector3
{
  func toSTL() -> String {
    return "\(self.x) \(self.y) \(self.z)"
  }
}