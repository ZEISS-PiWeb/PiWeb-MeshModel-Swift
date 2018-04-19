//
//  MeshModelEdgeNode.swift
//  PiWebMeshModel
//
//  Created by Daniel Flemming on 11.04.18.
//  Copyright © 2018 Carl Zeiss Innovationszentrum für Messtechnik GmbH. All rights reserved.
//

import Foundation
import SceneKit

class MeshModelEdgeNode: SCNNode {
    private let edgeColor = UIColor.black

    convenience init(edges: [MeshModelEdge]) {
        self.init()
        self.generateEdgeNodes(edges: edges)
    }

    private func generateEdgeNodes(edges: [MeshModelEdge]) {
        let pointCount: Int = edges.map { $0.points.count }.reduce(0, +)

        var indizes = [Int32]()
        var points = [SCNVector3]()

        indizes.reserveCapacity(pointCount * 2)
        points.reserveCapacity(pointCount)

        var lineIndex: Int32 = 0
        for edge in edges {
            if edge.points.isEmpty { continue }

            points += edge.points

            let count = Int32(edge.points.count-1)
            for i in 0 ..< count {
                indizes.append(lineIndex + i)
                indizes.append(lineIndex + i + 1)
            }
            lineIndex += count + 1
        }

        let indexData = Data(bytes: &indizes, count: MemoryLayout<Int32>.size * indizes.count)
        let vertexSource = SCNGeometrySource(vertices: points)

        let element = SCNGeometryElement(
            data: indexData,
            primitiveType: .line,
            primitiveCount: indizes.count / 2,
            bytesPerIndex: MemoryLayout<Int32>.size)
        let geometry = SCNGeometry(sources: [vertexSource], elements: [element])
        geometry.firstMaterial?.lightingModel = .constant
        geometry.firstMaterial?.diffuse.contents = edgeColor

        self.addChildNode(SCNNode(geometry: geometry))
    }
}
