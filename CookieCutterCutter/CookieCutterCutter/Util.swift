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

func normalizeVector(vector: SCNVector3, length: Float) -> SCNVector3 {
    let x = vector.x/length
    let y = vector.y/length
    let z = vector.z/length
    
    return SCNVector3(x: x, y: y, z: z)
}

func getLengthOfVector(vector: SCNVector3) -> Float {
    return sqrt((vector.x * vector.x) + (vector.y * vector.y) + (vector.z * vector.z))
}

func getVectorCrossProduct(firstVector: SCNVector3, secondVector: SCNVector3) -> SCNVector3 {
    
    let x = (firstVector.y * secondVector.z) - (firstVector.z * secondVector.y)
    let y = (firstVector.z * secondVector.x) - (firstVector.x * secondVector.z)
    let z = (firstVector.x * secondVector.y) - (firstVector.y * secondVector.x)
    
    return SCNVector3(x: x, y: y, z: z)
}

func getVectorDotProduct(firstVector: SCNVector3, secondVector: SCNVector3) -> Float {
    return (firstVector.x * secondVector.x) + (firstVector.y * secondVector.y) + (firstVector.z * secondVector.z)
}

func createQuaternionWithAxisAndAngle(axis: SCNVector3, angle: Float) -> SCNQuaternion {
    
    let sinAngle = sin(angle/2)
    
    let qx = axis.x * sinAngle
    let qy = axis.y * sinAngle
    let qz = axis.z * sinAngle
    let qw = cos(angle/2)
    
    return SCNQuaternion(x: qx, y: qy, z: qz, w: qw)
}

func getLengthOfQuaternion(quat: SCNQuaternion) -> Float {
    return sqrt((quat.x * quat.x) + (quat.y * quat.y) + (quat.z * quat.z) + (quat.w * quat.w))
}

func normalizeQuaternion(quat: SCNQuaternion, length: Float) -> SCNQuaternion {
    
    let x = quat.x/length
    let y = quat.y/length
    let z = quat.z/length
    let w = quat.w/length
    
    return SCNQuaternion(x: x, y: y, z: z, w: w)
}