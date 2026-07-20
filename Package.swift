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
            url: "https://github.com/Adtelligent/AdtelligentSwiftSDK/releases/download/0.2.0/AdtelligentSwiftSDK.xcframework.zip",
            checksum: "162d885fa8c82e16d629ece2993e4adc3c5a3a13b6dd5883d945dbfac26f5ac4"
        ),
    ]
)
