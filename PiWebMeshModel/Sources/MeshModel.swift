//
//  Created by Daniel Flemming on 11.04.18.
//  Copyright © 2018 Carl Zeiss Innovationszentrum für Messtechnik GmbH. All rights reserved.
//

import Foundation
import SceneKit
import ZIPFoundation
import os.log

public typealias MeshModelMutator = (_ model: MeshModel) -> MeshModel

public struct MeshModel {
    public var meshes = [Mesh]()
    public var edges = [Edge]()
}

public class PiWebMeshModel {
    private(set) public var metadata = PiWebMeshModelMetadata()
    private var model = MeshModel()
    private var modelMutators = [MeshModelMutator]()
    private let unobfuscatedFilename: String
    private var cachedNode = SCNNode()
    private var isDirty = true
    
    public var node: SCNNode {
        guard isDirty else {
            return cachedNode
        }
        
        let model = modelMutators.reduce(self.model, { (result, mutator) in
            return mutator(result)
        })
        
        let node = SCNNode()
        let meshNode = MeshNode(meshes: model.meshes)
        meshNode.name = "Mesh"
        let edgeNode = EdgeNode(edges: model.edges)
        edgeNode.name =  "Edge"
        
        node.addChildNode(meshNode)
        node.addChildNode(edgeNode)
        
        cachedNode = node.clone()
        isDirty = false
    
        return cachedNode
    }

    public convenience init?(data: Data) {
        let tempFilename = FileManager.default
            .temporaryDirectory
            .appendingPathComponent(UUID.init().uuidString)
            .path
    
        guard FileManager.default.createFile(atPath: tempFilename, contents: data) else { return nil }
        defer {
            do {
                try FileManager.default.removeItem(atPath: tempFilename)
            } catch {
                os_log("Unable to remove temporary meshmodel file: @%", log: Logger.cad, type: .error, tempFilename)
            }
        }
        
        self.init(filename: tempFilename)
    }
    
    public init?(filename: String) {
        self.unobfuscatedFilename = URL(fileURLWithPath: filename).lastPathComponent
        guard loadModel(filename: filename) else { return nil }
    }
    
    public func add(mutator: @escaping MeshModelMutator) {
        isDirty = true
        modelMutators.append(mutator)
    }
    
    private func loadModel(filename: String) -> Bool {
        let time = Date()
        
        os_log("Reading meshmodel file '%@'.", log: Logger.cad, type: .info, unobfuscatedFilename)

        let archiveURL = URL(fileURLWithPath: filename)
        guard let archive = Archive(url: archiveURL, accessMode: .read) else { return false }
        
        guard let metadata = readMetadata(from: archive) else {
            let elapsed = Int(round(Date().timeIntervalSince(time) * 1000))
            os_log("Error reading meshmodel file '%@' in %d ms.", log: Logger.cad, type: .info, unobfuscatedFilename, elapsed)
            return false
        }
        self.metadata = metadata
        
        if let meshes = readMeshes(from: archive) {
            model.meshes = meshes
        }
        
        if let edges = readEdges(from: archive) {
            model.edges = edges
        }
        
        let elapsed = Int(round(Date().timeIntervalSince(time) * 1000))
        os_log("Done reading meshmodel file '%@' in %d ms.", log: Logger.cad, type: .info, unobfuscatedFilename, elapsed)
        
        return true
    }
    
    private func readMetadata(from archive: Archive) -> PiWebMeshModelMetadata? {
        guard let data = readZipEntry(from: archive, name: "Metadata.xml") else { return nil }
        
        let metadata = PiWebMeshModelMetadata(data: data)
        
        if metadata == nil {
            os_log("Error reading meshmodel file '%@': Model does not contain metadata entry.", log: Logger.cad, type: .error, unobfuscatedFilename)
            return nil
        }
        
        if metadata?.fileVersion ?? Version() <= Version(major: 1, minor: 0) {
            os_log("Error reading meshmodel file '%@': Model too old (version %@)", log: Logger.cad, type: .error, unobfuscatedFilename, (metadata?.fileVersion ?? Version()).description)
            return nil
        }
        
        if (metadata?.partCount ?? 0 ) > 1 {
            os_log("Error reading meshmodel file '%@': Model contains more than one part (number of parts: %d). Multi part models are not supported.", log: Logger.cad, type: .error, unobfuscatedFilename, metadata?.partCount ?? 0)
            return nil
        }
        
        return metadata
    }
    
    private func readEdges(from archive: Archive) -> [Edge]? {
        guard let data = readZipEntry(from: archive, name: "Edges.dat") else { return nil }
    
        var offset: Int = 0
        let edgeCount = data.readInt32(offset: &offset)
        guard edgeCount > 0 else { return nil }
        
        var edges = [Edge]()
        edges.reserveCapacity(edgeCount)
        for _ in 0 ..< edgeCount {
            edges.append(Edge(data: data, offset: &offset, fileVersion: self.metadata.fileVersion))
        }
        
        return edges
    }
    
    private func readMeshes(from archive: Archive) -> [Mesh]? {
        guard let data = readZipEntry(from: archive, name: "Meshes.dat") else { return nil }
        
        var offset: Int = 0
        let meshCount = data.readInt32(offset: &offset)
        guard meshCount > 0 else { return nil }
        
        var meshes = [Mesh]()
        meshes.reserveCapacity(meshCount)
        for _ in 0 ..< meshCount {
            meshes.append(Mesh(data: data, offset: &offset, fileVersion: self.metadata.fileVersion))
        }
        
        return meshes
    }
    
    private func readZipEntry(from archive: Archive, name: String) -> Data? {
        guard let entry = archive[name] else { return nil }
        
        var data = Data()
        do {
            let _ = try archive.extract(entry, consumer: { data.append($0) })
            return data
        } catch {
            os_log("Error reading meshmodel file '%@': Unzipping '%@' failed.", log: Logger.cad, type: .error, unobfuscatedFilename, name)
            return nil
        }
    }
}
