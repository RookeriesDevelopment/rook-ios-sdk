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
    
    .target(
      name: "RookSDK",
      dependencies: ["RookAppleHealth",
                     "RookConnectTransmission",
                     "RookUsersSDK"],
      cxxSettings: [
        .headerSearchPath("include")
      ]
    ),
    
      .binaryTarget(name: "RookAppleHealth",
                    path: "./RookAppleHealth/RookAppleHealth.xcframework"),
      .binaryTarget(name: "RookConnectTransmission",
                    path: "./RookConnectTransmission/RookConnectTransmission.xcframework"),
      .binaryTarget(name: "RookUsersSDK",
                    path: "./RookUsersSDK/RookUsersSDK.xcframework")
    
  ]
)
