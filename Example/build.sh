#!/bin/bash

xcodebuild \
  -scheme PiWebMeshModel-Example \
  -workspace PiWebMeshModel.xcworkspace \
  -destination "platform=iOS Simulator,name=iPhone 8" \
  -sdk iphonesimulator \
  BuildSystem=BuildServer \
  clean test \
| xcpretty -f `xcpretty-teamcity-formatter`
if [[ ${PIPESTATUS[0]} != 0 ]]; then exit ${PIPESTATUS[0]}; fi

slather coverage --html --teamcity --scheme PiWebMeshModel-Example --workspace PiWebMeshModel.xcworkspace PiWebMeshModel.xcodeproj
echo "##teamcity[publishArtifacts 'html']"
