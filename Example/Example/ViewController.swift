//
//  ViewController.swift
//  Example
//
//  Created by Kristof Dreier on 07.12.18.
//  Copyright © 2018 Carl Zeiss AG. All rights reserved.
//

import UIKit
import SceneKit
import PiWebMeshModel
import os.log

class ViewController: UIViewController {
    lazy var sceneView: SCNView = {
        let sceneView = SCNView(frame: CGRect.zero)
        sceneView.backgroundColor = UIColor.clear
        sceneView.allowsCameraControl = true
        sceneView.scene = SCNScene()
        return sceneView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(sceneView)
        
        loadModel(resource: "MetalPart")
        setupConstraints()
    }
    
    private func setupConstraints() {
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        sceneView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        sceneView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        sceneView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func loadModel(resource: String) {
        let path = Bundle.main.path(forResource: resource, ofType: "meshModel")
        guard let filename = path else {
            print("Error reading meshmodel file '\(resource).meshModel': File does not exist.")
            return
        }
        
        if let meshModel = PiWebMeshModel(filename: filename) {
            self.sceneView.scene?.rootNode.addChildNode(meshModel.node)
        }
    }
}
