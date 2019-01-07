Pod::Spec.new do |s|
  s.name         = "PiWebMeshModel"
  s.version      = "0.2.0"
  s.summary      = "Framework to read CAD visualization data in MeshModel format for the ZEISS PiWeb quality data management system."
  s.description  = <<-DESC
  PiWebMeshModel is a framework to read CAD visualization data in MeshModel format for the ZEISS PiWeb quality data management system.
                   DESC
  s.homepage     = "https://github.com/ZEISS-PiWeb/PiWeb-MeshModel-Swift"
  s.license      = { :type => "BSD", :file => "LICENSE" }
  s.author       = { "David Dombrowe" => "dombrowe@zeiss-izm.de" }
  s.source       = { :git => "https://github.com/ZEISS-PiWeb/PiWeb-MeshModel-Swift.git", :tag => s.version.to_s }
  s.source_files = "PiWebMeshModel/Sources/**/*.swift"
  s.dependency "ZIPFoundation", "~> 0.9"
  s.ios.deployment_target = '11.0'
  s.swift_version = '4.2'
end
