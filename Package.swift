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
            url: "https://github.com/Adtelligent/AdtelligentSwiftSDK/releases/download/0.0.8/AdtelligentSwiftSDK.xcframework.zip",
            checksum: "85509e53bf44d57879a8a9bf2d328c180f409a849f83f5460f0915cd45b7268d"
        ),
        .testTarget(
            name: "AdtelligentSwiftSDKTests",
            dependencies: ["AdtelligentSwiftSDK"]
        ),
    ]
)
