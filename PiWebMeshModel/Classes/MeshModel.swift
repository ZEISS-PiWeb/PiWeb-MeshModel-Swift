//
//  MeshModel.swift
//  PiWebMeshModel
//
//  Created by Daniel Flemming on 11.04.18.
//  Copyright © 2018 Carl Zeiss Innovationszentrum für Messtechnik GmbH. All rights reserved.
//

import Foundation
import GLKit
import SceneKit
import objective_zip
import os.log

public class MeshModel: SCNNode {

    public var metadata: MeshModelMetadata?
    private let meshNode = SCNNode()
    private let edgeNode = SCNNode()

    public convenience init?(data: Data) {
        self.init()
        
        let tempFilename = FileManager.default
            .temporaryDirectory
            .appendingPathComponent(UUID.init().uuidString)
            .path
        if FileManager.default.createFile(atPath: tempFilename, contents: data) {
            defer {
                do {
                    try FileManager.default.removeItem(atPath: tempFilename)
                } catch {
                    os_log("Unable to remove temporary meshmodel file: @%", log: Logger.cad, type: .error, tempFilename)
                }
            }

            let filenameWithoutPath = URL(fileURLWithPath: tempFilename).lastPathComponent
            let modelLoaded = loadModel(filename: tempFilename, unobfuscatedFilename: filenameWithoutPath)

            if !modelLoaded {
                return nil
            }
        }
    }

    public convenience init?(filename: String) {
        self.init()

        let filenameWithoutPath = URL(fileURLWithPath: filename).lastPathComponent
        if !loadModel(filename: filename, unobfuscatedFilename: filenameWithoutPath) {
            return nil
        }
    }
    
    private func loadModel(filename: String, unobfuscatedFilename: String) -> Bool {
        let time = Date()
        
        os_log("Reading meshmodel file '%@'.", log: Logger.cad, type: .info, unobfuscatedFilename)
        do {
            let archive = try OZZipFile(fileName: filename, mode: OZZipFileMode.unzip, error: ())
            
            if let data = readZipEntry(fromArchive: archive, name: "Metadata.xml") {
                self.metadata = MeshModelMetadata(data: data)
            }
            
            if self.metadata == nil {
                os_log("Error reading meshmodel file '%@': Model does not contain metadata entry.", log: Logger.cad, type: .error, unobfuscatedFilename)
                return false
            }
            
            if self.metadata?.fileVersion ?? Version() <= Version(major: 1, minor: 0) {
                os_log("Error reading meshmodel file '%@': Model too old (version %@)", log: Logger.cad, type: .error, unobfuscatedFilename, (self.metadata?.fileVersion ?? Version()).description)
                return false
            }
            
            if (self.metadata?.partCount ?? 0 ) > 1 {
                os_log("Error reading meshmodel file '%@': Model contains more than one part (number of parts: %d). Multi part models are not supported.", log: Logger.cad, type: .error, unobfuscatedFilename, self.metadata?.partCount ?? 0)
                return false
            }
            
            if let data = readZipEntry(fromArchive: archive, name: "Meshes.dat") {
                readMeshes(data: data)
            }
            
            if let data = readZipEntry(fromArchive: archive, name: "Edges.dat") {
                readEdges(data: data)
            }
            
            archive.close()
        } catch let error as OZZipException {
            let elapsed = Int(round(Date().timeIntervalSince(time) * 1000))
            os_log("Error reading meshmodel file '%@' in %d ms with error code %@: %@", log: Logger.cad, type: .error, unobfuscatedFilename, elapsed, error.error, error)

            return false
            
        } catch let error {
            let elapsed = Int(round(Date().timeIntervalSince(time) * 1000))
            os_log("Error reading meshmodel file '%@' in %d ms: %@.", log: Logger.cad, type: .error, unobfuscatedFilename, elapsed, error.localizedDescription)
            
            return false
        }
        
        self.name = unobfuscatedFilename
        self.addChildNode(self.meshNode)
        self.addChildNode(self.edgeNode)
        
        let elapsed = Int(round(Date().timeIntervalSince(time) * 1000))
        os_log("Done reading meshmodel file '%@' in %d ms.", log: Logger.cad, type: .info, unobfuscatedFilename, elapsed)
        
        return true
    }
    
    private func readZipEntry(fromArchive archive: OZZipFile, name: String) -> Data? {
        if archive.locateFile(inZip: name) {
            let entry = archive.getCurrentFileInZipInfo()
            os_log("Reading entry %@ of size %d (compressed: %d bytes).", log: Logger.cad, type: .info, entry.name, entry.length, entry.size)
            
            // Read data in 32K chunks (otherwise the zip library will fail with an error)
            let data = NSMutableData(capacity: Int(entry.length))!
            let buffer = NSMutableData(length: 32*1024)!
            let stream = archive.readCurrentFileInZip()
            
            var bytesRead = stream.readData(withBuffer: buffer)
            var totalBytes = bytesRead
            
            while bytesRead > 0 {
                data.append(buffer.subdata(with: NSRange.init(location: 0, length: Int(bytesRead)) ))

                bytesRead = stream.readData(withBuffer: buffer)
                totalBytes += bytesRead
            }
            if totalBytes != UInt(data.length) {
                os_log("Inconsistent state: Zip entry contains %d but only read %d bytes from zip file.", log: Logger.cad, type: .error, data.length, bytesRead)
            }
            stream.finishedReading()
            
            return data as Data
        } else {
            os_log("No entry with name '%@' found in zip file.", log: Logger.cad, type: .error, name)
        }
        return nil
    }
    
    private func readEdges(data: Data) {
        var offset: Int = 0
        let edgeCount = data.readInt32(offset: &offset)

        if let fileVersion = self.metadata?.fileVersion {
            var edges = [MeshModelEdge]()
            for _ in 0 ..< edgeCount {
                edges.append(MeshModelEdge(data: data, offset: &offset, fileVersion: fileVersion))
            }
            self.edgeNode.addChildNode(MeshModelEdgeNode(edges: edges))
        }
    }
    
    private func readMeshes(data: Data) {
        if let fileVersion = self.metadata?.fileVersion {
            
            var offset: Int = 0

            let meshCount = data.readInt32(offset: &offset)
            if meshCount == 0 {
                return
            }

            var meshes = [MeshModelMesh]()
            meshes.reserveCapacity(meshCount)
            
            for _ in 0 ..< meshCount {
                meshes.append(MeshModelMesh(data: data, offset: &offset, fileVersion: fileVersion))
            }

            self.meshNode.addChildNode(MeshModelMeshNode(meshes: meshes))
        }
    }
}
