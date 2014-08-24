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

func getPrevNext(points:[SCNVector3], i: Int) -> (SCNVector3, SCNVector3, SCNVector3) {
  var prev = modulo(i - 1, points.count);
  var next = modulo(i + 1, points.count);
  var curr = modulo(i    , points.count)
  return (points[prev], points[curr], points[next])
}

func smoothPoints(points: [SCNVector3]) -> [SCNVector3] {
  var smoothedPoints : [SCNVector3] = []
  for i in 0 ..< points.count {
    let (prev, curr, next) = getPrevNext(points, i)

    let smoothed = 0.5 * curr + 0.25 * prev + 0.25 * next

    smoothedPoints.append(smoothed)
  }
  return smoothedPoints
}

func extrudeAlong(points: [CGPoint], extrusionShape: [CGPoint], width: CGFloat, depth: CGFloat, smoothing: Int = 4) -> SCNGeometry {

  var points = points.map({ SCNVector3($0) })
  let extrusionShape = extrusionShape.map({ SCNVector3($0) })

  for i in 0...smoothing {
    points = smoothPoints(points)
  }

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

    println("  facet normal \(normal1.toSTL())")
    // Tri strip steaks

    println("    outer loop")

    vertices += [q.0, q.1, q.2]
    normals  += [normal1, normal1, normal1]
    elements += [elemIdx++, elemIdx++, elemIdx++]

    println("      vertex \(q.0.toSTL())")
    println("      vertex \(q.1.toSTL())")
    println("      vertex \(q.2.toSTL())")

    vertices += [q.2, q.1, q.3]
    normals  += [normal1, normal1, normal1]
    elements += [elemIdx++, elemIdx++, elemIdx++]

    println("      vertex \(q.2.toSTL())")
    println("      vertex \(q.1.toSTL())")
    println("      vertex \(q.3.toSTL())")


    println("    endloop")

    println("  endfacet")
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

