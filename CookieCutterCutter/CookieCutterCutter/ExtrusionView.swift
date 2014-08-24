//
//  ExtrusionView.swift
//  CookieCutterCutter
//
//  Created by Elizabeth Salazar on 8/23/14.
//
//

import Foundation
import UIKit
import SceneKit

class ExtrusionView : SCNView {
    
    var childObject : SCNNode?
    var anchorPosition : SCNVector3?
    var currentPosition : SCNVector3?
    var quatStart = SCNQuaternion(x: 0, y: 0, z: 0, w: 1)
    var quat = SCNQuaternion(x: 0, y: 0, z: 0, w: 1)
    var currentMatrix : SCNMatrix4 = SCNMatrix4Identity {
        didSet(setCurrentMatrix) {
            childObject!.transform = currentMatrix
        }
    }
    
    func projectOntoSurface(touchPoint: SCNVector3) -> SCNVector3 {
        
        let radius : CGFloat = (self.bounds.size.width)/3
        let center : SCNVector3 = SCNVector3Make(Float(self.bounds.size.width)/2, Float(self.bounds.size.height)/2, 0)
        var P : SCNVector3 = touchPoint - center
        
        P = SCNVector3Make(P.x, P.y * -1, P.z)
        
        let radius2 : Float = Float(radius * radius)
        let length2 : Float = P.x * P.x + P.y * P.y
        
        if length2 <= radius2 {
            P.z = sqrt(radius2 - length2)
        } else {
            P.x *= Float(radius) / sqrt(length2)
            P.y *= Float(radius) / sqrt(length2)
            P.z = 0
        }
        
        return normalize(P)
    }
    
    func computeIncremental() {
        let axis : SCNVector3 = cross(anchorPosition!, currentPosition!)
        let dot1 : Float = dot(anchorPosition!, currentPosition!)
        let angle : Float = acosf(dot1)
        
        var quatRot = SCNQuaternion(axis: axis, angle: angle)
        quatRot = normalize(quatRot)
        
        quat = quatRot * quatStart
        
        println("quat in computeIncremental: \(quat)")
        
        currentMatrix = createMatrixFromQuaternion(quat)
    }
    
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        
        let touch : UITouch = touches.anyObject() as UITouch
        let location : CGPoint = touch.locationInView(self)
        
        println("location: \(location)")
        
        anchorPosition = SCNVector3Make(Float(location.x), Float(location.y), 0)
        anchorPosition = self.projectOntoSurface(anchorPosition!)
        
        println("quatstart: \(quatStart)")
        println("quat \(quat)")
        println("anchorPosition after update: \(anchorPosition)")
        
        //Why this?
        currentPosition = anchorPosition
        
        println("currentPosition: \(currentPosition)")
        
        quatStart = quat
    }
    
    override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {

        let touch : UITouch = touches.anyObject() as UITouch
        let location : CGPoint = touch.locationInView(self)
        
        currentPosition = SCNVector3Make(Float(location.x), Float(location.y), 0)
        currentPosition = self.projectOntoSurface(currentPosition!)
        
        computeIncremental()
    }
    
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
        
        computeIncremental()

    }
    
}