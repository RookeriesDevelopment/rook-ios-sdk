// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "RookSDK",
  
  platforms: [
    .iOS(.v13)
  ],
  
  products: [
    .library(
      name: "RookSDK",
      targets: ["RookSDK"]),
  ],
  
  dependencies: [
  ],
  
  targets: [
    .binaryTarget(name: "RookSDK",
                  path: "./Sources/RookSDK.xcframework")
  ]
)
