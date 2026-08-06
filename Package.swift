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
            url: "https://github.com/Adtelligent/AdtelligentSwiftSDK/releases/download/0.4.0/AdtelligentSwiftSDK.xcframework.zip",
            checksum: "b5647ff4cc70d3b727e97304c13cc0b466bd2884326b5fac1d7062185d0369c4"
        ),
    ]
)
