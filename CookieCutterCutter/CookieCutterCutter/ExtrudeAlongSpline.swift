//
//  ExtrudeAlongSpline.swift
//  CookieCutterCutter
//
//  Created by Andrew Pouliot on 8/23/14.
//
//

import Foundation
import CoreGraphics
import SceneKit

func getPrevNext(points:[CGPoint], i: Int) -> (SCNVector3, SCNVector3, SCNVector3) {
  var prev = modulo(i - 1, points.count);
  var next = modulo(i + 1, points.count);
  var curr = modulo(i    , points.count)
  return (SCNVector3(points[prev]), SCNVector3(points[curr]), SCNVector3(points[next]))
}

func extrudeAlong(points: [CGPoint], extrusionShape: [CGPoint], width: CGFloat, depth: CGFloat) -> SCNGeometry {
  let width : Float = Float(width)

  var vertices : [SCNVector3] = []
  var normals : [SCNVector3] = []
  var elements : [UInt32] = []

  // Calculate a normal for the point from previous and next points
  func calculateNormal(i : Int) -> SCNVector3 {
    let (prev, curr, next) = getPrevNext(points, i)

    let a : SCNVector3 = curr - next

    let na = inv(normalize(curr - next))
    let nb = inv(normalize(prev - curr))
    return (na + nb) * 0.5
  }

  var elemIdx : UInt32 = 0

  func applyBasis(basisU: SCNVector3, basisV: SCNVector3, vector: SCNVector3) -> SCNVector3 {
    return vector.x * basisU + vector.y * basisV
  }

  func emitQuad(q: (SCNVector3, SCNVector3, SCNVector3, SCNVector3)) {

    let normal1 =  normalize(cross(q.1 - q.0, q.2 - q.0))

    // Tri strip steaks

    vertices += [q.0, q.1, q.2]
    normals  += [normal1, normal1, normal1]
    elements += [elemIdx++, elemIdx++, elemIdx++]

    vertices += [q.2, q.1, q.3]
    normals  += [normal1, normal1, normal1]
    elements += [elemIdx++, elemIdx++, elemIdx++]
  }

  for i in 0 ..< points.count {
    let (_, curr, next) = getPrevNext(points, i)

    // Drawn curve normals
    var normal     = calculateNormal(i)
    var normalNext = calculateNormal(i + 1)


    var should = (true, true, true, true)

    for j in 0 ..< extrusionShape.count {
      let (_, shapeCurr, shapeNext) = getPrevNext(extrusionShape, j)

      var down = SCNVector3(x: 0, y: 0, z:Float(-depth) )

      let basis = normal * width
      let basisNext = normalNext * width

      emitQuad( (
        curr + applyBasis(basis,     down, shapeCurr),
        next + applyBasis(basisNext, down, shapeCurr),
        curr + applyBasis(basis,     down, shapeNext),
        next + applyBasis(basisNext, down, shapeNext) ) )
    }

//    // Emit top
//    if should.0 {
//      emitQuad( (curr, next, curr + normal * width, next + normalNext * width ) )
//    }
//
//    // Emit bottom
//    if should.1 {
//      emitQuad( (curr + normal * width + down, next + normalNext * width + down, curr + down, next + down) )
//    }
//
//    // Emit left
//    if should.2 {
//      emitQuad( (curr + down, next + down, curr, next) )
//    }
//
//    // Emit right
//    if should.3 {
//      emitQuad( (
//        curr + down + normal * width,
//        next + down + normalNext * width,
//        curr + normal * width,
//        next + normalNext * width) )
//    }
  }

  let vertexSource = SCNGeometrySource(vertices: vertices, count: vertices.count)
  let normalSource = SCNGeometrySource(normals: normals, count: normals.count)

  var indexData = NSData(bytes: UnsafePointer<UInt32>(elements), length: elements.count * sizeof(UInt32))

  let element = SCNGeometryElement(data: indexData,
    primitiveType: SCNGeometryPrimitiveType.Triangles,
    primitiveCount: elements.count / 3,
    bytesPerIndex: sizeof(Int32))

  return SCNGeometry(sources: [vertexSource, normalSource], elements: [element]);
}

