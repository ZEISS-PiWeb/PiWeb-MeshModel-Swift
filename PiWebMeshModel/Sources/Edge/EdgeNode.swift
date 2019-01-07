//
//  Created by Daniel Flemming on 11.04.18.
//  Copyright © 2018 Carl Zeiss Innovationszentrum für Messtechnik GmbH. All rights reserved.
//

import Foundation
import SceneKit

class EdgeNode: SCNNode {
    private let edgeColor = UIColor.black
    private let maximumPointsPerNode = 20000
    
    convenience init(edges: [Edge]) {
        self.init()
        generateEdgeNodes(edges: edges)
    }
        
    private func generateEdgeNodes(edges: [Edge]) {
        let pointCount: Int = edges.map { $0.points.count }.reduce(0, +)
        
        var lines = [Int32]()
        var points = [SCNVector3]()
        
        lines.reserveCapacity(edges.count * 2)
        points.reserveCapacity(pointCount)
        
        var lineIndex: Int32 = 0
        for edge in edges {
            if edge.points.isEmpty { continue }
            if points.count >= maximumPointsPerNode {
                generateNode(lines: lines, points: points)
                
                lines.removeAll()
                points.removeAll()
                lineIndex = 0
            }
            
            let count = Int32(edge.points.count-1)
            
            points += edge.points
            for i in lineIndex ..< lineIndex + count {
                lines.append(i)
                lines.append(i + 1)
            }
            lineIndex += count + 1
        }
        
        generateNode(lines: lines, points: points)
        
        // Use custom line shader for antialiased line rendering:
        // https://www.youtube.com/watch?v=yaS_BbRY0gU
        // https://github.com/robovm/apple-ios-samples/blob/master/MetalInstancedHelix/MetalInstancedHelix/AAPLView.mm
    }
    
    private func generateNode(lines: [Int32], points: [SCNVector3]) {
        guard !points.isEmpty else { return }
        
        let indexData = Data(bytes: lines, count: MemoryLayout<Int32>.size * lines.count)
        let vertexSource = SCNGeometrySource(vertices: points)
        
        let element = SCNGeometryElement(
            data: indexData,
            primitiveType: .line,
            primitiveCount: lines.count / 2,
            bytesPerIndex: MemoryLayout<Int32>.size)
        
        let geometry = SCNGeometry(sources: [vertexSource], elements: [element])
        geometry.firstMaterial?.lightingModel = .constant
        geometry.firstMaterial?.diffuse.contents = edgeColor
        
        addChildNode(SCNNode(geometry: geometry))
    }
}
