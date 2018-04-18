#
# Be sure to run `pod lib lint PiWebMeshModel.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PiWebMeshModel'
  s.version          = '0.1.0'
  s.summary          = 'Framework to read CAD visualization data in MeshModel format for the ZEISS PiWeb quality data management system.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
PiWebMeshModel is a framework to read CAD visualization data in MeshModel format for the ZEISS PiWeb quality data management system.
                       DESC

  s.homepage         = 'https://github.com/ZEISS-PiWeb/PiWebMeshModel'
  s.license          = { :type => 'BSD', :file => 'LICENSE' }
  s.author           = { 'David Dombrowe' => 'dombrowe@zeiss-izm.de' }
  s.source       = { :path => '.' }
  # s.source           = { :git => 'https://github.com/ZEISS-PiWeb/PiWebMeshModel', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.swift_version = '4.1'
  s.source_files = 'PiWebMeshModel/Classes/*', 'PiWebMeshModel/Classes/**/*'
  s.dependency "objective-zip", "~> 1.0"
  
end
