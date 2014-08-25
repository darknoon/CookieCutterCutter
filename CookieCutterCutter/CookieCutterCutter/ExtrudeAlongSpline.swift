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

func createSTLString(#trianglePoints: [SCNVector3], #normals: [SCNVector3]) -> String {

  var stl = ""

  let println = {(a : String) in
    stl += a + "\n"
  }

  println("solid cutter")
  for i in 0 ..< trianglePoints.count / 3 {
    var normal = normals[3 * i]

    println("  facet normal \(normal.toSTL())")
    println("    outer loop")

    for j in 3 * i ..< 3 * (i + 1) {
      var vertex = trianglePoints[j]
      println("      vertex \(vertex.toSTL())")
    }

    println("    endloop")
    println("  endfacet")

  }
  println("endsolid")

  return stl
}

struct Model {
  let vertices : [SCNVector3]
  let normals : [SCNVector3]
  let elements : [UInt32]
}

func extrudeAlong(points: [CGPoint], extrusionShape: [CGPoint], width: CGFloat, depth: CGFloat, smoothing: Int = 4) -> Model {

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
    let normal =  normalize(cross(q.1 - q.0, q.2 - q.0))

    vertices += [q.0, q.1, q.2]
    normals  += [normal, normal, normal]
    elements += [elemIdx++, elemIdx++, elemIdx++]

    vertices += [q.2, q.1, q.3]
    normals  += [normal, normal, normal]
    elements += [elemIdx++, elemIdx++, elemIdx++]
  }

  for i in 0 ..< points.count {
    let (_, curr, next) = getPrevNext(points, i)

    // Drawn curve normals
    var normal     = calculateNormal(i)
    var normalNext = calculateNormal(i + 1)

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

  return Model(vertices: vertices, normals: normals, elements: elements)
}

