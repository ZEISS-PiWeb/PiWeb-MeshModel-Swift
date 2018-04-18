//
//  Version.swift
//  PiWeb-MeshModel-Demo
//
//  Created by Daniel Flemming on 11.04.18.
//  Copyright © 2018 Carl Zeiss Innovationszentrum für Messtechnik GmbH. All rights reserved.
//

import Foundation

public struct Version {

    var major = 0
    var minor = 0
    var build = 0
    var revision = 0
    
    init() {
    }

    init(major: Int, minor: Int) {
        self.major = major
        self.minor = minor
    }
    
    init(major: Int, minor: Int, build: Int, revision: Int) {
        self.major = major
        self.minor = minor
        self.build = build
        self.revision = revision
    }

    init?(versionString: String) {
        self.init()

        var components = versionString.split(separator: ".").map { String($0) }
        if components.count >= 2 && components.count <= 4 {
            self.major = Int(components[0]) ?? 0
            self.minor = Int(components[1]) ?? 0
            
            if components.count > 2 {
                self.build = Int(components[2]) ?? 0
            }
            if components.count > 3 {
                self.revision = Int(components[3]) ?? 0
            }
        } else {
            return nil
        }
    }
}

extension Version: CustomStringConvertible {
    public var description: String {
        return "\(self.major).\(self.minor).\(self.build).\(self.revision)"
    }
}

extension Version: Comparable {
}

public func <= (lhs: Version, rhs: Version) -> Bool {
    if lhs.major != rhs.major {
        return lhs.major <= rhs.major
    }
    if lhs.minor != rhs.minor {
        return lhs.minor <= rhs.minor
    }
    if lhs.build != rhs.build {
        return lhs.build <= rhs.build
    }
    if lhs.revision != rhs.revision {
        return lhs.revision <= rhs.revision
    }
    return true
}

public func >= (lhs: Version, rhs: Version) -> Bool {
    if lhs.major != rhs.major {
        return lhs.major >= rhs.major
    }
    if lhs.minor != rhs.minor {
        return lhs.minor >= rhs.minor
    }
    if lhs.build != rhs.build {
        return lhs.build >= rhs.build
    }
    if lhs.revision != rhs.revision {
        return lhs.revision >= rhs.revision
    }
    return true
}

public func > (lhs: Version, rhs: Version) -> Bool {
    if lhs.major != rhs.major {
        return lhs.major > rhs.major
    }
    if lhs.minor != rhs.minor {
        return lhs.minor > rhs.minor
    }
    if lhs.build != rhs.build {
        return lhs.build > rhs.build
    }
    if lhs.revision != rhs.revision {
        return lhs.revision > rhs.revision
    }
    return false
}

public func < (lhs: Version, rhs: Version) -> Bool {
    if lhs.major != rhs.major {
        return lhs.major < rhs.major
    }
    if lhs.minor != rhs.minor {
        return lhs.minor < rhs.minor
    }
    if lhs.build != rhs.build {
        return lhs.build < rhs.build
    }
    if lhs.revision != rhs.revision {
        return lhs.revision < rhs.revision
    }
    return false
}

public func == (lhs: Version, rhs: Version) -> Bool {
    return lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.build == rhs.build && lhs.revision == rhs.revision
}
