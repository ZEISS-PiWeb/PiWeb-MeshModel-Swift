# PiWeb MeshModel (for Swift)

| ![Zeiss IQS Logo](Documentation/logo_128x128.png) | The **PiWeb MeshModel library** provides an easy to use interface for reading and especially writing PiWeb meshmodel data used by the quality data management system [ZEISS PiWeb](http://www.zeiss.com/industrial-metrology/en_de/products/software/piweb.html). |
|-|:-|

To read more about the MeshModel format: https://github.com/ZEISS-PiWeb/PiWeb-MeshModel


# Overview

- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)

<a id="markdown-requirements" name="requirements"></a>
## Requirements

* iOS 11

<a id="markdown-installation" name="installation"></a>
## Installation

PiWebMeshModel is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'PiWebMeshModel'
```

<a id="markdown-usage" name="usage"></a>
## Usage

```Swift
import SceneKit
import PiWebMeshModel

let model = MeshModel.init(filename: "MetalPart.meshModel")

let scene = SCNScene()
scene.rootNode.addChildNode(model)
sceneView.scene = scene

```

The MeshModel object is a SceneKitNode and can be used in any SceneKit scene.

## Example Project

An example project and examples for MeshModel files are included with this repository.  To run the example project, clone the repository and run `pod install` from the Example directory first.

<img style="display:block;margin:auto;" src="Documentation/Example.png">

## Author

David Dombrowe.

## License

PiWebMeshModel is available under the BSD license. See the LICENSE file for more info.


# Contributing

This repository makes use of resuable workflows from [ZEISS-PiWeb/github-actions](https://github.com/ZEISS-PiWeb/github-actions). Read the documentation (especially about automated semantic versioning) before committing any changes.