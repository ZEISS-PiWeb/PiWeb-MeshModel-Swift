//
//  Created by Daniel Flemming on 11.04.18.
//  Copyright © 2018 Carl Zeiss Innovationszentrum für Messtechnik GmbH. All rights reserved.
//

import Foundation
import GLKit
import SceneKit

public class Mesh {
    var name = ""
    var layer = [String]()
    var color = SCNVector4(x: 0.267, y: 0.306, z: 0.435, w: 1.000)
    var positions = [SCNVector3]()
    var normals = [SCNVector3]()
    var indices = [Int32]()
    
    convenience init(data: Data, offset: inout Int, fileVersion: Version) {
        self.init()
        
        readName(data: data, offset: &offset, fileVersion: fileVersion)
        readGlobalColor(data: data, offset: &offset)
        
        readPositions(data: data, offset: &offset, fileVersion: fileVersion)
        readNormals(data: data, offset: &offset, fileVersion: fileVersion)
        readIndices(data: data, offset: &offset, fileVersion: fileVersion)
        
        readLayer(data: data, offset: &offset, fileVersion: fileVersion)
        readTextureCoordinates(data: data, offset: &offset, fileVersion: fileVersion)
        readPerPositionColors(data: data, offset: &offset, fileVersion: fileVersion)
    }
    
    private func readName(data: Data, offset: inout Int, fileVersion: Version) {
        guard fileVersion >= Version(major: 2, minor: 1) else { return }

        self.name = data.readString(offset: &offset)
    }

    private func readGlobalColor(data: Data, offset: inout Int) {
        guard data.readBoolean(offset: &offset) else { return }

        let col = data.readInt32(offset: &offset)

        let green = Float(col >> 8 & 0xff)
        let blue = Float(col & 0xff)
        let red = Float(col >> 16 & 0xff)
        let alpha = Float((col >> 24) & 0xff)

        self.color = SCNVector4(x: red / 255.0, y: green / 255.0, z: blue / 255.0, w: alpha / 255.0)
    }

    private func readPerPositionColors(data: Data, offset: inout Int, fileVersion: Version) {
        guard fileVersion >= Version(major: 3, minor: 3) else { return }
        guard data.readBoolean(offset: &offset) else { return }

        // ignored for now
        _ = data.readArray(offset: &offset) as [SCNVector4]
    }

    private func readPositions(data: Data, offset: inout Int, fileVersion: Version) {
        guard data.readBoolean(offset: &offset) else { return }
        
        self.positions = data.readArray(offset: &offset) as [SCNVector3]
    }

    private func readNormals(data: Data, offset: inout Int, fileVersion: Version) {
        guard data.readBoolean(offset: &offset) else { return }
        
        self.normals = data.readArray(offset: &offset) as [SCNVector3]
    }

    private func readIndices(data: Data, offset: inout Int, fileVersion: Version) {
        guard data.readBoolean(offset: &offset) else { return }
        
        self.indices = data.readArray(offset: &offset) as [Int32]
    }
    
    private func readLayer(data: Data, offset: inout Int, fileVersion: Version) {
        guard data.readBoolean(offset: &offset) else { return }
        
        let count = data.readInt32(offset: &offset)
        for _ in 0 ..< count {
            self.layer.append(data.readString(offset: &offset))
        }
    }

    private func readTextureCoordinates(data: Data, offset: inout Int, fileVersion: Version) {
        guard fileVersion >= Version(major: 2, minor: 2) else  { return }
        guard data.readBoolean(offset: &offset) else { return }
        
        // Ignored for now
        _ = data.readArray(offset: &offset) as [SCNVector2]
    }
}

extension Mesh: CustomStringConvertible {
    public var description: String {
        return "Mesh \(self.name) (\(self.indices.count) triangles)"
    }
}

struct SCNVector2 {
    public var x: Float
    public var y: Float

    public init() {
        self.x = 0
        self.y = 0
    }
    
    public init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }
}
