// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AdtelligentSwiftSDK",
    products: [
        .library(
            name: "AdtelligentSwiftSDK",
            targets: ["AdtelligentSwiftSDK"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "AdtelligentSwiftSDK",
            url: "https://github.com/Adtelligent/AdtelligentSwiftSDK/releases/download/0.0.9/AdtelligentSwiftSDK.xcframework.zip",
            checksum: "fa3fe19e03a07e623024aac698767f117c5f687940ac7e96b4db0102f6f25226"
        ),
        .testTarget(
            name: "AdtelligentSwiftSDKTests",
            dependencies: ["AdtelligentSwiftSDK"]
        ),
    ]
)
