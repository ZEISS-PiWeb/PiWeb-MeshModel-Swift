//
//  MeshModelEdgeNode.swift
//  PiWebMeshModel
//
//  Created by Daniel Flemming on 11.04.18.
//  Copyright © 2018 Carl Zeiss Innovationszentrum für Messtechnik GmbH. All rights reserved.
//

import Foundation
import SceneKit

class MeshModelEdgeNode: SCNNode, SCNShadable, SCNNodeRendererDelegate {
    
    convenience init(edges: [MeshModelEdge]) {
        self.init()
        
        var pointCount = 0
        
        for edge in edges {
            pointCount += edge.points.count
        }
        
        var indizes = [Int32]()
        var points = [SCNVector3]()
        
        indizes.reserveCapacity(Int(pointCount)*2)
        points.reserveCapacity(Int(pointCount))
        
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
        geometry.firstMaterial?.diffuse.contents = UIColor.black
        
        self.rendererDelegate = self
        self.addChildNode(SCNNode(geometry: geometry))
        
        // TODO: Use custom line shader for antialiased line rendering
        // https://www.youtube.com/watch?v=yaS_BbRY0gU
        // https://github.com/robovm/apple-ios-samples/blob/master/MetalInstancedHelix/MetalInstancedHelix/AAPLView.mm
    }

    func renderNode(_ node: SCNNode, renderer: SCNRenderer, arguments: [String: Any]) {
        /*
        glLineWidth(2.0 * Float(UIScreen.main.scale))
        glPolygonOffset(1.0, 2.0)
        glEnable(GLenum(GL_POLYGON_OFFSET_FILL))
        
        renderer.render(atTime: renderer.sceneTime)
        
        glPolygonOffset(1.0, 1.0)
        glDisable(GLenum(GL_POLYGON_OFFSET_FILL))*/
    }
}
