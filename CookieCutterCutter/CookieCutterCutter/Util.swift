//
//  Util.swift
//  CookieCutterCutter
//
//  Created by Elizabeth Salazar on 8/23/14.
//
//

import Foundation
import UIKit
import SceneKit

func - (firstVector: SCNVector3, secondVector: SCNVector3) -> SCNVector3 {

    let x = firstVector.x - secondVector.x
    let y = firstVector.y - secondVector.y
    let z = firstVector.z - secondVector.z

    return SCNVector3(x: x, y: y, z: z)
}

func + (firstVector: SCNVector3, secondVector: SCNVector3) -> SCNVector3 {

    let x = firstVector.x + secondVector.x
    let y = firstVector.y + secondVector.y
    let z = firstVector.z + secondVector.z

    return SCNVector3(x: x, y: y, z: z)
}

func * (quat1: SCNQuaternion, quat2: SCNQuaternion) -> SCNQuaternion {

    let nx = (quat1.x * quat2.x - quat1.y * quat2.y - quat1.z * quat2.z - quat1.w * quat2.w)
    let ny = (quat1.x * quat2.y - quat1.y * quat2.x - quat1.z * quat2.w - quat1.w * quat2.z)
    let nz = (quat1.x * quat2.z - quat1.y * quat2.w - quat1.z * quat2.x - quat1.w * quat2.y)
    let nw = (quat1.x * quat2.w - quat1.y * quat2.z - quat1.z * quat2.y - quat1.w * quat2.x)

    return SCNQuaternion(x: nx, y: ny, z: nz, w: nw)
}

func * (a: SCNVector3, k: Float) -> SCNVector3 {
  return SCNVector3(x: a.x * k, y: a.y * k, z: a.z * k)
}

func * (k: Float, a: SCNVector3) -> SCNVector3 {
  return SCNVector3(x: a.x * k, y: a.y * k, z: a.z * k)
}

func normalize(vector: SCNVector3) -> SCNVector3 {
  let len = length(vector)
    let x = vector.x/len
    let y = vector.y/len
    let z = vector.z/len

    return SCNVector3(x: x, y: y, z: z)
}

func normalize(quat: SCNQuaternion) -> SCNQuaternion {
  let len = length(quat)

    let x = quat.x/len
    let y = quat.y/len
    let z = quat.z/len
    let w = quat.w/len

    return SCNQuaternion(x: x, y: y, z: z, w: w)
}

extension SCNVector4 : Printable {

   public var description : String {
        return "vector.x: \(self.x) vector.y: \(self.y) vector.z: \(self.z))"
    }

}

func length(vector: SCNVector3) -> Float {
    return sqrt((vector.x * vector.x) + (vector.y * vector.y) + (vector.z * vector.z))
}

func length(quat: SCNQuaternion) -> Float {
    return sqrt((quat.x * quat.x) + (quat.y * quat.y) + (quat.z * quat.z) + (quat.w * quat.w))
}

//func normalize(vector: SCNVector3) -> SCNVector3
//{
//    return normalizeVector(vector, length(vector))
//}

func cross(firstVector: SCNVector3, secondVector: SCNVector3) -> SCNVector3 {

    let x = (firstVector.y * secondVector.z) - (firstVector.z * secondVector.y)
    let y = (firstVector.z * secondVector.x) - (firstVector.x * secondVector.z)
    let z = (firstVector.x * secondVector.y) - (firstVector.y * secondVector.x)

    return SCNVector3(x: x, y: y, z: z)
}

func dot(firstVector: SCNVector3, secondVector: SCNVector3) -> Float {
    return (firstVector.x * secondVector.x) + (firstVector.y * secondVector.y) + (firstVector.z * secondVector.z)
}

extension SCNQuaternion {

    init(axis: SCNVector3, angle: Float) {
    let sinAngle = sin(angle/2)

    let qx = axis.x * sinAngle
    let qy = axis.y * sinAngle
    let qz = axis.z * sinAngle
    let qw = cos(angle/2)

    self = SCNQuaternion(x: qx, y: qy, z: qz, w: qw)
  }
}

func + (ss: CGPoint, other: CGPoint) -> CGPoint {
  return CGPoint(x: ss.x + other.x, y: ss.y + other.y)
}

func - (ss: CGPoint, other: CGPoint) -> CGPoint {
  return CGPoint(x: ss.x - other.x, y: ss.y - other.y)
}

func * (a: CGPoint, k: CGFloat) -> CGPoint {
  return CGPoint(x: a.x * k, y: a.y * k)
}

func norm(v : CGPoint) -> CGPoint {
  let length = sqrt(v.x * v.x + v.y * v.y)
  if (length < 0.00001) {
    return CGPointZero
  }
  return CGPoint(x: v.x / length, y: v.y / length)
}

func inv (p: SCNVector3) -> SCNVector3 {
  return SCNVector3(x: p.y, y: -p.x, z:p.z)
}

extension SCNVector3 {

  init (_ p : CGPoint) {
   self = SCNVector3(x: Float(p.x), y: Float(p.y), z: 0)
  }

  init (_ p : CGPoint, z: CGFloat) {
   self = SCNVector3(x: Float(p.x), y: Float(p.y), z: Float(z))
  }

  func length() -> Float {
    return sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
  }
}

func modulo(a : Int, b : Int) -> Int {
  let r = a % b
  return r > 0 ? r : -r
}
