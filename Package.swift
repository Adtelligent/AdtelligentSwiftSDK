// swift-tools-version: 6.1
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
            url: "https://github.com/Adtelligent/AdtelligentSwiftSDK/releases/download/0.0.7/AdtelligentSwiftSDK.xcframework.zip",
            checksum: "597a540fef7b857c5336bc11d534785abf48f0550932ae526c88b0c129164942"
        ),
        .testTarget(
            name: "AdtelligentSwiftSDKTests",
            dependencies: ["AdtelligentSwiftSDK"]
        ),
    ]
)
