//
//  Created by Daniel Flemming on 11.04.18.
//  Copyright © 2018 Carl Zeiss Innovationszentrum für Messtechnik GmbH. All rights reserved.
//

import Foundation

public class PiWebMeshModelMetadata: NSObject {
    var fileVersion: Version = Version()
    var sourceFormat: String = ""
    var guid: UUID = UUID.empty
    var name: String = ""
    var partCount: Int = 0
    var layer: [String] = []
    
    public override var description: String {
        return "\(name) - (Version \(fileVersion))"
    }
    
    private var currentProperty = ""

    convenience init?(data: Data) {
        self.init()
        
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.shouldProcessNamespaces = false
        parser.shouldReportNamespacePrefixes = false
        parser.shouldResolveExternalEntities = false
        
        parser.parse()
    }
}

extension PiWebMeshModelMetadata: XMLParserDelegate {
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentProperty += string
    }

    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
        currentProperty = ""
    }
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {

        case "FileVersion":
            self.fileVersion = Version(versionString: currentProperty)!
        case "SourceFormat":
            self.sourceFormat = currentProperty
        case "Guid":
            self.guid = UUID(uuidString: currentProperty) ?? UUID.empty
        case "Name":
            self.name = currentProperty
        case "PartCount":
            self.partCount = NSString(string: currentProperty).integerValue
        case "string":
            self.layer.append(currentProperty)
        default:
            break
        }
    }
}
