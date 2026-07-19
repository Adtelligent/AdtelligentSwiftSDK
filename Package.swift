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
            url: "https://github.com/Adtelligent/AdtelligentSwiftSDK/releases/download/0.1.0/AdtelligentSwiftSDK.xcframework.zip",
            checksum: "e696a4b12246cda900833759cf4b3d8f8dc01aa8fa374269814bf78da1c840fa"
        ),
    ]
)
