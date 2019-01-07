//
//  Created by Daniel Flemming on 11.04.18.
//  Copyright © 2018 Carl Zeiss Innovationszentrum für Messtechnik GmbH. All rights reserved.
//

import Foundation
import GLKit
import SceneKit

public class Edge {
    var name = ""
    var layer = [String]()
    var points = [SCNVector3]()
    var indices = [Int32]()
    var color: UIColor?
    
    convenience init(data: Data, offset: inout Int, fileVersion: Version) {
        self.init()
        
        if fileVersion >= Version(major: 2, minor: 1) {
            self.name = data.readString(offset: &offset)
        }
        
        var layer = [String]()
        
        if data.readBoolean(offset: &offset) {
            let col = data.readInt32(offset: &offset)
            
            let green = CGFloat(col >> 8 & 0xff)
            let blue = CGFloat(col & 0xff)
            let red = CGFloat(col >> 16 & 0xff)
            let alpha =  CGFloat((col >> 24) & 0xff)
            
            // ignore edge color for now
            _ = UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha / 255.0)
        }
        
        if data.readBoolean(offset: &offset) {
            self.points += data.readArray(offset: &offset) as [SCNVector3]
        }
        
        if data.readBoolean(offset: &offset) {
            
            let count = data.readInt32(offset: &offset)
            for _ in 0 ..< count {
                layer.append(data.readString(offset: &offset))
            }
        }
    }
}

extension Edge: CustomStringConvertible {
    public var description: String {
        return "Edge \(self.name) (\(self.points.count) points)"
    }
}
