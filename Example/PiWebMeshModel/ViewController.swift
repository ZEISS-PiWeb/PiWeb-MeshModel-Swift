//
//  Created by Daniel Flemming on 11.04.18.
//  Copyright © 2018 Carl Zeiss Innovationszentrum für Messtechnik GmbH. All rights reserved.
//

import UIKit
import GLKit
import SceneKit
import os.log
import PiWebMeshModel

class ViewController: UIViewController {
    private let logger = OSLog(subsystem: "com.zeiss-izm.piwebmeshmodel", category: "demo")
    
    // MeshModel-Testdaten
    private let meshModelResource = "MetalPart"
    //    private let meshModelResource = "Cube"
    //    private let meshModelResource = "Panel"
    
    @IBOutlet weak var sceneView: SCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let path = Bundle.main.path(forResource: meshModelResource, ofType: "meshModel" )
        guard let filename = path else {
            os_log("Error reading meshmodel file '%@.meshModel': The file does not exist.", log: logger, type: .error, meshModelResource)
            return
        }
        
        // MeshModel aus Datei einlesen
        let model = MeshModel.init(filename: filename)
        guard let meshModel = model else {
            return
        }
        
        // Zentrum des MeshModels definieren
        let center = meshModel.boundingSphere.center
        meshModel.pivot = SCNMatrix4MakeTranslation(center.x, center.y, center.z)
        
        // MeshModel in SceneView darstellen
        let scene = SCNScene()
        scene.rootNode.addChildNode(meshModel)
        sceneView.scene = scene
    }
}

