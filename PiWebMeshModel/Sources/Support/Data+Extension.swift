//
//  Created by Daniel Flemming on 11.04.18.
//  Copyright © 2018 Carl Zeiss Innovationszentrum für Messtechnik GmbH. All rights reserved.
//

import Foundation
import SceneKit

extension Data {
    
    func readBoolean(offset: inout Int) -> Bool {
        let value = self[offset]
        offset += 1
        if value == 0 {
            return false
        } else if value == 1 {
            return true
        } else {
            assertionFailure("Inconsistent state => reading a bool should result in 0 or 1 (but got \(value) instead.")
        }
        return false
    }

    func readInt32(offset: inout Int) -> Int {
        var result = Int(self[offset])
        result += Int(self[offset + 1]) << 8
        result += Int(self[offset + 2]) << 16
        result += Int(self[offset + 3]) << 24

        offset += 4
        
        return result
    }

    func read7BitEncodedInt(offset: inout Int) -> Int {
        let num3 = 0
        var result = 0
        var num2 = 0

        repeat {
            result |= (Int(self[offset]) & 0x7f) << num2
            num2 += 7
            offset += 1
        }
        while (( num3 & 0x80 ) != 0 )

        return result
    }

    func readString(offset: inout Int) -> String {
        let count = read7BitEncodedInt(offset: &offset)

        let range = Range(uncheckedBounds: (lower: offset, upper: offset+count))
        var buffer: [Int8] = self.subdata(in: range).withUnsafeBytes {
            Array(UnsafeBufferPointer<Int8>(start: $0, count: count)) as [Int8] }
        buffer.append(0)
        
        offset += count

        return String(utf8String: buffer) ?? ""
    }
        
    func readArray<T>(offset: inout Int) -> [T] {
        let count = readInt32(offset: &offset)
        let start = offset
        offset += count * MemoryLayout<T>.size
        
        let range = Range(uncheckedBounds: (lower: start, upper: offset))
        return self.subdata(in: range).withUnsafeBytes {
            Array(UnsafeBufferPointer<T>(start: $0, count: count))
        }
    }
}
