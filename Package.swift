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
            url: "https://github.com/Adtelligent/AdtelligentSwiftSDK/releases/download/0.6.0/AdtelligentSwiftSDK.xcframework.zip",
            checksum: "3d5498f47380d9bad6a147689f94c53f8eb65aefa4c6018d89188c860d637ebc"
        ),
    ]
)
